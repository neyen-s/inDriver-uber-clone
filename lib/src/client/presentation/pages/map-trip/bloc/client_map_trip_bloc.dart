import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_usecase.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/secrets.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

part 'client_map_trip_event.dart';
part 'client_map_trip_state.dart';

class ClientMapTripBloc extends Bloc<ClientMapTripEvent, ClientMapTripState> {
  ClientMapTripBloc(
    this._clientRequestUsecases,
    this._geolocatorUseCases,
    this.socketBloc,
  ) : super(const ClientMapTripState()) {
    on<GetClientRequestById>(_onGetClientRequestById);
    on<DrawRouteForTrip>(_onDrawRouteForTrip);
    on<SocketDriverPositionUpdated>(_onSocketDriverPositionUpdated);

    _listenToSocket();
  }

  final ClientRequestsUsecases _clientRequestUsecases;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc socketBloc;

  StreamSubscription? _socketSub;

  void _listenToSocket() {
    // Escucha al socketBloc y cuando venga la posición del driver asignado
    try {
      _socketSub = socketBloc.stream.listen((socketState) {
        if (socketState is SocketDriverPositionsUpdated) {
          final drivers = socketState.drivers; // Map<String, LatLng-like>
          final assigned = state.clientRequestResponse?.idDriver?.toString();
          if (assigned != null && drivers.containsKey(assigned)) {
            //final pos = drivers[assigned];
            // pos.latitude / pos.longitude assumed
            /*             add(
              SocketDriverPositionUpdated(
                assigned,
                pos!.latitude,
                pos.longitude,
              ),
            ); */
          }
        }

        if (socketState is SocketTripDriverPositionUpdated) {
          // convertirlo a tu evento interno que crea/actualiza el marker del driver
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
      /*       socketBloc.add(
        ListenTripDriverPositionChannel(
          state.clientRequestResponse!.idClient.toString(),
        ),
      ); */
      // En caso de que socket tenga ya snapshot
      final cur = socketBloc.state;
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

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
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
        emit(
          state.copyWith(
            isLoading: false,
            clientRequestResponse: fetchedRequest,
            origin: origin,
            destination: destination,

            //Sets the errorMessage to null on success
            // ignore: avoid_redundant_argument_values
            errorMessage: null,
          ),
        );
        try {
          // pedimos que el socket escuche el canal trip_new_driver_position/{idClient}
          socketBloc.add(
            ListenTripDriverPositionChannel(fetchedRequest.idClient.toString()),
          );
        } catch (e) {
          // opcional: log
          debugPrint('Error requesting trip channel listen: $e');
        }
        // Start drawing route
        add(DrawRouteForTrip(origin: origin, destination: destination));
      },
    );
  }

  Future<void> _onDrawRouteForTrip(
    DrawRouteForTrip event,
    Emitter<ClientMapTripState> emit,
  ) async {
    final current = state;
    emit(current.copyWith(isLoading: true));

    try {
      // 1) Request time & distance values (use your usecase)
      final timeResult = await _clientRequestUsecases
          .getTimeAndDistanceValuesUsecase(
            TimeAndDistanceParams(
              originLat: event.origin.latitude,
              originLng: event.origin.longitude,
              destinationLat: event.destination.latitude,
              destinationLng: event.destination.longitude,
            ),
          );

      // 2) Get route geometry via PolylinePoints
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
        emit(
          current.copyWith(isLoading: false, errorMessage: 'No route found'),
        );
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

      Map<PolylineId, Polyline> newPolys = {
        ...current.polylines,
        polyline.polylineId: polyline,
      };

      double distanceKm = 0;
      int durationMinutes = 0;
      dynamic timeAndDistanceValues;

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

      emit(
        current.copyWith(
          isLoading: false,
          polylines: newPolys,
          timeAndDistanceValues: timeAndDistanceValues,
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
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
    final current = state;
    // Create icon + marker for driver
    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );
    final icon = iconResult.fold((l) => null, (r) => r);
    if (icon == null) return;

    final markerResult = await _geolocatorUseCases.getMarkerUseCase(
      event.idSocket,
      'Driver',
      'Assigned driver',
      LatLng(event.lat, event.lng),
      icon,
    );

    final marker = markerResult.fold((l) => null, (r) => r);
    if (marker == null) return;

    emit(current.copyWith(driverMarker: marker));
  }
}
