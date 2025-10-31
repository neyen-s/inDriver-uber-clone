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

    on<SocketDriversSnapshotReceived>(_onDriversSnapshotReceived);
    on<SocketDriverPositionReceived>(_onDriverPositionReceived);
    on<SocketDriverDisconnectedReceived>(_onDriverDisconnectedReceived);
    on<SocketClientRequestReceived>(_onSocketClientRequestReceived);
    on<SendNewClientRequestRequested>(_onSendNewClientRequestRequested);

    on<SendDriverPositionRequested>(_onSendDriverPositionRequested);
    on<SocketDriverRemovalTimeout>(_onDriverRemovalTimeout);

    //Client driver offers
    on<ListenClientRequestChannel>(_onListenClientRequestChannel);
    on<StopListeningClientRequestChannel>(_onStopListeningClientRequestChannel);
    on<SendDriverOfferRequested>(_onSendDriverOfferRequested);
    on<SocketDriverOfferReceived>(_onSocketDriverOfferReceived);
  }

  final SocketUseCases _socketUseCases;
  final Map<String, LatLng> _drivers = {}; // key = driverId
  final List<StreamSubscription> _socketSubscriptions = [];

  final Map<String, Timer> _pendingRemovals = {};
  final Duration _clientRemovalDelay = const Duration(seconds: 6);

  final Map<String, StreamSubscription> _channelSubscriptions = {};

  bool _isConnecting = false;
  bool _isConnected = false;

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

      //Creates the socket and starts connecting, but does NOT wait for
      // connection. This allows registering listeners immediately.
      final connectFuture = _socketUseCases.connectSocketUseCase();

      //Listeners
      unawaited(_handleInitialDrivers());
      unawaited(_listenDriverPositions());
      unawaited(_listenNewClientRequests());

      // Now we wait for the conecction to finish
      await connectFuture;
      try {
        await _socketUseCases.sendSocketMessageUseCase(
          'request_initial_drivers',
          {},
        );
        debugPrint('SocketBloc: requested initial drivers snapshot');
      } catch (e) {
        debugPrint('SocketBloc: error requesting initial drivers -> $e');
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

  Future<void> _handleInitialDrivers() async {
    debugPrint(' SocketBloc: requesting initial drivers snapshot');
    final res = await _socketUseCases.onSocketMessageUseCase('initial_drivers');
    res.fold(
      (failure) => addError(
        Exception('Socket initial_drivers error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            if (data == null) return;
            if (data is Map) {
              final snapshot = <String, LatLng>{};
              data.forEach((k, v) {
                final lat = _parseToDouble(v['lat']);
                final lng = _parseToDouble(v['lng']);
                if (lat != null && lng != null) {
                  snapshot[k.toString()] = LatLng(lat, lng);
                }
              });
              add(SocketDriversSnapshotReceived(snapshot));
            }
          },
          onError: (Object e, StackTrace st) =>
              debugPrint('initial_drivers stream error: $e'),
        );
        _socketSubscriptions.add(sub);
      },
    );
  }

  Future<void> _listenDriverPositions() async {
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
                final dynamic rawId =
                    data['id'] ??
                    data['id_socket'] ??
                    data['driver_id'] ??
                    data['driverId'];
                final driverId = rawId?.toString();

                final lat = _parseToDouble(data['lat']);
                final lng = _parseToDouble(data['lng']);

                if (driverId == null || lat == null || lng == null) {
                  debugPrint('Ignored new_driver_position (incomplete): $data');
                  return;
                }

                debugPrint(
                  '--- new_driver_position: id=$driverId lat=$lat lng=$lng'
                  ' emitting now SocketDriverPositionReceived',
                );
                add(
                  SocketDriverPositionReceived(
                    idSocket: driverId,
                    lat: lat,
                    lng: lng,
                  ),
                );
              } else {
                debugPrint(
                  'new_driver_position: unexpected payload type:'
                  ' ${data.runtimeType}',
                );
              }
            } catch (e, st) {
              debugPrint('Error parsing new_driver_position: $e\n$st');
            }
          },
          onError: (Object e, StackTrace st) {
            debugPrint('Stream error on new_driver_position: $e\n$st');
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
                final dynamic rawId =
                    data['id'] ??
                    data['id_socket'] ??
                    data['driver_id'] ??
                    data['driverId'];
                final driverId = rawId?.toString();
                if (driverId != null) {
                  add(SocketDriverDisconnectedReceived(idSocket: driverId));
                } else {
                  debugPrint(
                    '---driver_disconnected: payload without id: $data',
                  );
                }
              } else {
                debugPrint(
                  '----driver_disconnected: unexpected payload type:'
                  '${data.runtimeType}',
                );
              }
            } catch (e, st) {
              debugPrint('Error parsing driver_disconnected: $e\n$st');
            }
          },
          onError: (Object e, StackTrace st) {
            debugPrint('Stream error on driver_disconnected: $e\n$st');
          },
        );

        _socketSubscriptions.add(sub);
      },
    );
  }

  Future<void> _listenNewClientRequests() async {
    final res = await _socketUseCases.onSocketMessageUseCase(
      'created_client_request',
    );
    res.fold(
      (failure) {
        addError(
          Exception('Socket created_client_request error: ${failure.message}'),
        );
      },
      (stream) {
        final sub = stream.listen(
          (data) {
            try {
              if (data == null) return;
              if (data is Map) {
                final rawId =
                    data['id_client_request'] ??
                    data['id'] ??
                    data['idClientRequest'];
                final id = rawId?.toString();
                if (id != null) {
                  debugPrint(
                    'SocketBloc: created_client_request received id=$id',
                  );
                  add(SocketClientRequestReceived(idClientRequest: id));
                } else {
                  debugPrint(
                    'SocketBloc: created_client_request without id: $data',
                  );
                }
              } else {
                debugPrint(
                  'created_client_request:'
                  ' unexpected payload type: ${data.runtimeType}',
                );
              }
            } catch (e, st) {
              debugPrint('Error parsing created_client_request: $e\n$st');
            }
          },
          onError: (Object e, StackTrace st) {
            debugPrint('Stream error on created_client_request: $e\n$st');
          },
        );
        _socketSubscriptions.add(sub);
      },
    );
  }

  void _onDriversSnapshotReceived(
    SocketDriversSnapshotReceived event,
    Emitter<SocketState> emit,
  ) {
    debugPrint(
      'SocketBloc ON snapshot -> emit count=${event.drivers.length},'
      ' keys=${event.drivers.keys.toList()}',
    );

    _drivers
      ..clear()
      ..addAll(event.drivers);
    debugPrint(
      '-- _onDriversSnapshotReceived : SocketBloc EMIT drivers count:'
      ' ${_drivers.length}, keys: ${_drivers.keys.toList()}',
    );
    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverPositionReceived(
    SocketDriverPositionReceived event,
    Emitter<SocketState> emit,
  ) {
    debugPrint(
      'SocketBloc ON update -> id=${event.idSocket}'
      ' lat=${event.lat} lng=${event.lng}',
    );
    _pendingRemovals.remove(event.idSocket)?.cancel();

    _drivers[event.idSocket] = LatLng(event.lat, event.lng);
    debugPrint(
      'SocketBloc EMIT drivers count: ${_drivers.length},'
      ' keys: ${_drivers.keys.toList()}',
    );

    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverDisconnectedReceived(
    SocketDriverDisconnectedReceived event,
    Emitter<SocketState> emit,
  ) {
    final id = event.idSocket;
    _pendingRemovals[id]?.cancel();

    //Allows a delay before removing, in case of quick reconnect
    _pendingRemovals[id] = Timer(_clientRemovalDelay, () {
      _pendingRemovals.remove(id);
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
      debugPrint(
        '-- (client) finalize removal: SocketBloc EMIT drivers count:'
        ' ${_drivers.length}, keys: ${_drivers.keys.toList()}',
      );
      emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
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

  Future<void> _onSocketClientRequestReceived(
    SocketClientRequestReceived event,
    Emitter<SocketState> emit,
  ) async {
    try {
      debugPrint(
        'SocketBloc: _onSocketClientRequestReceived id=${event.idClientRequest}',
      );
      //Emitting ttransitory state to let external listeners react
      emit(SocketClientRequestCreated(event.idClientRequest));
    } catch (e) {
      emit(SocketError('Error processing new client request: $e'));
    }
  }

  Future<void> _onSendNewClientRequestRequested(
    SendNewClientRequestRequested event,
    Emitter<SocketState> emit,
  ) async {
    try {
      debugPrint(
        'SocketBloc: sending new_client_request id=${event.idClientRequest}',
      );
      final payload = {'id_client_request': event.idClientRequest};

      await _socketUseCases.sendSocketMessageUseCase(
        'new_client_request',
        payload,
      );
      debugPrint(
        'SocketBloc: sendSocketMessageUseCase'
        ' completed for id=${event.idClientRequest}',
      );
    } catch (e, st) {
      debugPrint('SocketBloc: error sending new_client_request: $e\n$st');
      emit(SocketError('Error sending new client request via socket: $e'));
    }
  }

  /// ------ Client DRIVER OFFERS ------
  Future<void> _onListenClientRequestChannel(
    ListenClientRequestChannel event,
    Emitter<SocketState> emit,
  ) async {
    final channel = '/${event.idClientRequest}';
    if (_channelSubscriptions.containsKey(channel)) {
      debugPrint('SocketBloc: already listening to $channel');
      return;
    }

    final res = await _socketUseCases.onSocketMessageUseCase(channel);
    res.fold(
      (failure) {
        addError(
          Exception('Socket listen error ($channel): ${failure.message}'),
        );
      },
      (stream) {
        final sub = stream.listen(
          (data) {
            try {
              if (data == null) return;
              if (data is Map) {
                add(
                  SocketDriverOfferReceived(
                    idClientRequest: event.idClientRequest,
                    payload: Map<String, dynamic>.from(data),
                  ),
                );
              } else {
                debugPrint(
                  'Socket $channel: unexpected payload type ${data.runtimeType}',
                );
              }
            } catch (e, st) {
              debugPrint('Error parsing $channel message: $e\n$st');
            }
          },
          onError: (e, st) {
            debugPrint('Stream error on $channel: $e');
          },
        );

        _channelSubscriptions[channel] = sub;
        _socketSubscriptions.add(sub); // si quieres mantener la lista también
        debugPrint('SocketBloc: started listening to $channel');
      },
    );
  }

  Future<void> _onStopListeningClientRequestChannel(
    StopListeningClientRequestChannel event,
    Emitter<SocketState> emit,
  ) async {
    final channel = '/${event.idClientRequest}';
    final sub = _channelSubscriptions.remove(channel);
    if (sub != null) {
      await sub.cancel();
      debugPrint('SocketBloc: stopped listening to $channel');
    }
  }

  Future<void> _onSendDriverOfferRequested(
    SendDriverOfferRequested event,
    Emitter<SocketState> emit,
  ) async {
    try {
      final payload = {
        'id_client_request': event.idClientRequest,
        'id_driver': event.idDriver,
        'fare_offered': event.fare,
        'time': event.time,
        'distance': event.distance,
      };
      await _socketUseCases.sendSocketMessageUseCase(
        'new_driver_offer',
        payload,
      );
      debugPrint(
        'SocketBloc: sent new_driver_offer payload'
        ' for clientRequest ${event.idClientRequest}',
      );
    } catch (e, st) {
      debugPrint('SocketBloc: error sending new_driver_offer: $e\n$st');
    }
  }

  void _onSocketDriverOfferReceived(
    SocketDriverOfferReceived event,
    Emitter<SocketState> emit,
  ) {
    try {
      emit(
        SocketDriverOfferArrived(
          idClientRequest: event.idClientRequest,
          payload: event.payload,
        ),
      );
    } catch (e) {
      emit(SocketError('Error handling driver offer: $e'));
    }
  }

  /// ------ UTILS ------

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
