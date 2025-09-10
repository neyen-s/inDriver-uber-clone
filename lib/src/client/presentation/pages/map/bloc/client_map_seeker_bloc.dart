import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/deboncer_location.dart';
import 'package:indriver_uber_clone/secrets.dart';

part 'client_map_seeker_event.dart';
part 'client_map_seeker_state.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  ClientMapSeekerBloc(
    this._geolocatorUseCases,
    this.socketBloc, {
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

  StreamSubscription? _socketSub;
  StreamSubscription<dynamic>? _socketStreamSub;
  StreamSubscription<Position>? _positionStreamSub;
  LatLng? lastLatLng;

  // dentro de la clase ClientMapSeekerBloc
  DateTime? _lastNonEmptySnapshotAt;
  final Duration _emptySnapshotGrace = const Duration(seconds: 2);

  // Escuchar estados del socket

  void _listenToSocket() {
    print('ENTRO EN LISTEN TO SOCKET');
    _socketSub = socketBloc.stream.listen((socketState) {
      print('ClientMapSeekerBloc received socket state: $socketState');
      if (socketState is SocketDriverPositionsUpdated) {
        // En lugar de añadir uno a uno, mandamos el snapshot completo
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
    // emit(ClientMapSeekerLoading());
    print(' -----_onGetCurrentPositionRequested -----');
    final result = await _geolocatorUseCases.findPositionUseCase();

    result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
      position,
    ) {
      print('Current position: $position');
      // emit a success state if not already
      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();
      print('emitting new position current: $current');
      emit(current.copyWith(userPosition: position));
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

      // Diferenciar por selectedField
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

  // --------------------------
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
    print('-----_onChangeSelectedFieldRequested -----');
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();
    print('selectedField: ${event.selectedField}');

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

      //emit(ClientMapSeekerLoading());

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

      if (response.routes.isNotEmpty) {
        final route = response.routes.first;

        // 🔹 Construir polyline
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

        // 🔹 Extraer distancia y duración
        final distanceKm = (route.distanceMeters ?? 0) / 1000;
        final durationMinutes = ((route.duration ?? 0) / 60).round();
        emit(
          current.copyWith(
            mapPolylines: updatedPolylines,
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
          ),
        );
      } else {
        emit(const ClientMapSeekerError('No se pudo dibujar la ruta.'));
      }
    } catch (e) {
      emit(ClientMapSeekerError('Error al trazar ruta: $e'));
    }
  }

  // --------------------------
  // Evento que crea/actualiza el marker (usa usecases)
  Future<void> _onAddDriverPositionMarker(
    AddDriverPositionMarker event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    print('-----_onAddDriverPositionMarker -----');
    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    final icon = await foldOrEmitError<BitmapDescriptor, ClientMapSeekerState>(
      iconResult,
      emit,
      (msg) => ClientMapSeekerError(msg),
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
      (msg) => ClientMapSeekerError(msg),
    );
    if (marker == null) return;

    print('markerResult: $markerResult');
    final updated = Map<String, Marker>.from(current.driverMarkers)
      ..[event.idSocket] = marker;
    /*     final updated = Map<String, LatLng>.from(current.driverPositions)
      ..[event.idSocket] = LatLng(event.lat, event.lng); */

    print('emit');
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

    // Vaciar el map/Set de driverMarkers
    emit(
      current.copyWith(driverMarkers: <String, Marker>{}),
    ); // si ya cambiaste a Map<String,Marker>
  }

  Future<void> _onDriversSnapshotReceived(
    DriversSnapshotReceived event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    print('_onDriversSnapshotReceived: ${event.drivers.length} drivers');

    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();

    // Si snapshot vacío y hace poco tuvimos uno no vacío, lo ignoramos
    if (event.drivers.isEmpty) {
      final last = _lastNonEmptySnapshotAt;
      if (last != null &&
          DateTime.now().difference(last) < _emptySnapshotGrace) {
        print(
          'Ignored empty snapshot because last non-empty was ${DateTime.now().difference(last).inMilliseconds} ms ago',
        );
        return;
      }
      // Si no hubo non-empty reciente, procedemos a limpiar
      emit(current.copyWith(driverMarkers: <String, Marker>{}));
      return;
    }

    // snapshot no vacío -> actualizamos timestamp y construimos markers
    _lastNonEmptySnapshotAt = DateTime.now();

    // Reutiliza icon una sola vez (eficiencia)
    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    final icon = await foldOrEmitError<BitmapDescriptor, ClientMapSeekerState>(
      iconResult,
      emit,
      (msg) => ClientMapSeekerError(msg),
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
        (msg) => ClientMapSeekerError(msg),
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
}
