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
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/utils/map_trip_utils.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

part 'client_map_trip_event.dart';
part 'client_map_trip_state.dart';

class ClientMapTripBloc extends Bloc<ClientMapTripEvent, ClientMapTripState> {
  ClientMapTripBloc(
    this._clientRequestUsecases,
    this._geolocatorUseCases,
    this._socketBloc,
  ) : super(const ClientMapTripState()) {
    // public events
    on<GetClientRequestById>(_onGetClientRequestById);
    on<DrawRouteForTrip>(_onDrawRouteForTrip);
    on<SocketDriverPositionUpdated>(_onSocketDriverPositionUpdated);
    on<TripStatusReceivedFromSocket>(_onTripStatusReceivedFromSocket);

    // ETA timer
    on<StartLocalEtaCountdown>(_onStartLocalEtaCountdown);
    on<StopLocalEtaCountdown>(_onStopLocalEtaCountdown);
    on<EtaTick>(_onEtaTick);

    // initialize listeners / preload resources
    _listenToSocket();
    prepareDriverIcon();
  }

  // dependencies
  final ClientRequestsUsecases _clientRequestUsecases;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;

  // internal state
  LatLng? _lastDriverPosition;
  StreamSubscription<dynamic>? _socketSubscription;
  BitmapDescriptor? _driverIcon;
  bool _isDrawingRoute = false;

  Timer? _localEtaTimer;
  final Duration _localTick = const Duration(seconds: 1);

  // --------------------
  // socket listeners
  // --------------------
  void _listenToSocket() {
    try {
      _socketSubscription = _socketBloc.stream.listen((socketState) {
        // global snapshot update
        if (socketState is SocketDriverPositionsUpdated) {
          final assignedDriverId = state.clientRequestResponse?.idDriver
              ?.toString();
          if (assignedDriverId != null &&
              socketState.drivers.containsKey(assignedDriverId)) {
            final pos = socketState.drivers[assignedDriverId];
            if (pos != null) {
              add(
                SocketDriverPositionUpdated(
                  assignedDriverId,
                  pos.latitude,
                  pos.longitude,
                ),
              );
            }
          }
          return;
        }

        // trip status update
        if (socketState is SocketTripStatusUpdated) {
          final idFromSocket = socketState.idClientRequest;
          final localRequestId = state.clientRequestResponse?.id.toString();
          if (localRequestId != null && localRequestId == idFromSocket) {
            add(TripStatusReceivedFromSocket(status: socketState.status));
          }
          return;
        }

        // per-trip driver position update
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

      // if socket bloc already contains a snapshot,
      // attempt to extract assigned driver position
      final currentSocketState = _socketBloc.state;
      if (currentSocketState is SocketDriverPositionsUpdated) {
        final assigned = state.clientRequestResponse?.idDriver?.toString();
        if (assigned != null &&
            currentSocketState.drivers.containsKey(assigned)) {
          final position = currentSocketState.drivers[assigned];
          if (position != null) {
            add(
              SocketDriverPositionUpdated(
                assigned,
                position.latitude,
                position.longitude,
              ),
            );
          }
        }
      }
    } catch (_) {
      // best-effort listener: swallow errors
    }
  }

  // --------------------
  // resources / helpers
  // --------------------
  Future<void> prepareDriverIcon() async {
    try {
      final iconRes = await _geolocatorUseCases.createMarkerUseCase(
        'assets/img/car-placeholder.png',
      );
      _driverIcon = iconRes.fold((l) => null, (r) => r);
    } catch (_) {
      _driverIcon = null;
    }
  }

  // --------------------
  // public event handlers
  // --------------------
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

        // subscribe to socket channels
        try {
          _socketBloc
            ..add(
              ListenTripDriverPositionChannel(
                fetchedRequest.idClient.toString(),
              ),
            )
            ..add(ListenTripStatusChannel(fetchedRequest.id.toString()));
        } catch (_) {}

        // attempt to get a cached driver position from socket state
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

        final routeOrigin =
            socketDriverPos ??
            _lastDriverPosition ??
            state.driverMarker?.position ??
            origin;

        if (!approxSameLatLng(routeOrigin, origin)) {
          if (!state.routeDrawn) {
            _isDrawingRoute = false;
            emit(state.copyWith(routePhases: RoutePhases.onTheWay));
            add(DrawRouteForTrip(origin: routeOrigin, destination: origin));
          }
        } else {}
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
      final estimatedSecondsFromRequest = extractEstimatedSecondsFromRequest(
        state.clientRequestResponse,
      );
      TimeAndDistanceValuesEntity? timeAndDistance;
      var durationSecondsFromTimeResult = 0;

      if (estimatedSecondsFromRequest != null) {
        durationSecondsFromTimeResult = estimatedSecondsFromRequest;
      } else {
        final timeResult = await _clientRequestUsecases
            .getTimeAndDistanceValuesUsecase(
              TimeAndDistanceParams(
                originLat: event.origin.latitude,
                originLng: event.origin.longitude,
                destinationLat: event.destination.latitude,
                destinationLng: event.destination.longitude,
              ),
            );

        timeResult.fold(
          (failure) {
            // ignore failure; will fallback to route response values
          },
          (val) {
            timeAndDistance = val;
            durationSecondsFromTimeResult = (val.duration.value * 60).round();
          },
        );
      }

      // gets polylines
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

      // duration/distance fallback logic
      var distanceKm = 0.0;
      var durationMinutes = 0;

      if (timeAndDistance?.duration != null &&
          timeAndDistance?.distance != null) {
        distanceKm = timeAndDistance!.distance.value;
        durationMinutes = timeAndDistance!.duration.value.round();
      } else {
        distanceKm = (route.distanceMeters ?? 0) / 1000;
        durationMinutes = ((route.duration ?? 0) / 60).round();
        if (durationSecondsFromTimeResult > 0) {
          durationMinutes = (durationSecondsFromTimeResult / 60).round();
        }
      }

      final newPhase = (state.routePhases == RoutePhases.created)
          ? RoutePhases.onTheWay
          : state.routePhases;
      final seconds = durationMinutes * 60;

      emit(
        state.copyWith(
          isLoading: false,
          polylines: newPolys,
          timeAndDistanceValues: timeAndDistance,
          distanceKm: distanceKm,
          estimatedTripDurationSeconds: seconds,
          routeDrawn: true,
          routePhases: newPhase,
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

    // cache last driver position
    _lastDriverPosition = newPos;

    // ensure icon prepared
    if (_driverIcon == null) {
      await prepareDriverIcon();
    }

    final marker = Marker(
      markerId: const MarkerId('driver_marker'),
      position: newPos,
      infoWindow: const InfoWindow(title: 'Driver', snippet: 'Assigned driver'),
      icon: _driverIcon ?? BitmapDescriptor.defaultMarker,
    );

    emit(state.copyWith(driverMarker: marker));

    // draw driver->pickup if needed
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
    final receivedPhase =
        routePhaseFromServerString(status) ?? state.routePhases;
    final updatedEntity = state.clientRequestResponse?.copyWith(status: status);

    emit(
      state.copyWith(
        clientRequestResponse: updatedEntity,
        routePhases: receivedPhase,
      ),
    );

    if (receivedPhase == RoutePhases.onTheWay) {
      final driverPos = state.driverMarker?.position ?? _lastDriverPosition;
      if (driverPos != null && state.origin != null && !_isDrawingRoute) {
        _isDrawingRoute = true;
        add(DrawRouteForTrip(origin: driverPos, destination: state.origin!));
      }
      return;
    }

    if (receivedPhase == RoutePhases.arrived) {
      emit(state.copyWith(estimatedTripDurationSeconds: 0));
      add(const StopLocalEtaCountdown());
      return;
    }

    if (receivedPhase == RoutePhases.travelling) {
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
      }
      return;
    }

    if (receivedPhase == RoutePhases.canceled ||
        receivedPhase == RoutePhases.finished) {
      add(const StopLocalEtaCountdown());
      emit(
        state.copyWith(
          routeDrawn: false,
          polylines: {},
          routePhases: RoutePhases.canceled,
        ),
      );
      return;
    }
  }

  // --------------------
  // ETA timer handlers
  // --------------------
  Future<void> _onStartLocalEtaCountdown(
    StartLocalEtaCountdown event,
    Emitter<ClientMapTripState> emit,
  ) async {
    if (_localEtaTimer != null && _localEtaTimer!.isActive) return;
    _localEtaTimer = Timer.periodic(_localTick, (_) => add(const EtaTick()));
  }

  Future<void> _onStopLocalEtaCountdown(
    StopLocalEtaCountdown event,
    Emitter<ClientMapTripState> emit,
  ) async {
    _localEtaTimer?.cancel();
    _localEtaTimer = null;
  }

  Future<void> _onEtaTick(
    EtaTick event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final secs = state.estimatedTripDurationSeconds ?? 0;
    if (secs <= 0) {
      emit(state.copyWith(estimatedTripDurationSeconds: 0));
      add(const StopLocalEtaCountdown());
      return;
    }
    final newSecs = secs - _localTick.inSeconds;
    emit(state.copyWith(estimatedTripDurationSeconds: newSecs));
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    _localEtaTimer?.cancel();
    return super.close();
  }
}
