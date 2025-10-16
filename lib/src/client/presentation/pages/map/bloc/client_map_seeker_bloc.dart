import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_usecase.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/deboncer_location.dart';
import 'package:indriver_uber_clone/secrets.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/client/domain/entities/client_request_entity.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/create_client_request_use_case.dart';

part 'client_map_seeker_event.dart';
part 'client_map_seeker_state.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  ClientMapSeekerBloc(
    this._geolocatorUseCases,
    this.socketBloc,
    this.clientRequestsUsecases,
    this.authUseCases, {
    DebouncerLocation? debouncer,
  }) : _debouncer =
           debouncer ?? DebouncerLocation(const Duration(milliseconds: 500)),

       super(ClientMapSeekerInitial()) {
    on<GetCurrentPositionRequested>(_onGetCurrentPositionRequested);
    on<GetAddressFromLatLng>(_onGetAddressFromLatLng);
    on<CancelTripConfirmation>(_onCancelTripConfirmation);
    on<ChangeSelectedFieldRequested>(_onChangeSelectedFieldRequested);
    on<DrawRouteRequested>(_onDrawRouteRequested);
    on<ClientMapCameraCentered>(_onClientMapCameraCentered);
    on<ResetCameraRequested>(_onResetCameraRequested);
    // on<GetTimeAndDistanceValuesRequested>(_onGetTimeAndDistanceValues);
    on<CreateClientRequest>(_onCreateClientRequest);

    //socket related events
    on<AddDriverPositionMarker>(_onAddDriverPositionMarker);
    on<RemoveDriverPositionMarker>(_onRemoveDriverPositionMarker);
    on<ClearDriverMarkers>(_onClearDriverMarkers);
    on<DriversSnapshotReceived>(_onDriversSnapshotReceived);

    // Socket Subscriptions events
    _listenToSocket();
  }

  final DebouncerLocation _debouncer;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc socketBloc;
  final ClientRequestsUsecases clientRequestsUsecases;
  final AuthUseCases authUseCases;

  StreamSubscription? _socketSub;
  StreamSubscription<dynamic>? _socketStreamSub;
  StreamSubscription<Position>? _positionStreamSub;
  LatLng? lastLatLng;

  DateTime? _lastNonEmptySnapshotAt;
  final Duration _emptySnapshotGrace = const Duration(seconds: 2);

  void _listenToSocket() {
    _socketSub = socketBloc.stream.listen((socketState) {
      if (socketState is SocketDriverPositionsUpdated) {
        add(DriversSnapshotReceived(Map.from(socketState.drivers)));
      }
    });
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    _socketSub?.cancel();
    _socketStreamSub?.cancel();
    _positionStreamSub?.cancel();
    return super.close();
  }

  Future<void> _onGetCurrentPositionRequested(
    GetCurrentPositionRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();
    emit(current.copyWith(isLoading: true));

    final result = await _geolocatorUseCases.findPositionUseCase().timeout(
      const Duration(seconds: 10),
      onTimeout: () => const Left(
        ServerFailure(message: 'Location request timed out', statusCode: 408),
      ),
    );

    result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
      position,
    ) {
      emit(current.copyWith(userPosition: position, isLoading: false));
    });
  }

  Future<void> _onResetCameraRequested(
    ResetCameraRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();
    emit(current.copyWith(hasCenteredCameraOnce: false));
  }

  Future<void> _onGetAddressFromLatLng(
    GetAddressFromLatLng event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        event.latLng.latitude,
        event.latLng.longitude,
      );

      if (placemarks.isEmpty) {
        emit(const ClientMapSeekerError('Address not found.'));
        return;
      }

      final placemark = placemarks.first;
      final address =
          '${placemark.street}, ${placemark.locality}, '
          ' ${placemark.administrativeArea}';

      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();

      if (event.selectedField == SelectedField.origin) {
        emit(
          current.copyWith(
            origin: event.latLng,
            originAddress: address,
            selectedField: event.selectedField,
          ),
        );
      } else {
        emit(
          current.copyWith(
            destination: event.latLng,
            destinationAddress: address,
            selectedField: SelectedField.destination,
          ),
        );
      }
    } catch (e) {
      emit(const ClientMapSeekerError('Error while getting address.'));
    }
  }

  void _onCancelTripConfirmation(
    CancelTripConfirmation event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    emit(current.copyWith(mapPolylines: {}));
  }

  void _onChangeSelectedFieldRequested(
    ChangeSelectedFieldRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    emit(current.copyWith(selectedField: event.selectedField));
  }

  Future<void> _onDrawRouteRequested(
    DrawRouteRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    try {
      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();

      // Guardamos origin/destination e indicamos loading
      emit(
        current.copyWith(
          origin: event.origin,
          destination: event.destination,
          isLoading: true,
        ),
      );

      // Llamada al service que calcula time & distance (sin encolar)
      print('orign: ${event.origin}, destination: ${event.destination}');
      final timeResult = await clientRequestsUsecases
          .getTimeAndDistanceValuesUsecase(
            TimeAndDistanceParams(
              originLat: event.origin.latitude,
              originLng: event.origin.longitude,
              destinationLat: event.destination.latitude,
              destinationLng: event.destination.longitude,
            ),
          );

      // Calculamos la polyline (pues esta llamada también puede tardar)
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
        emit(const ClientMapSeekerError('Could not find route.'));
        return;
      }

      final route = response.routes.first;
      final points = route.polylinePoints ?? [];
      final latLngPoints = points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: latLngPoints,
      );

      final updatedPolylines = {
        ...current.polylines,
        polyline.polylineId: polyline,
      };

      // Extraer valores del timeResult (si success)
      TimeAndDistanceValuesEntity? timeAndDistanceValues;
      double distanceKmFromApi = 0;
      var durationMinutesFromApi = 0;

      timeResult.fold(
        (failure) {
          debugPrint('GetTimeAndDistanceValues FAILED: ${failure.message}');
          timeAndDistanceValues = null;
        },
        (val) {
          timeAndDistanceValues = val;
          distanceKmFromApi = val.distance.value;
          durationMinutesFromApi = val.duration.value.round();
        },
      );

      // Preferir valores del API de time/distance si existen, sino usar los derivados de la route
      final distanceKm = distanceKmFromApi != 0
          ? distanceKmFromApi
          : (route.distanceMeters ?? 0) / 1000;
      final durationMinutes = durationMinutesFromApi != 0
          ? durationMinutesFromApi
          : ((route.duration ?? 0) / 60).round();

      // Emitimos un único estado final completo (incluye quitar loader)
      emit(
        current.copyWith(
          mapPolylines: updatedPolylines,
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          timeAndDistanceValues: timeAndDistanceValues,
          origin: event.origin,
          destination: event.destination,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(ClientMapSeekerError('Error While drawing route: $e'));
    }
  }

  Future<void> _onAddDriverPositionMarker(
    AddDriverPositionMarker event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    final icon = await foldOrEmitError<BitmapDescriptor, ClientMapSeekerState>(
      iconResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (icon == null) return;

    final markerResult = await _geolocatorUseCases.getMarkerUseCase(
      event.idSocket,
      'Driver',
      'Available driver',
      LatLng(event.lat, event.lng),
      icon,
    );

    final marker = await foldOrEmitError<Marker, ClientMapSeekerState>(
      markerResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (marker == null) return;

    final updated = Map<String, Marker>.from(current.driverMarkers)
      ..[event.idSocket] = marker;

    emit(current.copyWith(driverMarkers: updated));
  }

  void _onRemoveDriverPositionMarker(
    RemoveDriverPositionMarker event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    final updated = Map<String, Marker>.from(current.driverMarkers)
      ..remove(event.idSocket);

    emit(current.copyWith(driverMarkers: updated));
  }

  void _onClearDriverMarkers(
    ClearDriverMarkers event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    emit(current.copyWith(driverMarkers: <String, Marker>{}));
  }

  Future<void> _onDriversSnapshotReceived(
    DriversSnapshotReceived event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    //if recently had non-empty, ignore empty,
    //For when it desconects and reconect from the socket quickly
    if (event.drivers.isEmpty) {
      final last = _lastNonEmptySnapshotAt;
      if (last != null &&
          DateTime.now().difference(last) < _emptySnapshotGrace) {
        debugPrint(
          'Ignored empty snapshot because last non-empty was'
          ' ${DateTime.now().difference(last).inMilliseconds} ms ago',
        );
        return;
      }
      emit(current.copyWith(driverMarkers: <String, Marker>{}));
      return;
    }

    //shanpshot not empty -> update timestamp and build markers
    _lastNonEmptySnapshotAt = DateTime.now();

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    final icon = await foldOrEmitError<BitmapDescriptor, ClientMapSeekerState>(
      iconResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (icon == null) return;

    final newMarkers = <String, Marker>{};
    for (final entry in event.drivers.entries) {
      final driverId = entry.key;
      final pos = entry.value;

      final markerResult = await _geolocatorUseCases.getMarkerUseCase(
        driverId,
        'Driver',
        'Available driver',
        LatLng(pos.latitude, pos.longitude),
        icon,
      );

      final marker = await foldOrEmitError<Marker, ClientMapSeekerState>(
        markerResult,
        emit,
        ClientMapSeekerError.new,
      );

      if (marker != null) {
        newMarkers[driverId] = marker;
      }
    }

    emit(current.copyWith(driverMarkers: newMarkers));
  }

  void _onClientMapCameraCentered(
    ClientMapCameraCentered event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    if (state is ClientMapSeekerSuccess) {
      emit(
        (state as ClientMapSeekerSuccess).copyWith(hasCenteredCameraOnce: true),
      );
    }
  }

  /*   Future<void> _onGetTimeAndDistanceValues(
    GetTimeAndDistanceValuesRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    print('**BLOC _onGetTimeAndDistanceValues ');

    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    // Usamos los datos que vienen en el evento, no los del state.
    final originLat = event.originLat;
    final originLng = event.originLng;
    final destinationLat = event.destinationLat;
    final destinationLng = event.destinationLng;

    // Seguridad: si por alguna razón faltan coords en el event, fallback al state
    if (originLat == null ||
        originLng == null ||
        destinationLat == null ||
        destinationLng == null) {
      final origin = current.origin;
      final destination = current.destination;
      if (origin == null || destination == null) {
        emit(const ClientMapSeekerError('Origin or destination is null'));
        return;
      }
    }

    try {
      final result = await clientRequestsUsecases
          .getTimeAndDistanceValuesUsecase(
            TimeAndDistanceParams(
              originLat: originLat ?? current.origin!.latitude,
              originLng: originLng ?? current.origin!.longitude,
              destinationLat: destinationLat ?? current.destination!.latitude,
              destinationLng: destinationLng ?? current.destination!.longitude,
            ),
          );

      result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
        timeAndDistanceValues,
      ) {
        // combinamos con el estado actual (no perder polylines, etc.)
        emit(current.copyWith(timeAndDistanceValues: timeAndDistanceValues));
      });
    } catch (e) {
      emit(ClientMapSeekerError('Error getting time/distance values: $e'));
    }
  } */

  Future<void> _onCreateClientRequest(
    CreateClientRequest event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    final authResponse = await authUseCases.getUserSessionUseCase();

    await authResponse.fold(
      (failure) async {
        emit(ClientMapSeekerError(failure.message));
      },
      (authResponse) async {
        print(
          '----------------------------urrent.origin?.latitude: ${current.origin?.latitude}',
        );
        print(
          '----------------------------current.origin?.longitude: ${current.origin?.longitude}',
        );
        print(
          '----------------------------current.destination?.longitude: ${current.destination?.latitude}',
        );
        print(
          '----------------------------current.destination?.longitude: ${current.destination?.longitude}',
        );

        try {
          debugPrint('**BLOC: creating Client request...');
          final response = await clientRequestsUsecases
              .createClientRequestUseCase(
                CreateClientRequestParams(
                  clientRequestEntity: ClientRequestEntity(
                    idClient: authResponse.user.id,
                    fareOffered: event.fareOffered,
                    pickupDescription:
                        current.timeAndDistanceValues?.originAddresses ?? '',
                    destinationDescription:
                        current.timeAndDistanceValues?.destinationAddresses ??
                        '',
                    pickupLat: current.origin?.latitude ?? 0.0,
                    pickupLng: current.origin?.longitude ?? 0.0,
                    destinationLat: current.destination?.latitude ?? 0.0,
                    destinationLng: current.destination?.longitude ?? 0.0,
                  ),
                ),
              );

          await response.fold(
            (failure) async {
              emit(ClientMapSeekerError(failure.message));
            },
            (clientRequest) async {
              debugPrint('**BLOC: Client request created: $clientRequest');
              emit(
                current.copyWith(
                  clientRequestSended: true,
                  polylines: {},
                  mapPolylines: {},
                ),
              );
              await Future<void>.delayed(const Duration(milliseconds: 100));
              emit(current.copyWith(clientRequestSended: false));
            },
          );
        } catch (e) {
          debugPrint('**BLOC: ERROR CREATING CLIENT REQUEST: $e');
          emit(ClientMapSeekerError('ERROR CREATING CLIENT REQUEST: $e'));
        }
      },
    );
  }
}
