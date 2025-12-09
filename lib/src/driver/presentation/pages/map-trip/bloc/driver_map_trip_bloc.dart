//lint:ignore-file for setting errorMSG back to null on succes is required
// ignore_for_file: avoid_redundant_argument_values
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_use_cases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/update_trip_status_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/geo_utils.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/route_phases.dart';
import 'package:indriver_uber_clone/secrets.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

part 'driver_map_trip_event.dart';
part 'driver_map_trip_state.dart';

class DriverMapTripBloc extends Bloc<DriverMapTripEvent, DriverMapTripState> {
  DriverMapTripBloc(
    this._clientRequestsUsecases,
    this._geolocatorUseCases,
    this._socketBloc,
  ) : super(const DriverMapTripState()) {
    on<GetClientRequestById>(_onGetClientRequestById);
    on<DrawRouteForTrip>(_onDrawRouteForTrip);
    on<DriverLocationUpdated>(_onDriverLocationUpdated);
    on<UpdateTripStatus>(_onUpdateTripStatus);
    on<TripStatusReceivedFromSocketDriver>(
      _onTripStatusReceivedFromSocketDriver,
    );

    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<StartTrip>(_onStartTrip);
    on<ResetRoute>(_onResetRoute);

    _listenToSocket();
    _prepareDriverIcon(); // preload icon
  }

  // dependencies
  final ClientRequestsUsecases _clientRequestsUsecases;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;

  // internal state / caches
  LatLng? _lastDriverPosition;
  StreamSubscription<Position>? _positionSubscription;
  BitmapDescriptor? _driverIcon;
  bool _isDrawingRoute = false;

  // --------------------
  // socket listener
  // --------------------
  void _listenToSocket() {
    try {
      _socketBloc.stream.listen((socketState) {
        if (socketState is SocketTripStatusUpdated) {
          final requestIdFromSocket = socketState.idClientRequest;
          final statusFromSocket = socketState.status;
          final localRequestId = state.clientRequestResponse?.id.toString();
          if (localRequestId != null && localRequestId == requestIdFromSocket) {
            add(TripStatusReceivedFromSocketDriver(status: statusFromSocket));
          }
        }
        // you can add other socket message handling here when needed
      });
    } catch (e) {
      debugPrint('DriverMapTripBloc: error listening to socket -> $e');
    }
  }

  // --------------------
  // helpers
  // --------------------
  Future<void> _prepareDriverIcon() async {
    try {
      final iconResult = await _geolocatorUseCases.createMarkerUseCase(
        'assets/img/car-placeholder.png',
      );
      _driverIcon = iconResult.fold((l) => null, (r) => r);
    } catch (_) {
      _driverIcon = null;
    }
  }

  // --------------------
  // event handlers
  // --------------------
  Future<void> _onGetClientRequestById(
    GetClientRequestById event,
    Emitter<DriverMapTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _clientRequestsUsecases.getClientRequestByIdUseCase(
      event.idClientRequest,
    );
    await result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (fetchedRequest) async {
        final pickupLatLng = LatLng(
          fetchedRequest.pickupPosition.lat,
          fetchedRequest.pickupPosition.lng,
        );
        final destinationLatLng = LatLng(
          fetchedRequest.destinationPosition.lat,
          fetchedRequest.destinationPosition.lng,
        );

        final initialPhase =
            routePhaseFromServerString(fetchedRequest.status) ??
            RoutePhases.created;

        emit(
          state.copyWith(
            isLoading: true, // keep loader until route drawn
            clientRequestResponse: fetchedRequest,
            origin: pickupLatLng,
            destination: destinationLatLng,
            routeDrawn: false,
            routePhases: initialPhase,
            errorMessage: null,
          ),
        );

        // Listen to trip channel in socket
        // (server will emit driver positions for this trip)
        try {
          _socketBloc.add(
            ListenTripDriverPositionChannel(fetchedRequest.id.toString()),
          );
        } catch (e) {
          debugPrint('DriverMapTripBloc: error adding socket listen -> $e');
        }

        // Try to use cached driver position from socket state's snapshot
        LatLng? socketDriverPosition;
        try {
          final socketState = _socketBloc.state;
          if (socketState is SocketDriverPositionsUpdated) {
            final assignedDriverId = fetchedRequest.idDriver?.toString();
            if (assignedDriverId != null &&
                socketState.drivers.containsKey(assignedDriverId)) {
              final pos = socketState.drivers[assignedDriverId];
              if (pos != null) {
                socketDriverPosition = LatLng(pos.latitude, pos.longitude);
              }
            }
          }
        } catch (_) {}

        final routeOrigin =
            socketDriverPosition ??
            _lastDriverPosition ??
            state.driverMarker?.position ??
            pickupLatLng;

        // If routeOrigin equals pickup,
        //postpone drawing until we get an updated driver location.
        if (!approxSameLatLng(routeOrigin, pickupLatLng)) {
          if (!state.routeDrawn && !_isDrawingRoute) {
            _isDrawingRoute = true;
            add(
              DrawRouteForTrip(origin: routeOrigin, destination: pickupLatLng),
            );
          }
        }

        // Start continuous location tracking for
        // driver (will send positions via socket)
        add(StartLocationTracking());
      },
    );
  }

  Future<void> _onDrawRouteForTrip(
    DrawRouteForTrip event,
    Emitter<DriverMapTripState> emit,
  ) async {
    // Skip trivial routes
    if (approxSameLatLng(event.origin, event.destination, metersThreshold: 2)) {
      emit(state.copyWith(isLoading: false));
      _isDrawingRoute = false;
      return;
    }

    emit(state.copyWith(isLoading: true, polylines: {}));

    try {
      final polylineService = PolylinePoints(apiKey: googleMapsApiKey);
      final request = RoutesApiRequest(
        origin: PointLatLng(event.origin.latitude, event.origin.longitude),
        destination: PointLatLng(
          event.destination.latitude,
          event.destination.longitude,
        ),
        routingPreference: RoutingPreference.trafficAware,
      );

      final response = await polylineService.getRouteBetweenCoordinatesV2(
        request: request,
      );
      if (response.routes.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'No route found'));
        _isDrawingRoute = false;
        return;
      }

      final route = response.routes.first;
      final points = (route.polylinePoints ?? [])
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      final polylineIdName = switch (state.routePhases) {
        RoutePhases.created => 'route_driver_to_pickup',
        RoutePhases.onTheWay => 'route_driver_to_pickup',
        RoutePhases.travelling => 'route_pickup_to_destination',
        _ => 'route',
      };

      final polyline = Polyline(
        polylineId: PolylineId(polylineIdName),
        points: points,
        width: 5,
        color: Colors.blue,
      );

      final updatedPolylines = {
        ...state.polylines,
        polyline.polylineId: polyline,
      };

      final nextPhase = (state.routePhases == RoutePhases.created)
          ? RoutePhases.onTheWay
          : state.routePhases;

      emit(
        state.copyWith(
          isLoading: false,
          polylines: updatedPolylines,
          routeDrawn: true,
          routePhases: nextPhase,
          errorMessage: null,
        ),
      );
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

  Future<void> _onDriverLocationUpdated(
    DriverLocationUpdated event,
    Emitter<DriverMapTripState> emit,
  ) async {
    // ensure icon is ready
    if (_driverIcon == null) {
      await _prepareDriverIcon();
    }

    final icon = _driverIcon;
    if (icon == null) {
      debugPrint(
        'DriverMapTripBloc: driver icon not available,'
        ' skipping marker update',
      );

      return;
    }

    final markerResult = await _geolocatorUseCases.getMarkerUseCase(
      'driver_self',
      'Driver',
      'Current location',
      LatLng(event.lat, event.lng),
      icon,
    );

    final driverMarker = markerResult.fold((l) => null, (r) => r);
    if (driverMarker == null) return;

    final newPosition = LatLng(event.lat, event.lng);
    _lastDriverPosition = newPosition;

    // send position to server (socket) if we have an active trip
    if (state.clientRequestResponse != null) {
      _socketBloc.add(
        SendTripDriverPositionRequested(
          idClient: state.clientRequestResponse!.idClient,
          lat: event.lat,
          lng: event.lng,
        ),
      );
    }

    emit(state.copyWith(driverMarker: driverMarker));

    // draw driver-> pickup if we still haven't drawn it
    if (state.origin != null && !state.routeDrawn && !_isDrawingRoute) {
      _isDrawingRoute = true;
      add(DrawRouteForTrip(origin: newPosition, destination: state.origin!));
    }
  }

  Future<void> _onUpdateTripStatus(
    UpdateTripStatus event,
    Emitter<DriverMapTripState> emit,
  ) async {
    if (state.clientRequestResponse == null) return;

    final statusString = event.status.toServerString();
    final response = await _clientRequestsUsecases.updateTripStatusUseCase(
      UpdateTripStatusParams(
        idClientRequest: state.clientRequestResponse!.id,
        status: statusString,
      ),
    );

    await response.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (success) async {
        final updatedEntity = state.clientRequestResponse?.copyWith(
          status: statusString,
        );
        final newPhase =
            routePhaseFromServerString(statusString) ?? state.routePhases;

        emit(
          state.copyWith(
            clientRequestResponse: updatedEntity,
            routePhases: newPhase,
            errorMessage: null,
          ),
        );

        // local actions based on new phase
        if (newPhase == RoutePhases.travelling) {
          add(const StartTrip());
        } else if (newPhase == RoutePhases.canceled ||
            newPhase == RoutePhases.finished) {
          add(const ResetRoute());
        }

        // notify server via socket so other clients receive update
        _socketBloc.add(
          SendTripStatusRequested(
            idClientRequest: state.clientRequestResponse!.id.toString(),
            status: statusString,
          ),
        );
      },
    );
  }

  Future<void> _onTripStatusReceivedFromSocketDriver(
    TripStatusReceivedFromSocketDriver event,
    Emitter<DriverMapTripState> emit,
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

    if (receivedPhase == RoutePhases.travelling) {
      add(StartLocationTracking());
      add(const StartTrip());
      return;
    }

    if (receivedPhase == RoutePhases.canceled ||
        receivedPhase == RoutePhases.finished) {
      add(const ResetRoute());
      return;
    }
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<DriverMapTripState> emit,
  ) async {
    debugPrint('DriverMapTripBloc: starting location tracking stream');

    try {
      await _positionSubscription?.cancel();
      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((position) {
            add(DriverLocationUpdated(position.latitude, position.longitude));
          });
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error starting location tracking: $e',
        ),
      );
    }
  }

  Future<void> _onStopLocationTracking(
    StopLocationTracking event,
    Emitter<DriverMapTripState> emit,
  ) async {
    debugPrint('DriverMapTripBloc: stopping location tracking');
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<DriverMapTripState> emit,
  ) async {
    final current = state;
    if (current.clientRequestResponse == null) return;

    emit(
      current.copyWith(
        polylines: {},
        routeDrawn: false,
        routePhases: RoutePhases.travelling,
        errorMessage: null,
      ),
    );

    final pickup = current.origin;
    final destination = current.destination;
    if (pickup != null && destination != null) {
      add(DrawRouteForTrip(origin: pickup, destination: destination));
    }
  }

  Future<void> _onResetRoute(
    ResetRoute event,
    Emitter<DriverMapTripState> emit,
  ) async {
    emit(
      state.copyWith(
        polylines: {},
        routeDrawn: false,
        routePhases: RoutePhases.canceled,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
