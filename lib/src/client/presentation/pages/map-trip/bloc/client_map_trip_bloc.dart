//lint:ignore-file for setting errorMSG back to null on succes is required
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_use_cases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/geo_utils.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/route_phases.dart';
import 'package:indriver_uber_clone/secrets.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

part 'client_map_trip_event.dart';
part 'client_map_trip_state.dart';

class ClientMapTripBloc extends Bloc<ClientMapTripEvent, ClientMapTripState> {
  ClientMapTripBloc(
    this._clientRequestUsecases,
    this._geolocatorUseCases,
    this._socketBloc,
  ) : super(const ClientMapTripState()) {
    on<GetClientRequestById>(_onGetClientRequestById);
    on<DrawRouteForTrip>(_onDrawRouteForTrip);
    on<SocketDriverPositionUpdated>(_onSocketDriverPositionUpdated);
    on<TripStatusReceivedFromSocket>(_onTripStatusReceivedFromSocket);

    //Timer methods
    on<StartLocalEtaCountdown>(_onStartLocalEtaCountdown);
    on<StopLocalEtaCountdown>(_onStopLocalEtaCountdown);
    on<EtaTick>(_onEtaTick);

    _listenToSocket();
    // Start asynchronous load of driver icon to avoid creating
    // it repeatedly later.
    _prepareDriverIcon();
  }

  final ClientRequestsUsecases _clientRequestUsecases;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;

  LatLng? _lastPositionSent;
  StreamSubscription<dynamic>? _socketSub;

  // Prevents concurrent route requests to the routing API.
  bool _isDrawingRoute = false;

  // Cached driver icon to avoid recreating BitmapDescriptor repeatedly.
  BitmapDescriptor? _driverIcon;

  Timer? _localEstimatedTimer;
  final Duration _localTick = const Duration(seconds: 1);

  void _listenToSocket() {
    try {
      _socketSub = _socketBloc.stream.listen((socketState) {
        // debug genérico + runtimeType para ver TODO lo que llega
        print(
          'CLIENT MAP TRIP LISTEN TO SOCKET -> runtimeType=${socketState.runtimeType} value=$socketState',
        );

        // Driver positions (ya ok)
        if (socketState is SocketDriverPositionsUpdated) {
          final assigned = state.clientRequestResponse?.idDriver?.toString();
          if (assigned != null && socketState.drivers.containsKey(assigned)) {
            final pos = socketState.drivers[assigned];
            if (pos != null) {
              add(
                SocketDriverPositionUpdated(
                  assigned,
                  pos.latitude,
                  pos.longitude,
                ),
              );
            }
          }
          return;
        }

        // Trip status
        if (socketState is SocketTripStatusUpdated) {
          final rawId = socketState.idClientRequest;
          final idFromSocket = rawId.toString();
          final localRequestId = state.clientRequestResponse?.id.toString();

          // debug detallado de ids (esto te dirá exactamente por qué falla)
          debugPrint(
            '[ClientMap][_listenToSocket] incoming status rawId=$rawId idFromSocket=$idFromSocket localRequestId=$localRequestId status=${socketState.status}',
          );

          if (localRequestId != null && localRequestId == idFromSocket) {
            add(TripStatusReceivedFromSocket(status: socketState.status));
          } else {
            debugPrint(
              '[ClientMap][_listenToSocket] ignored status: id mismatch (local=$localRequestId socket=$idFromSocket)',
            );
          }
          return;
        }

        if (socketState is SocketTripDriverPositionUpdated) {
          add(
            SocketDriverPositionUpdated(
              socketState.idSocket,
              socketState.lat,
              socketState.lng,
            ),
          );
          return;
        }
      });

      // initial snapshot handling (sin cambios)
      final cur = _socketBloc.state;
      if (cur is SocketDriverPositionsUpdated) {
        final drivers = cur.drivers;
        final assigned = state.clientRequestResponse?.idDriver?.toString();
        if (assigned != null && drivers.containsKey(assigned)) {
          final pos = drivers[assigned];
          add(
            SocketDriverPositionUpdated(assigned, pos!.latitude, pos.longitude),
          );
        }
      }
    } catch (e) {
      // ignore
    }
  }

  /// Preload driver icon once.
  Future<void> _prepareDriverIcon() async {
    try {
      final iconRes = await _geolocatorUseCases.createMarkerUseCase(
        'assets/img/car-placeholder.png',
      );
      _driverIcon = iconRes.fold((l) => null, (r) => r);
    } catch (_) {
      _driverIcon = null;
    }
  }

  Future<void> _onGetClientRequestById(
    GetClientRequestById event,
    Emitter<ClientMapTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final response = await _clientRequestUsecases.getClientRequestByIdUseCase(
      event.idClientRequest,
    );
    response.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (fetchedRequest) {
        final origin = LatLng(
          fetchedRequest.pickupPosition.lat,
          fetchedRequest.pickupPosition.lng,
        );
        final destination = LatLng(
          fetchedRequest.destinationPosition.lat,
          fetchedRequest.destinationPosition.lng,
        );

        // Keeping loader true until route drawing finishes.
        emit(
          state.copyWith(
            isLoading: true,
            clientRequestResponse: fetchedRequest,
            origin: origin,
            destination: destination,
            routeDrawn: false,
            routePhases: RoutePhases.created,
            errorMessage: null,
          ),
        );
        try {
          // ask socket to listen to the trip channel
          debugPrint('------------ fetchedRequest.id: ${fetchedRequest.id}');

          // suscribir posiciones (usa idClient)
          _socketBloc
            ..add(
              ListenTripDriverPositionChannel(
                fetchedRequest.idClient.toString(),
              ),
            )
            // suscribir cambios de estado del viaje (usa id del request)
            ..add(ListenTripStatusChannel(fetchedRequest.id.toString()));
        } catch (e) {
          debugPrint('Error requesting trip channel listen: $e');
        }

        LatLng? socketDriverPos;
        try {
          final blocState = _socketBloc.state;
          if (blocState is SocketDriverPositionsUpdated) {
            final assigned = fetchedRequest.idDriver?.toString();
            if (assigned != null && blocState.drivers.containsKey(assigned)) {
              final pos = blocState.drivers[assigned];
              if (pos != null) {
                socketDriverPos = LatLng(pos.latitude, pos.longitude);
              }
            }
          }
        } catch (_) {}

        // Choose the best origin candidate
        final routeOrigin =
            socketDriverPos ??
            _lastPositionSent ??
            state.driverMarker?.position ??
            origin;

        // If origin (driver) and pickup are not basically the same and we
        // haven't drawn the route yet,
        // request route drawing once. _isDrawingRoute protects against
        //concurrent double calls.
        if (!approxSameLatLng(routeOrigin, origin)) {
          // draw once if not drawn already
          if (!state.routeDrawn) {
            _isDrawingRoute = false; // asegurar
            // setea fase ON_THE_WAY antes de enviar evento a dibujar
            emit(state.copyWith(routePhases: RoutePhases.onTheWay));
            add(DrawRouteForTrip(origin: routeOrigin, destination: origin));
          }
        }
      },
    );
  }

  Future<void> _onDrawRouteForTrip(
    DrawRouteForTrip event,
    Emitter<ClientMapTripState> emit,
  ) async {
    if (approxSameLatLng(event.origin, event.destination, metersThreshold: 2)) {
      emit(state.copyWith(isLoading: false));
      _isDrawingRoute = false;
      return;
    }
    emit(state.copyWith(isLoading: true, polylines: {}));

    try {
      final timeResult = await _clientRequestUsecases
          .getTimeAndDistanceValuesUsecase(
            TimeAndDistanceParams(
              originLat: event.origin.latitude,
              originLng: event.origin.longitude,
              destinationLat: event.destination.latitude,
              destinationLng: event.destination.longitude,
            ),
          );

      final polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);
      final request = RoutesApiRequest(
        origin: PointLatLng(event.origin.latitude, event.origin.longitude),
        destination: PointLatLng(
          event.destination.latitude,
          event.destination.longitude,
        ),
        routingPreference: RoutingPreference.trafficAware,
      );

      final response = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: request,
      );

      if (response.routes.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'No route found'));
        return;
      }
      final route = response.routes.first;
      final latLngPoints = (route.polylinePoints ?? [])
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      // elegir id base en función de la fase actual
      final idName = switch (state.routePhases) {
        RoutePhases.created => 'route_driver_to_pickup',
        RoutePhases.onTheWay => 'route_driver_to_pickup',
        RoutePhases.travelling => 'route_pickup_to_destination',
        _ => 'route',
      };

      final polyline = Polyline(
        polylineId: PolylineId(idName),
        width: 5,
        color: Colors.blue,
        points: latLngPoints,
      );

      final newPolys = {...state.polylines, polyline.polylineId: polyline};

      final phase = (state.routePhases == RoutePhases.created)
          ? RoutePhases.onTheWay
          : state.routePhases;

      // time/distance fallback handling
      var distanceKm = 0.0;
      var durationMinutes = 0;
      TimeAndDistanceValuesEntity? timeAndDistanceValues;

      timeResult.fold(
        (failure) {
          distanceKm = (route.distanceMeters ?? 0) / 1000;
          durationMinutes = ((route.duration ?? 0) / 60).round();
        },
        (val) {
          timeAndDistanceValues = val;
          distanceKm = val.distance.value;
          durationMinutes = val.duration.value.round();
        },
      );

      final seconds = durationMinutes * 60;

      emit(
        state.copyWith(
          isLoading: false,
          polylines: newPolys,
          timeAndDistanceValues: timeAndDistanceValues,
          distanceKm: distanceKm,
          estimatedTripDurationSeconds: seconds,
          routeDrawn: true,
          routePhases: phase,
          errorMessage: null,
        ),
      );

      add(const StartLocalEtaCountdown());
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error drawing route: $e',
        ),
      );
    } finally {
      _isDrawingRoute = false;
    }
  }

  Future<void> _onSocketDriverPositionUpdated(
    SocketDriverPositionUpdated event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final newPos = LatLng(event.lat, event.lng);
    debugPrint(
      '[ClientMap] _onSocketDriverPositionUpdated -> id=${event.idSocket} lat=${event.lat} lng=${event.lng}',
    );

    // Cache last position
    _lastPositionSent = newPos;

    // Ensure icon is read
    if (_driverIcon == null) {
      await _prepareDriverIcon();
    }

    final marker = Marker(
      markerId: const MarkerId('driver_marker'),
      position: newPos,
      infoWindow: const InfoWindow(title: 'Driver', snippet: 'Assigned driver'),
      icon: _driverIcon ?? BitmapDescriptor.defaultMarker,
    );

    emit(state.copyWith(driverMarker: marker));
    debugPrint(
      '[ClientMap] emitted driverMarker -> markerId=${marker.markerId.value} pos=${marker.position}',
    );

    // If we haven't drawn the driver->pickup route yet, draw it once.
    if (state.origin != null && !state.routeDrawn && !_isDrawingRoute) {
      _isDrawingRoute = true;
      emit(state.copyWith(routePhases: RoutePhases.onTheWay));
      add(DrawRouteForTrip(origin: newPos, destination: state.origin!));
    }
  }

  Future<void> _onTripStatusReceivedFromSocket(
    TripStatusReceivedFromSocket event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final status = event.status.toUpperCase();
    debugPrint(
      '[ClientMap][_onTripStatusReceivedFromSocket] status=$status, currentRequestId=${state.clientRequestResponse?.id}',
    );

    final receivedPhase =
        routePhaseFromServerString(status) ?? state.routePhases;
    final updatedEntity = state.clientRequestResponse?.copyWith(status: status);

    // update entity + phase in one emit
    emit(
      state.copyWith(
        clientRequestResponse: updatedEntity,
        routePhases: receivedPhase,
      ),
    );

    // Act based on the canonical phase (mirrors Driver behaviour)
    if (receivedPhase == RoutePhases.onTheWay) {
      debugPrint(
        '[ClientMap] received TRAVELLING — requesting draw pickup->destination',
      );
      // attempt to draw driver -> pickup using cached driver pos
      final driverPos = state.driverMarker?.position ?? _lastPositionSent;
      if (driverPos != null && state.origin != null && !_isDrawingRoute) {
        _isDrawingRoute = true;
        add(DrawRouteForTrip(origin: driverPos, destination: state.origin!));
      } else {
        debugPrint(
          '[ClientMap] cannot draw travelling route origin=${state.origin} dest=${state.destination} _isDrawingRoute=$_isDrawingRoute',
        );
      }
      return;
    }

    if (receivedPhase == RoutePhases.arrived) {
      debugPrint('[ClientMap] received ARRIVED');
      emit(state.copyWith(estimatedTripDurationSeconds: 0));
      add(const StopLocalEtaCountdown());
      return;
    }

    if (receivedPhase == RoutePhases.travelling) {
      debugPrint('[ClientMap] received TRAVELLING');
      // Clear previous driver->pickup and draw pickup->destination
      // set phase to travelling before requesting draw
      emit(state.copyWith(routePhases: RoutePhases.travelling));
      if (state.origin != null &&
          state.destination != null &&
          !_isDrawingRoute) {
        _isDrawingRoute = true;
        add(
          DrawRouteForTrip(
            origin: state.origin!,
            destination: state.destination!,
          ),
        );
      } else {
        debugPrint(
          '[ClientMap] cannot draw travelling route (origin/dest null or already drawing)',
        );
      }
      return;
    }

    if (receivedPhase == RoutePhases.canceled ||
        receivedPhase == RoutePhases.finished) {
      debugPrint('[ClientMap] received FINISHED/CANCELLED');
      add(const StopLocalEtaCountdown());
      add(
        const StopLocalEtaCountdown(),
      ); // safe guard (no-op if already stopped)
      // reset route UI
      emit(
        state.copyWith(
          routeDrawn: false,
          polylines: {},
          routePhases: RoutePhases.canceled,
        ),
      );
      return;
    }

    debugPrint('[ClientMap] status not handled explicitly: $status');
  }

  // ETA handling strategy functionality (prototype):
  // 1) We request a real ETA (Google / backend) once when the route is created.
  // 2) We start a local countdown (seconds)
  // from that ETA and show it in the UI.
  // 3) The local countdown updates every second
  // to give the impression  of a live ETA without calling
  // the routing API repeatedly.
  // --this provides a realistic UX while avoiding Google
  // quota consumption during development. --
  Future<void> _onStartLocalEtaCountdown(
    StartLocalEtaCountdown event,
    Emitter<ClientMapTripState> emit,
  ) async {
    if (_localEstimatedTimer != null && _localEstimatedTimer!.isActive) return;

    // start periodic timer that dispatches EtaTick events to the bloc
    _localEstimatedTimer = Timer.periodic(_localTick, (_) {
      // dispatch event so the Bloc handles state update inside handler
      add(const EtaTick());
    });
  }

  Future<void> _onStopLocalEtaCountdown(
    StopLocalEtaCountdown event,
    Emitter<ClientMapTripState> emit,
  ) async {
    _localEstimatedTimer?.cancel();
    _localEstimatedTimer = null;
  }

  Future<void> _onEtaTick(
    EtaTick event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final secs = state.estimatedTripDurationSeconds ?? 0;
    if (secs <= 0) {
      // reached zero: stop timer and update UI message (we set 0 explicitly)
      emit(state.copyWith(estimatedTripDurationSeconds: 0));
      // stop timer via event (so timer is cancelled in the handler)
      add(const StopLocalEtaCountdown());
      return;
    }
    final newSecs = secs - _localTick.inSeconds;
    emit(state.copyWith(estimatedTripDurationSeconds: newSecs));
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _localEstimatedTimer?.cancel();
    return super.close();
  }
}
