//lint:ignore-file for setting errorMSG back to null on succes is required
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_usecase.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/geo_utils.dart';
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

  void _listenToSocket() {
    // Listen to socketBloc stream and convert relevant
    // states into internal events.
    try {
      _socketSub = _socketBloc.stream.listen((socketState) {
        // If socket provides a drivers snapshot (map),
        // extract assigned driver's pos
        if (socketState is SocketDriverPositionsUpdated) {
          final assigned = state.clientRequestResponse?.idDriver?.toString();
          if (assigned != null && socketState.drivers.containsKey(assigned)) {
            final pos = socketState.drivers[assigned];
            if (pos != null) {
              // normalize into the same internal event
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

        // TODO: replace `SocketDriverArrivedState with the real state class once the api call is finished

        // If socket gives a trip-specific driver position update,
        // handle it similarly
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

      // En caso de que socket tenga ya snapshot
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
            routePhase: RoutePhase.none,
            errorMessage: null,
          ),
        );
        try {
          // ask socket to listen to the trip channel
          _socketBloc.add(
            ListenTripDriverPositionChannel(fetchedRequest.idClient.toString()),
          );
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
        if (!approxSameLatLng(routeOrigin, origin) &&
            !state.routeDrawn &&
            !_isDrawingRoute) {
          _isDrawingRoute = true;
          // Start drawing route
          add(DrawRouteForTrip(origin: routeOrigin, destination: origin));
        }
      },
    );
  }

  Future<void> _onDrawRouteForTrip(
    DrawRouteForTrip event,
    Emitter<ClientMapTripState> emit,
  ) async {
    // If start and end are effectively the same (tiny distance), don't draw.
    if (approxSameLatLng(event.origin, event.destination, metersThreshold: 2)) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    emit(state.copyWith(isLoading: true));

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

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        width: 5,
        color: Colors.blue,
        points: latLngPoints,
      );

      final newPolys = {...state.polylines, polyline.polylineId: polyline};

      var distanceKm = 0.0;
      var durationMinutes = 0;
      TimeAndDistanceValuesEntity? timeAndDistanceValues;

      timeResult.fold(
        (failure) {
          // fallback using route metrics if available
          distanceKm = (route.distanceMeters ?? 0) / 1000;
          durationMinutes = ((route.duration ?? 0) / 60).round();
        },
        (val) {
          timeAndDistanceValues = val;
          distanceKm = val.distance.value;
          durationMinutes = val.duration.value.round();
        },
      );

      final phase = (state.routePhase == RoutePhase.none)
          ? RoutePhase.driverToPickup
          : state.routePhase;

      emit(
        state.copyWith(
          isLoading: false,
          polylines: newPolys,
          timeAndDistanceValues: timeAndDistanceValues,
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          routeDrawn: true,
          routePhase: phase,
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
    }
  }

  Future<void> _onSocketDriverPositionUpdated(
    SocketDriverPositionUpdated event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final newPos = LatLng(event.lat, event.lng);

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

    // If we haven't drawn the driver->pickup route yet, draw it once.
    if (state.origin != null && !state.routeDrawn && !_isDrawingRoute) {
      _isDrawingRoute = true;
      add(DrawRouteForTrip(origin: newPos, destination: state.origin!));
    }
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }
}
