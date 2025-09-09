import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/socket_use_cases.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  SocketBloc(this._socketUseCases) : super(SocketInitial()) {
    on<ConnectSocket>(_onConnectSocket);
    on<DisconnectSocket>(_onDisconnectSocket);

    // handlers que *sí* usan emit(...) dentro de su scope (correcto)
    on<SocketDriversSnapshotReceived>(_onDriversSnapshotReceived);
    on<SocketDriverPositionReceived>(_onDriverPositionReceived);
    on<SocketDriverDisconnectedReceived>(_onDriverDisconnectedReceived);

    on<SendDriverPositionRequested>(_onSendDriverPositionRequested);
    on<SocketDriverRemovalTimeout>(_onDriverRemovalTimeout);
  }

  final SocketUseCases _socketUseCases;
  final Map<String, LatLng> _drivers = {}; // key = driverId
  final List<StreamSubscription> _socketSubscriptions = [];

  final Map<String, Timer> _pendingRemovals = {};
  final Duration _clientRemovalDelay = const Duration(seconds: 6);

  bool _isConnecting = false;
  bool _isConnected = false;

  // -------------------------
  // Connect / Disconnect
  // -------------------------
  Future<void> _onConnectSocket(
    ConnectSocket event,
    Emitter<SocketState> emit,
  ) async {
    if (_isConnected || _isConnecting) {
      debugPrint(
        'SocketBloc: already connected/connecting -> ignore ConnectSocket',
      );
      return;
    }
    _isConnecting = true;
    try {
      debugPrint('SocketBloc: trying to connect (awaiting repo)...');

      // 1) Lanzamos la conexión (inicia la creación del socket y la conexión) PERO
      // no esperamos aquí a que termine la conexión. Esto permite que el socket
      // exista y se pueda usar para registrar listeners inmediatamente.
      final connectFuture = _socketUseCases.connectSocketUseCase();
      // 2) Registramos listeners (initial_drivers, new_driver_position, driver_disconnected)
      // IMPORTANT: _handleInitialDrivers() y _listenDriverPositions() usan socket.on(...) internamente.
      // Dado que socket ya fue creado dentro de connect(), ahora podemos registrarlos antes de await.
      _handleInitialDrivers();
      _listenDriverPositions();

      // 3) Ahora esperamos a que la conexión realmente se confirme.
      await connectFuture;
      // pedir snapshot/forzar server a enviar
      try {
        await _socketUseCases.sendSocketMessageUseCase(
          'request_initial_drivers',
          {},
        );
        debugPrint('SocketBloc: requested initial drivers snapshot');
      } catch (e) {
        debugPrint('SocketBloc: error requesting initial drivers -> $e');
        // fallback HTTP opcional:
        // final httpSnapshot = await driversRepository.getDriversSnapshotHttp();
        // add(SocketDriversSnapshotReceived(httpSnapshot));
      }
      emit(SocketConnected());
      _isConnected = true;
    } catch (e) {
      emit(SocketError('Error connecting socket: $e'));
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _onDisconnectSocket(
    DisconnectSocket event,
    Emitter<SocketState> emit,
  ) async {
    if (!_isConnected && !_isConnecting) return;
    try {
      for (final sub in _socketSubscriptions) {
        await sub.cancel();
      }
      _socketSubscriptions.clear();
      await _socketUseCases.disconnectSocketUseCase();
      _drivers.clear();
      _isConnected = false;
      emit(SocketDisconnected());
    } catch (e) {
      emit(SocketError('Error disconnecting socket: $e'));
    }
  }

  // -------------------------
  // Inicial snapshot (no emite aquí; añade evento)
  // -------------------------

  Future<void> _handleInitialDrivers() async {
    print(' SocketBloc: requesting initial drivers snapshot');
    final res = await _socketUseCases.onSocketMessageUseCase('initial_drivers');
    res.fold(
      (failure) => addError(
        Exception('Socket initial_drivers error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen((data) {
          if (data == null) return;
          if (data is Map) {
            final snapshot = <String, LatLng>{};
            data.forEach((k, v) {
              final lat = _parseToDouble(v['lat']);
              final lng = _parseToDouble(v['lng']);
              if (lat != null && lng != null)
                snapshot[k.toString()] = LatLng(lat, lng);
            });
            add(SocketDriversSnapshotReceived(snapshot));
          }
        }, onError: (e, st) => debugPrint('initial_drivers stream error: $e'));
        _socketSubscriptions.add(sub);
      },
    );
  }

  // -------------------------
  // Escuchar updates y desconexiones (no emiten: añaden eventos)
  // -------------------------
  Future<void> _listenDriverPositions() async {
    // new_driver_position (posiciones nuevas / updates)
    final resPositions = await _socketUseCases.onSocketMessageUseCase(
      'new_driver_position',
    );

    resPositions.fold(
      (failure) {
        addError(
          Exception('Socket new_driver_position error: ${failure.message}'),
        );
      },
      (stream) {
        final sub = stream.listen(
          (data) {
            try {
              if (data == null) return;

              if (data is Map) {
                dynamic rawId =
                    data['id'] ??
                    data['id_socket'] ??
                    data['driver_id'] ??
                    data['driverId'];
                final driverId = rawId?.toString();

                final lat = _parseToDouble(data['lat']);
                final lng = _parseToDouble(data['lng']);

                if (driverId == null || lat == null || lng == null) {
                  print('Ignored new_driver_position (incomplete): $data');
                  return;
                }

                // En lugar de llamar emit(...) aquí, añadimos un evento que el bloc
                // procesará dentro de su handler (donde sí se puede usar emit).
                print(
                  '--- new_driver_position: id=$driverId lat=$lat lng=$lng emitting now SocketDriverPositionReceived',
                );
                add(
                  SocketDriverPositionReceived(
                    idSocket: driverId,
                    lat: lat,
                    lng: lng,
                  ),
                );
              } else {
                print(
                  'new_driver_position: unexpected payload type: ${data.runtimeType}',
                );
              }
            } catch (e, st) {
              print('Error parsing new_driver_position: $e\n$st');
            }
          },
          onError: (e, st) {
            print('Stream error on new_driver_position: $e\n$st');
          },
        );

        _socketSubscriptions.add(sub);
      },
    );

    // driver_disconnected
    final resDisconnects = await _socketUseCases.onSocketMessageUseCase(
      'driver_disconnected',
    );

    resDisconnects.fold(
      (failure) {
        addError(
          Exception('Socket driver_disconnected error: ${failure.message}'),
        );
      },
      (stream) {
        final sub = stream.listen(
          (data) {
            try {
              if (data == null) return;
              if (data is Map) {
                dynamic rawId =
                    data['id'] ??
                    data['id_socket'] ??
                    data['driver_id'] ??
                    data['driverId'];
                final driverId = rawId?.toString();
                if (driverId != null) {
                  add(SocketDriverDisconnectedReceived(idSocket: driverId));
                } else {
                  print('---driver_disconnected: payload without id: $data');
                }
              } else {
                print(
                  '----driver_disconnected: unexpected payload type: ${data.runtimeType}',
                );
              }
            } catch (e, st) {
              print('Error parsing driver_disconnected: $e\n$st');
            }
          },
          onError: (e, st) {
            print('Stream error on driver_disconnected: $e\n$st');
          },
        );

        _socketSubscriptions.add(sub);
      },
    );
  }

  // -------------------------
  // Event handlers (estos sí emiten directamente)
  // -------------------------
  void _onDriversSnapshotReceived(
    SocketDriversSnapshotReceived event,
    Emitter<SocketState> emit,
  ) {
    print(
      'SocketBloc ON snapshot -> emit count=${event.drivers.length}, keys=${event.drivers.keys.toList()}',
    );

    _drivers
      ..clear()
      ..addAll(event.drivers);
    print(
      '-- _onDriversSnapshotReceived : SocketBloc EMIT drivers count: ${_drivers.length}, keys: ${_drivers.keys.toList()}',
    );
    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverPositionReceived(
    SocketDriverPositionReceived event,
    Emitter<SocketState> emit,
  ) {
    print(
      'SocketBloc ON update -> id=${event.idSocket} lat=${event.lat} lng=${event.lng}',
    );
    _pendingRemovals.remove(event.idSocket)?.cancel();

    _drivers[event.idSocket] = LatLng(event.lat, event.lng);
    print(
      'SocketBloc EMIT drivers count: ${_drivers.length}, keys: ${_drivers.keys.toList()}',
    );

    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverDisconnectedReceived(
    SocketDriverDisconnectedReceived event,
    Emitter<SocketState> emit,
  ) {
    final id = event.idSocket;
    // cancelar timer previo si existe
    _pendingRemovals[id]?.cancel();

    // programamos un Timer que añadirá un evento cuando expire
    _pendingRemovals[id] = Timer(_clientRemovalDelay, () {
      _pendingRemovals.remove(id);
      // en lugar de emitir, añadimos un evento al bloc
      add(SocketDriverRemovalTimeout(id));
    });
  }

  void _onDriverRemovalTimeout(
    SocketDriverRemovalTimeout event,
    Emitter<SocketState> emit,
  ) {
    final id = event.idSocket;
    if (_drivers.containsKey(id)) {
      _drivers.remove(id);
      print(
        '-- (client) finalize removal: SocketBloc EMIT drivers count: ${_drivers.length}, keys: ${_drivers.keys.toList()}',
      );
      emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
    } else {
      // nada que hacer (posible reconexión previa ya canceló)
    }
  }

  Future<void> _onSendDriverPositionRequested(
    SendDriverPositionRequested event,
    Emitter<SocketState> emit,
  ) async {
    try {
      await _socketUseCases.sendSocketMessageUseCase('change_driver_position', {
        'id': event.idDriver,
        'lat': event.lat,
        'lng': event.lng,
      });
    } catch (e) {
      emit(SocketError('Error sending driver position: $e'));
    }
  }

  // -------------------------
  // Util helpers
  // -------------------------
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }
    return null;
  }

  @override
  Future<void> close() async {
    for (final t in _pendingRemovals.values) {
      t.cancel();
    }
    _pendingRemovals.clear();
    for (final sub in _socketSubscriptions) {
      await sub.cancel();
    }
    _socketSubscriptions.clear();
    return super.close();
  }
}
