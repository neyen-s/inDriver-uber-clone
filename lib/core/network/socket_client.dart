import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:indriver_uber_clone/core/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

/// Lightweight socket client wrapper that:
/// - Buffers listener registrations so they are (re)attached on connect.
/// - Provides a `connect()` Future that completes when the socket connects.
/// - Runs a background retry routine to request an initial drivers snapshot.
/// - Keeps internal state to avoid duplicated retries
///  or duplicated listener attachments.
class SocketClient {
  Socket? _socket;
  Completer<void>? _connectCompleter;

  /// Keep permanent registered callbacks so they
  /// can be reattached on reconnect.
  final Map<String, List<void Function(dynamic)>> _registeredListeners = {};

  /// Background retry guard for initial drivers snapshot routine.
  bool _initialDriversRetryRunning = false;

  /// Cancellation flag for the initial drivers retry routine.
  bool _cancelInitialDriversRetry = false;

  /// Exposed for debug / tests.
  Socket? get rawSocket => _socket;

  /// Connect to the server. If a connect attempt is already in progress,
  /// returns the same future.
  Future<void> connect({
    Map<String, dynamic>? extraHeaders,
    Duration timeout = const Duration(seconds: 10),
  }) {
    // If already connecting, reuse the same future.
    if (_connectCompleter != null) return _connectCompleter!.future;

    _connectCompleter = Completer<void>();

    // create a fresh socket instance for each connect
    // (replaces any previous one)
    final options = OptionBuilder().setTransports([
      'websocket',
    ]).disableAutoConnect();

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      // OptionBuilder doesn't have a typed builder method for headers
      // in every version;
      // using Map via setExtraHeaders (if supported) is useful.
      try {
        options.setExtraHeaders(extraHeaders);
      } catch (_) {
        if (kDebugMode) {
          debugPrint(
            'SocketClient: option builder does not support extraHeaders.',
          );
        }
      }
    }

    _socket = io('http://$apiProject', options.build());

    if (kDebugMode) {
      _socket!.on('initial_drivers', (data) {
        debugPrint('EARLY handler initial_drivers -> $data');
      });
    }

    _socket!.onConnect((_) {
      if (kDebugMode) debugPrint('✅ Socket Connected to https://$apiProject');

      // Re-attach previously registered listeners on reconnect.
      _attachRegisteredListeners();

      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.complete();
      }

      if (kDebugMode) {
        _socket!.onAny((event, data) {
          debugPrint('SocketClient onAny -> event: $event, data: $data');
        });
      }

      // Start background routine to request initial drivers snapshot
      // with retries.
      _cancelInitialDriversRetry = false;
      if (!_initialDriversRetryRunning) {
        _ensureInitialDriversRetry().catchError((e) {
          if (kDebugMode) {
            debugPrint('Initial drivers retry routine failed: $e');
          }
        });
      }
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) debugPrint('❌ Socket Disconnected');
      // signal cancellation for any background retry
      _cancelInitialDriversRetry = true;
      _initialDriversRetryRunning = false;

      // Ensure the connect future doesn't leak: if it wasn't completed,
      // complete with error.
      if (!(_connectCompleter?.isCompleted ?? true)) {
        _connectCompleter?.completeError(
          'Socket disconnected before connect completed.',
        );
      }
      // Clear completer so subsequent connect() calls create a new attempt.
      _connectCompleter = null;
    });

    _socket!.onError((err) {
      if (kDebugMode) debugPrint('⚠️ socket Error: $err');
      if (!(_connectCompleter?.isCompleted ?? false)) {
        _connectCompleter!.completeError((err ?? 'socket error') as Object);
      }
    });

    // Some socket.io versions emit 'connect_error'
    try {
      _socket!.on('connect_error', (err) {
        if (kDebugMode) debugPrint('⚠️ socket connect_error: $err');
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError((err ?? 'connect_error') as Object);
        }
      });
    } catch (_) {}

    _socket!.connect();

    // Return the connect future with timeout guard.
    return _connectCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        if (!(_connectCompleter?.isCompleted ?? false)) {
          _connectCompleter!.completeError('connect timeout');
        }
        // Clear completer to allow retry later.
        _connectCompleter = null;
        throw TimeoutException('Socket connect timeout');
      },
    );
  }

  /// Disconnect and reset runtime state. Does not remove permanently registered
  /// listeners (they are kept to allow reattach on a future connect).
  void disconnect() {
    try {
      _socket?.disconnect();
    } catch (_) {}
    _socket = null;

    // Reset connect completer so new connect attempts create a fresh one.
    _connectCompleter = null;

    // Cancel background retry routine if running.
    _cancelInitialDriversRetry = true;
    _initialDriversRetryRunning = false;
    // re-attaches all callbacks automatically.
  }

  /// Emit an event through the underlying socket if available.
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  /// Register an event listener. If the socket exists it will be attached
  /// immediately; otherwise it is kept buffered and attached on connect.
  ///
  /// Duplicate callback functions for the same event are ignored.
  void on(String event, void Function(dynamic) callback) {
    final list = _registeredListeners.putIfAbsent(event, () => []);
    // Avoid duplicates: same callback shouldn't be added more than once.
    var already = false;
    for (final cb in list) {
      if (cb == callback) {
        already = true;
        break;
      }
    }
    if (!already) list.add(callback);

    // Attach now if socket exists
    if (_socket != null) {
      try {
        _socket!.on(event, callback);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SocketClient.on: error attaching callback now: $e');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          'SocketClient.on: socket null, buffered listener for $event',
        );
      }
    }
  }

  /// Remove previously registered callback(s) for an event.
  /// If [callback] is null, remove all callbacks for [event].
  void off(String event, [void Function(dynamic)? callback]) {
    if (callback == null) {
      _registeredListeners.remove(event);
      try {
        _socket?.off(event);
      } catch (_) {}
      return;
    }

    final list = _registeredListeners[event];
    if (list != null) {
      list.removeWhere((cb) => cb == callback);
      if (list.isEmpty) _registeredListeners.remove(event);
    }
    try {
      _socket?.off(event, callback);
    } catch (_) {}
  }

  /// Dispose full internal state (useful in tests or app teardown).
  /// Clears buffered listeners and cancels any background activity.
  Future<void> dispose() async {
    // Cancel background retry if any
    _cancelInitialDriversRetry = true;
    _initialDriversRetryRunning = false;

    try {
      _socket?.disconnect();
    } catch (_) {}
    _socket = null;

    _connectCompleter = null;
    _registeredListeners.clear();
  }

  // -----------------------
  // Internal helpers
  // -----------------------

  /// Reattach all permanently registered listeners to
  ///  the currently connected socket.
  void _attachRegisteredListeners() {
    if (_socket == null) return;
    if (_registeredListeners.isEmpty) return;

    if (kDebugMode) {
      debugPrint(
        'SocketClient: re-attaching ${_registeredListeners.length} event(s)',
      );
    }

    _registeredListeners.forEach((event, callbacks) {
      for (final cb in callbacks) {
        try {
          _socket!.on(event, cb);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('SocketClient: error attaching $event -> $e');
          }
        }
      }
    });
  }

  /// Background routine that requests `initial_drivers` snapshot with retries.
  /// This routine is started automatically after a successful connect.
  Future<void> _ensureInitialDriversRetry({
    int attempts = 4,
    int delayMillis = 250,
    Duration singleWait = const Duration(milliseconds: 700),
  }) async {
    if (_initialDriversRetryRunning) return;
    _initialDriversRetryRunning = true;

    try {
      if (_socket == null) {
        if (kDebugMode) {
          debugPrint('_ensureInitialDriversRetry: socket null -> exit');
        }
        return;
      }

      if (!_socket!.connected) {
        if (kDebugMode) {
          debugPrint(
            '_ensureInitialDriversRetry: socket not connected -> exit',
          );
        }
        return;
      }

      for (var i = 0; i < attempts; i++) {
        if (_cancelInitialDriversRetry) {
          if (kDebugMode) debugPrint('_ensureInitialDriversRetry: cancelled');
          return;
        }

        if (kDebugMode) {
          debugPrint('request_initial_drivers attempt ${i + 1}/$attempts');
        }

        final completer = Completer<dynamic>();
        void onceHandler(dynamic data) {
          if (!completer.isCompleted) completer.complete(data);
        }

        try {
          // Register a single-shot handler if the library supports `once`.
          _socket!.once('initial_drivers', onceHandler);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '_ensureInitialDriversRetry: error attaching once handler: $e',
            );
          }
        }

        try {
          _socket!.emit('request_initial_drivers', {});
        } catch (e) {
          if (kDebugMode) {
            debugPrint('_ensureInitialDriversRetry: emit error $e');
          }
        }

        dynamic incoming;
        try {
          incoming = await completer.future.timeout(singleWait);
        } catch (_) {
          incoming = null;
        } finally {
          // Defensive cleanup: remove the once handler if it wasn't invoked.
          try {
            _socket?.off('initial_drivers', onceHandler);
          } catch (_) {}
        }

        if (incoming != null) {
          if ((incoming is Map && incoming.isNotEmpty) ||
              (incoming is List && incoming.isNotEmpty)) {
            if (kDebugMode) {
              debugPrint(
                '_ensureInitialDriversRetry: got non-empty initial_drivers'
                ' on attempt ${i + 1}',
              );
            }
            return;
          } else {
            if (kDebugMode) {
              debugPrint(
                '_ensureInitialDriversRetry: initial_drivers arrived but'
                ' empty (attempt ${i + 1})',
              );
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              '_ensureInitialDriversRetry: no initial_drivers arrived'
              ' (attempt ${i + 1})',
            );
          }
        }

        // wait before next attempt
        await Future.delayed(Duration(milliseconds: delayMillis));
      }

      if (kDebugMode) {
        debugPrint(
          '_ensureInitialDriversRetry: exhausted attempts,'
          ' no initial drivers found.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_ensureInitialDriversRetry: unexpected error $e');
      }
    } finally {
      _initialDriversRetryRunning = false;
    }
  }
}
