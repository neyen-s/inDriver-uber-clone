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
  }

  final ClientRequestsUsecases _clientRequestsUsecases;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;

  LatLng? _lastPositionSent;

  StreamSubscription<Position>? _positionSub;

  void _listenToSocket() {
    try {
      _socketBloc.stream.listen((socketState) {
        if (socketState is SocketTripStatusUpdated) {
          final id = socketState.idClientRequest;
          final status = socketState.status;
          if (state.clientRequestResponse?.id.toString() == id) {
            add(TripStatusReceivedFromSocketDriver(status: status));
          }
        }
      });
    } catch (_) {}
  }

  /// When we ask for a client request, we keep isLoading true until the
  /// route is actually drawn (or an error occurs). We try to use known
  /// driver position from socket snapshot; if it's effectively the same
  /// as pickup we postpone drawing until the driver's first location update.
  Future<void> _onGetClientRequestById(
    GetClientRequestById event,
    Emitter<DriverMapTripState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _clientRequestsUsecases.getClientRequestByIdUseCase(
      event.idClientRequest,
    );

    await res.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (fetched) async {
        final origin = LatLng(
          fetched.pickupPosition.lat,
          fetched.pickupPosition.lng,
        );
        final destination = LatLng(
          fetched.destinationPosition.lat,
          fetched.destinationPosition.lng,
        );

        final initialPhase =
            routePhaseFromServerString(fetched.status) ?? RoutePhases.created;

        emit(
          state.copyWith(
            isLoading: true, // keep true until we draw or fail
            clientRequestResponse: fetched,
            origin: origin,
            destination: destination,
            routeDrawn: false,
            routePhases: initialPhase,
            errorMessage: null,
          ),
        );

        // Listens to trip channel in socket
        debugPrint('*********fetched.id.toString() ${fetched.id.toString()}');

        try {
          _socketBloc.add(
            ListenTripDriverPositionChannel(fetched.id.toString()),
          );
        } catch (e) {
          debugPrint('Error requesting trip channel listen: $e');
        }

        // Try to use snapshot driver position from socket (if available)
        LatLng? socketDriverPos;
        try {
          final blocState = _socketBloc.state;
          if (blocState is SocketDriverPositionsUpdated) {
            final assigned = fetched.idDriver?.toString();
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

        // If routeOrigin is basically the same as pickup, postpone drawing
        // until we receive a real driver location update
        // (avoid drawing pickup->pickup).
        if (approxSameLatLng(routeOrigin, origin)) {
          // do nothing here — loader stays until
          // driver position triggers drawing
        } else {
          // draw once if not drawn already
          if (!state.routeDrawn) {
            add(DrawRouteForTrip(origin: routeOrigin, destination: origin));
          }
        }
        add(StartLocationTracking());
      },
    );
  }

  /// Draw a route between two points. If route is trivial (same point), skip.
  Future<void> _onDrawRouteForTrip(
    DrawRouteForTrip event,
    Emitter<DriverMapTripState> emit,
  ) async {
    // skip trivial route (origin ~ destination)
    if (approxSameLatLng(event.origin, event.destination, metersThreshold: 2)) {
      emit(
        state.copyWith(isLoading: false),
      ); // route not drawable => hide loader
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
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
        points: latLngPoints,
        width: 5,
        color: Colors.blue,
      );

      final newPolys = {...state.polylines, polyline.polylineId: polyline};

      final phase = (state.routePhases == RoutePhases.created)
          ? RoutePhases.onTheWay
          : state.routePhases;

      emit(
        state.copyWith(
          isLoading: false,
          polylines: newPolys,
          routeDrawn: true,
          routePhases: phase,
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

  /// When a new driver location arrives, we update the marker and send it
  /// to the server (via socket). We draw the route only once: when origin
  /// (pickup) is known and route hasn't been drawn yet.
  Future<void> _onDriverLocationUpdated(
    DriverLocationUpdated event,
    Emitter<DriverMapTripState> emit,
  ) async {
    final iconRes = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );
    final icon = iconRes.fold((l) => null, (r) => r);
    if (icon == null) return;

    final markerRes = await _geolocatorUseCases.getMarkerUseCase(
      'driver_self',
      'Conductor',
      'Ubicación actual',
      LatLng(event.lat, event.lng),
      icon,
    );
    final driverMarker = markerRes.fold((l) => null, (r) => r);
    if (driverMarker == null) return;

    final newPos = LatLng(event.lat, event.lng);
    _lastPositionSent = newPos;
    debugPrint(
      '*** DriverBloc: sending trip pos to socket -> lat=${event.lat}, lng=${event.lng}',
    );

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

    if (state.origin != null && !state.routeDrawn) {
      add(DrawRouteForTrip(origin: newPos, destination: state.origin!));
    }
  }

  Future<void> _onUpdateTripStatus(
    UpdateTripStatus event,
    Emitter<DriverMapTripState> emit,
  ) async {
    if (state.clientRequestResponse == null) return;

    final newStatusStr = event.status.toServerString();
    final response = await _clientRequestsUsecases.updateTripStatusUseCase(
      UpdateTripStatusParams(
        idClientRequest: state.clientRequestResponse!.id,
        status: newStatusStr,
      ),
    );

    await response.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (success) async {
        final updated = state.clientRequestResponse?.copyWith(
          status: newStatusStr,
        );
        final newPhase =
            routePhaseFromServerString(newStatusStr) ?? state.routePhases;
        emit(
          state.copyWith(
            clientRequestResponse: updated,
            routePhases: newPhase,
            errorMessage: null,
          ),
        );

        // Acciones inmediatas según la nueva fase (me anticipa a la reemisión por socket)
        if (newPhase == RoutePhases.travelling) {
          add(const StartTrip());
        } else if (newPhase == RoutePhases.arrived) {
          // add(StopLocationTracking());
        } else if (newPhase == RoutePhases.canceled ||
            newPhase == RoutePhases.finished) {
          add(const ResetRoute());
          //  add(StopLocationTracking());
        }

        // Notifica al socket para que el server reemita a otros clientes
        _socketBloc.add(
          SendTripStatusRequested(
            idClientRequest: state.clientRequestResponse!.id.toString(),
            status: newStatusStr,
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
    // update local entity
    final updated = state.clientRequestResponse?.copyWith(status: status);
    emit(
      state.copyWith(
        clientRequestResponse: updated,
        routePhases: receivedPhase,
      ),
    );

    if (receivedPhase == RoutePhases.travelling) {
      debugPrint('*** DriverBloc: received TRAVELLING -> StartTrip');
      add(StartLocationTracking());
      add(const StartTrip());
    } else if (receivedPhase == RoutePhases.arrived) {
      debugPrint('*** DriverBloc: received ARRIVED -> StopLocationTracking');
      //add(StopLocationTracking());
    } else if (receivedPhase == RoutePhases.canceled ||
        receivedPhase == RoutePhases.finished) {
      add(const ResetRoute());
      // add(StopLocationTracking());
    }
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<DriverMapTripState> emit,
  ) async {
    debugPrint('*** DriverBloc: StartLocationTracking -> creating stream');
    try {
      await _positionSub?.cancel();
      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((pos) {
            add(DriverLocationUpdated(pos.latitude, pos.longitude));
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
    debugPrint('*** DriverBloc: StopLocationTracking -> cancelling stream');

    await _positionSub?.cancel();
    _positionSub = null;
  }

  Future<void> _onStartTrip(
    StartTrip event,
    Emitter<DriverMapTripState> emit,
  ) async {
    final current = state;
    if (current.clientRequestResponse == null) return;
    debugPrint('*** DriverBloc: StartTrip -> drawing pickup->destination');

    emit(
      current.copyWith(
        polylines: {},
        routeDrawn: false,
        routePhases: RoutePhases.travelling,
        errorMessage: null,
      ),
    );

    final pickup = current.origin;
    final dest = current.destination;
    if (pickup != null && dest != null) {
      add(DrawRouteForTrip(origin: pickup, destination: dest));
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
    _positionSub?.cancel();
    return super.close();
  }
}
