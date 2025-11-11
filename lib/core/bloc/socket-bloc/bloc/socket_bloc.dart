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
    on<SocketDriverRemovalTimeout>(_onDriverRemovalTimeout);

    on<SocketClientRequestReceived>(_onSocketClientRequestReceived);
    on<SendNewClientRequestRequested>(_onSendNewClientRequestRequested);

    on<SendDriverPositionRequested>(_onSendDriverPositionRequested);

    // request / attach initial drivers
    on<RequestInitialDrivers>(_onRequestInitialDrivers);
    on<SocketRequestRemovedReceivedEvent>(_onSocketRequestRemovedReceived);
    on<SendDriverAssignedRequested>(_onSendDriverAssignedRequested);
    on<ListenDriverAssignedChannel>(_onListenDriverAssignedChannel);

    // client-driver offers
    on<ListenClientRequestChannel>(_onListenClientRequestChannel);
    on<StopListeningClientRequestChannel>(_onStopListeningClientRequestChannel);
    on<SendDriverOfferRequested>(_onSendDriverOfferRequested);
    on<SocketDriverOfferReceived>(_onSocketDriverOfferReceived);
  }

  final SocketUseCases _socketUseCases;

  // internal drivers cache (idSocket -> LatLng)
  final Map<String, LatLng> _drivers = {};

  // subscriptions to the streams provided by repository
  final List<StreamSubscription> _socketSubscriptions = [];

  // delayed removal timers for driver disconnects (client behaviour)
  final Map<String, Timer> _pendingRemovals = {};
  final Duration _clientRemovalDelay = const Duration(seconds: 6);

  // channel specific subscriptions (per-client-request channels)
  final Map<String, StreamSubscription> _channelSubscriptions = {};

  bool _isConnecting = false;
  bool _isConnected = false;

  // avoid attaching initial_drivers listener multiple times
  bool _initialDriversAttached = false;

  // initial drivers retry control (client-side)
  int _initialDriversAttempts = 0;
  final int _initialDriversMaxAttempts = 4;
  Timer? _initialDriversRetryTimer;

  // -------------------- CONNECT / DISCONNECT --------------------

  Future<void> _onConnectSocket(
    ConnectSocket event,
    Emitter<SocketState> emit,
  ) async {
    if (_isConnected || _isConnecting) return;
    _isConnecting = true;

    try {
      // connect (repository handles actual socket client)
      await _socketUseCases.connectSocketUseCase();

      // attach listeners (do not await, they create stream subscriptions)
      unawaited(_attachInitialDriversListener());
      unawaited(_attachNewDriverPositionListener());
      unawaited(_attachCreatedClientRequestListener());

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
      // cancel subscriptions + clear state
      for (final s in _socketSubscriptions) {
        await s.cancel();
      }
      _socketSubscriptions.clear();

      for (final s in _channelSubscriptions.values) {
        await s.cancel();
      }
      _channelSubscriptions.clear();

      for (final t in _pendingRemovals.values) {
        t.cancel();
      }
      _pendingRemovals.clear();

      _initialDriversAttached = false;
      await _socketUseCases.disconnectSocketUseCase();
      _drivers.clear();
      _isConnected = false;
      _initialDriversRetryTimer?.cancel();
      emit(SocketDisconnected());
    } catch (e) {
      emit(SocketError('Error disconnecting socket: $e'));
    }
  }

  // -------------------- LISTENERS ATTACH (helpers) --------------------

  Future<void> _attachInitialDriversListener() async {
    if (_initialDriversAttached) return;
    final res = await _socketUseCases.onSocketMessageUseCase('initial_drivers');
    res.fold(
      (failure) => addError(
        Exception('Socket initial_drivers error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            try {
              final snapshot = _parseDriversSnapshot(data);
              add(SocketDriversSnapshotReceived(snapshot));
            } catch (e) {
              // ignore single-bad-payloads
            }
          },
          onError: (e, st) =>
              addError(Exception('initial_drivers stream error: $e')),
        );
        _socketSubscriptions.add(sub);
        _initialDriversAttached = true;
      },
    );
  }

  Future<void> _attachNewDriverPositionListener() async {
    final res = await _socketUseCases.onSocketMessageUseCase(
      'new_driver_position',
    );
    res.fold(
      (failure) => addError(
        Exception('Socket new_driver_position error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            final parsed = _extractIdLatLng(data);
            if (parsed != null) {
              add(
                SocketDriverPositionReceived(
                  idSocket: parsed.id,
                  lat: parsed.lat,
                  lng: parsed.lng,
                ),
              );
            }
          },
          onError: (e, st) =>
              addError(Exception('Stream error on new_driver_position: $e')),
        );
        _socketSubscriptions.add(sub);
      },
    );

    // attach driver_disconnected as well
    final resDisconnect = await _socketUseCases.onSocketMessageUseCase(
      'driver_disconnected',
    );
    resDisconnect.fold(
      (failure) => addError(
        Exception('Socket driver_disconnected error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            final parsed = _extractId(data);
            if (parsed != null) {
              add(SocketDriverDisconnectedReceived(idSocket: parsed));
            }
          },
          onError: (e, st) =>
              addError(Exception('Stream error on driver_disconnected: $e')),
        );
        _socketSubscriptions.add(sub);
      },
    );
  }

  Future<void> _attachCreatedClientRequestListener() async {
    final res = await _socketUseCases.onSocketMessageUseCase(
      'created_client_request',
    );
    res.fold(
      (failure) => addError(
        Exception('Socket created_client_request error: ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            if (data is Map) {
              final id = (data['id_client_request'] ?? data['id'])?.toString();
              if (id != null) {
                add(SocketClientRequestReceived(idClientRequest: id));
              }
            }
          },
          onError: (e, st) =>
              addError(Exception('Stream error on created_client_request: $e')),
        );
        _socketSubscriptions.add(sub);
      },
    );
  }

  // -------------------- EVENTS HANDLERS --------------------

  void _onDriversSnapshotReceived(
    SocketDriversSnapshotReceived event,
    Emitter<SocketState> emit,
  ) {
    // if snapshot empty but we already had cached drivers -> ignore (avoid wiping existing)
    if (event.drivers.isEmpty && _drivers.isNotEmpty) return;

    // if snapshot empty and cache empty -> schedule retry
    if (event.drivers.isEmpty && _drivers.isEmpty) {
      _scheduleInitialDriversRetry();
      return;
    }

    _drivers
      ..clear()
      ..addAll(event.drivers);

    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverPositionReceived(
    SocketDriverPositionReceived event,
    Emitter<SocketState> emit,
  ) {
    _pendingRemovals.remove(event.idSocket)?.cancel();
    _drivers[event.idSocket] = LatLng(event.lat, event.lng);
    emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
  }

  void _onDriverDisconnectedReceived(
    SocketDriverDisconnectedReceived event,
    Emitter<SocketState> emit,
  ) {
    final id = event.idSocket;
    _pendingRemovals[id]?.cancel();
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
    debugPrint(
      'SocketBloc: created_client_request received -> ${event.idClientRequest}',
    );

    emit(SocketClientRequestCreated(event.idClientRequest));
  }

  Future<void> _onSendNewClientRequestRequested(
    SendNewClientRequestRequested event,
    Emitter<SocketState> emit,
  ) async {
    try {
      final payload = {'id_client_request': event.idClientRequest};
      await _socketUseCases.sendSocketMessageUseCase(
        'new_client_request',
        payload,
      );
    } catch (e) {
      emit(SocketError('Error sending new client request: $e'));
    }
  }

  Future<void> _onListenClientRequestChannel(
    ListenClientRequestChannel event,
    Emitter<SocketState> emit,
  ) async {
    final channel = '/${event.idClientRequest}';
    if (_channelSubscriptions.containsKey(channel)) return;

    final res = await _socketUseCases.onSocketMessageUseCase(channel);
    res.fold(
      (failure) => addError(
        Exception('Socket listen error ($channel): ${failure.message}'),
      ),
      (stream) {
        //the cancel of this subscription is handled
        // in _onStopListeningClientRequestChannel
        // ignore: cancel_subscriptions
        final sub = stream.listen(
          (data) {
            if (data is Map) {
              add(
                SocketDriverOfferReceived(
                  idClientRequest: event.idClientRequest,
                  payload: Map<String, dynamic>.from(data),
                ),
              );
            }
          },
          onError: (e, st) =>
              addError(Exception('Stream error on $channel: $e')),
        );
        _channelSubscriptions[channel] = sub;
      },
    );
  }

  Future<void> _onStopListeningClientRequestChannel(
    StopListeningClientRequestChannel event,
    Emitter<SocketState> emit,
  ) async {
    final channel = '/${event.idClientRequest}';
    final sub = _channelSubscriptions.remove(channel);
    if (sub != null) await sub.cancel();
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
    } catch (e) {
      // emit error only on real failures
      emit(SocketError('Error sending new_driver_offer: $e'));
    }
  }

  void _onSocketDriverOfferReceived(
    SocketDriverOfferReceived event,
    Emitter<SocketState> emit,
  ) {
    emit(
      SocketDriverOfferArrived(
        idClientRequest: event.idClientRequest,
        payload: event.payload,
      ),
    );
  }

  // -------------------- REQUEST INITIAL DRIVERS (public event) --------------------

  Future<void> _onRequestInitialDrivers(
    RequestInitialDrivers event,
    Emitter<SocketState> emit,
  ) async {
    // fast path: return cached drivers immediately
    if (_drivers.isNotEmpty) {
      emit(SocketDriverPositionsUpdated(Map.from(_drivers)));
      // still try to refresh in background
      try {
        await _socketUseCases.sendSocketMessageUseCase(
          'request_initial_drivers',
          {},
        );
      } catch (_) {}
      return;
    }

    // attach listener and ask server for snapshot
    await _attachInitialDriversListener();
    try {
      await _socketUseCases.sendSocketMessageUseCase(
        'request_initial_drivers',
        {},
      );
    } catch (_) {}
  }

  Future<void> _onSocketRequestRemovedReceived(
    SocketRequestRemovedReceivedEvent event,
    Emitter<SocketState> emit,
  ) async {
    emit(SocketRequestRemovedState(event.idClientRequest));
  }

  Future<void> _onSendDriverAssignedRequested(
    SendDriverAssignedRequested event,
    Emitter<SocketState> emit,
  ) async {
    try {
      final payload = {
        'id_driver': event.idDriver,
        'id_client_request': event.idClientRequest,
      };
      await _socketUseCases.sendSocketMessageUseCase(
        'new_driver_assigned',
        payload,
      );
      debugPrint('SocketBloc: sent new_driver_assigned -> $payload');
    } catch (e) {
      emit(SocketError('Error sending new_driver_assigned: $e'));
    }
  }

  Future<void> _onListenDriverAssignedChannel(
    ListenDriverAssignedChannel event,
    Emitter<SocketState> emit,
  ) async {
    final channel = 'driver_assigned/${event.idDriver}';
    if (_channelSubscriptions.containsKey(channel)) return;

    final res = await _socketUseCases.onSocketMessageUseCase(channel);
    res.fold(
      (failure) => addError(
        Exception('Socket listen error ($channel): ${failure.message}'),
      ),
      (stream) {
        final sub = stream.listen(
          (data) {
            if (data is Map) {
              final idClientRequest = (data['id_client_request'] ?? data['id'])
                  ?.toString();
              if (idClientRequest != null) {
                // Reuse existing event for removed requests
                add(
                  SocketRequestRemovedReceivedEvent(
                    idClientRequest: idClientRequest,
                  ),
                );
              }
            }
          },
          onError: (e, st) {
            addError(Exception('Stream error on $channel: $e'));
          },
        );
        _channelSubscriptions[channel] = sub;
      },
    );
  }

  // -------------------- HELPERS --------------------

  Map<String, LatLng> _parseDriversSnapshot(dynamic data) {
    final map = <String, LatLng>{};
    if (data is Map) {
      data.forEach((k, v) {
        final lat = _parseToDouble(v?['lat']);
        final lng = _parseToDouble(v?['lng']);
        if (lat != null && lng != null) map[k.toString()] = LatLng(lat, lng);
      });
    }
    return map;
  }

  _IdLatLng? _extractIdLatLng(dynamic data) {
    try {
      if (data is! Map) return null;
      final dynamic rawId =
          data['id'] ??
          data['id_socket'] ??
          data['driver_id'] ??
          data['driverId'];
      final id = rawId?.toString();
      final lat = _parseToDouble(data['lat']);
      final lng = _parseToDouble(data['lng']);
      if (id == null || lat == null || lng == null) return null;
      return _IdLatLng(id: id, lat: lat, lng: lng);
    } catch (_) {
      return null;
    }
  }

  String? _extractId(dynamic data) {
    try {
      if (data is! Map) return null;
      final rawId =
          data['id'] ??
          data['id_socket'] ??
          data['driver_id'] ??
          data['driverId'];
      return rawId?.toString();
    } catch (_) {
      return null;
    }
  }

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

  void _scheduleInitialDriversRetry() {
    if (_initialDriversRetryTimer != null &&
        _initialDriversRetryTimer!.isActive) {
      return;
    }
    if (_initialDriversAttempts >= _initialDriversMaxAttempts) {
      _initialDriversAttempts = 0;
      return;
    }
    _initialDriversAttempts++;
    final delayMs = 300 * _initialDriversAttempts;
    _initialDriversRetryTimer = Timer(
      Duration(milliseconds: delayMs),
      () async {
        try {
          await _socketUseCases.sendSocketMessageUseCase(
            'request_initial_drivers',
            {},
          );
        } catch (_) {}
      },
    );
  }

  @override
  Future<void> close() async {
    for (final t in _pendingRemovals.values) {
      t.cancel();
    }
    _pendingRemovals.clear();
    for (final s in _socketSubscriptions) {
      await s.cancel();
    }
    _socketSubscriptions.clear();
    for (final s in _channelSubscriptions.values) {
      await s.cancel();
    }
    _channelSubscriptions.clear();
    _initialDriversAttached = false;
    _initialDriversRetryTimer?.cancel();
    return super.close();
  }
}

class _IdLatLng {
  _IdLatLng({required this.id, required this.lat, required this.lng});
  final String id;
  final double lat;
  final double lng;
}
