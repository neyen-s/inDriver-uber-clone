import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketClient {
  Socket? _socket;
  Completer<void>? _connectCompleter;

  // Guardamos los callbacks solicitados por event para poder adjuntarlos
  // cuando el socket esté listo (y volver a adjuntarlos en reconexiones).
  final Map<String, List<void Function(dynamic)>> _registeredListeners = {};

  // Para evitar múltiples rutinas de retry simultáneas
  bool _initialDriversRetryRunning = false;
  // control para cancelar la rutina si desconectamos
  bool _cancelInitialDriversRetry = false;

  Socket? get rawSocket => _socket; // útil para debug / tests

  Future<void> connect({
    Map<String, dynamic>? extraHeaders,
    Duration timeout = const Duration(seconds: 10),
  }) {
    // Si ya hay un intento de conectar en curso, devolvemos la misma futura.
    if (_connectCompleter != null) return _connectCompleter!.future;

    _connectCompleter = Completer<void>();

    // crear nueva instancia de socket cada connect (si existía una previa
    // se reemplaza)
    _socket = io(
      'http://$apiProject',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    // handler early (solo para debug). Puedes removerlo si quieres.
    _socket!.on('initial_drivers', (data) {
      debugPrint('EARLY handler initial_drivers -> $data');
    });

    // Cuando conecte, adjuntamos todos los listeners registrados (si hay)
    _socket!.onConnect((_) {
      debugPrint('✅ Socket Connected to https://$apiProject');

      // Re-attach all previously registered listeners (this handles reconnects)
      if (_registeredListeners.isNotEmpty) {
        debugPrint(
          'SocketClient: re-attaching ${_registeredListeners.length} event(s)',
        );
        _registeredListeners.forEach((event, callbacks) {
          for (final cb in callbacks) {
            try {
              _socket!.on(event, cb);
            } catch (e) {
              debugPrint('SocketClient: error attaching $event -> $e');
            }
          }
        });
      }

      // complete connect() future
      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.complete();
      }

      // debug any event
      _socket!.onAny((event, data) {
        debugPrint('SocketClient onAny -> event: $event, data: $data');
      });

      // Start background routine to request initial drivers snapshot with retries.
      // No bloquea la resolución de connect().
      _cancelInitialDriversRetry = false;
      if (!_initialDriversRetryRunning) {
        _ensureInitialDriversRetry().catchError((e) {
          debugPrint('Initial drivers retry routine failed: $e');
        });
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket Disconnected');
      // signal cancellation for any background retry
      _cancelInitialDriversRetry = true;
      _initialDriversRetryRunning = false;
      // keep _registeredListeners so they are reattached if connect() is called again
    });

    _socket!.onError((err) {
      debugPrint('⚠️ socket Error: $err');
      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.completeError((err ?? 'socket error') as Object);
      }
    });

    // some versions emit 'connect_error'
    try {
      _socket!.on('connect_error', (err) {
        debugPrint('⚠️ socket connect_error: $err');
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError((err ?? 'connect_error') as Object);
        }
      });
    } catch (_) {}

    _socket!.connect();

    return _connectCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError('connect timeout');
        }
        throw TimeoutException('Socket connect timeout');
      },
    );
  }

  void disconnect() {
    try {
      _socket?.disconnect();
    } catch (_) {}
    _socket = null;
    _connectCompleter = null;

    // cancelar rutina de initial drivers si está corriendo
    _cancelInitialDriversRetry = true;
    _initialDriversRetryRunning = false;

    // **NO** borramos _registeredListeners: si vuelves a conectar queremos
    // mantener las suscripciones y re-attach automáticamente.
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  /// Register an event listener. If the socket exists it will be attached
  /// immediately; otherwise kept in memory and attached on connect.
  void on(String event, void Function(dynamic) callback) {
    // store permanently so they are re-attached on reconnects
    _registeredListeners.putIfAbsent(event, () => []).add(callback);

    // attach now if socket exists
    if (_socket != null) {
      try {
        _socket!.on(event, callback);
      } catch (e) {
        debugPrint('SocketClient.on: error attaching callback now: $e');
      }
    } else {
      debugPrint('SocketClient.on: socket null, buffered listener for $event');
    }
  }

  /// Optional: helper to remove a previously registered callback (useful in tests)
  void off(String event, [void Function(dynamic)? callback]) {
    if (callback == null) {
      // remove all callbacks registered for event
      _registeredListeners.remove(event);
      try {
        _socket?.off(event);
      } catch (_) {}
    } else {
      final list = _registeredListeners[event];
      list?.removeWhere((cb) => cb == callback);
      try {
        _socket?.off(event, callback);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Rutina interna: solicita el snapshot inicial y re-intenta si viene vacío.
  // Esto se ejecuta automáticamente después de onConnect y NO requiere cambios
  // en el repoImpl.
  // ---------------------------------------------------------------------------
  Future<void> _ensureInitialDriversRetry({
    int attempts = 4,
    int delayMillis = 250,
    Duration singleWait = const Duration(milliseconds: 700),
  }) async {
    // si ya está corriendo, no arrancamos otra
    if (_initialDriversRetryRunning) return;
    _initialDriversRetryRunning = true;

    try {
      if (_socket == null) {
        debugPrint('_ensureInitialDriversRetry: socket null -> exit');
        return;
      }

      // si no está conectado, salimos
      if (!_socket!.connected) {
        debugPrint('_ensureInitialDriversRetry: socket not connected -> exit');
        return;
      }

      for (int i = 0; i < attempts; i++) {
        if (_cancelInitialDriversRetry) {
          debugPrint('_ensureInitialDriversRetry: cancelled');
          return;
        }

        debugPrint('request_initial_drivers attempt ${i + 1}/$attempts');

        final completer = Completer<dynamic?>();

        // onceHandler -> single-shot
        void onceHandler(dynamic data) {
          if (!completer.isCompleted) completer.complete(data);
        }

        try {
          // se registra un handler once (si la lib lo soporta).
          _socket!.once('initial_drivers', onceHandler);
        } catch (e) {
          debugPrint(
            '_ensureInitialDriversRetry: error attaching once handler: $e',
          );
        }

        // Emitimos por si el servidor espera un evento explícito para enviar snapshot
        try {
          _socket!.emit('request_initial_drivers', {});
        } catch (e) {
          debugPrint('_ensureInitialDriversRetry: emit error $e');
        }

        // esperamos la respuesta o timeout
        dynamic incoming;
        try {
          incoming = await completer.future.timeout(singleWait);
        } catch (_) {
          incoming = null;
        } finally {
          // defensive cleanup: off the once handler in case it wasn't invoked
          try {
            _socket?.off('initial_drivers', onceHandler);
          } catch (_) {}
        }

        if (incoming != null) {
          if ((incoming is Map && incoming.isNotEmpty) ||
              (incoming is List && incoming.isNotEmpty)) {
            debugPrint(
              '_ensureInitialDriversRetry: got non-empty initial_drivers on attempt ${i + 1}',
            );
            // ya llegó un snapshot válido: dejamos de reintentar.
            return;
          } else {
            debugPrint(
              '_ensureInitialDriversRetry: initial_drivers arrived but empty (attempt ${i + 1})',
            );
          }
        } else {
          debugPrint(
            '_ensureInitialDriversRetry: no initial_drivers arrived (attempt ${i + 1})',
          );
        }

        // espera antes de siguiente intento
        await Future.delayed(Duration(milliseconds: delayMillis));
      }

      debugPrint(
        '_ensureInitialDriversRetry: exhausted attempts, no initial drivers found.',
      );
    } catch (e) {
      debugPrint('_ensureInitialDriversRetry: unexpected error $e');
    } finally {
      _initialDriversRetryRunning = false;
    }
  }
}
