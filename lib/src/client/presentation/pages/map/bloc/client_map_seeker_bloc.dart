import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/socket_use_cases.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/deboncer_location.dart';
import 'package:indriver_uber_clone/secrets.dart';

part 'client_map_seeker_event.dart';
part 'client_map_seeker_state.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  ClientMapSeekerBloc(
    this._geolocatorUseCases,
    this._socketUseCases, {
    DebouncerLocation? debouncer,
  }) : _debouncer =
           debouncer ?? DebouncerLocation(const Duration(milliseconds: 500)),

       super(ClientMapSeekerInitial()) {
    on<GetCurrentPositionRequested>(_onGetCurrentPositionRequested);
    on<GetAddressFromLatLng>(_onGetAddressFromLatLng);
    on<ConfirmTripDataEntered>(_onConfirmTripDataEntered);
    on<CancelTripConfirmation>(_onCancelTripConfirmation);
    on<ChangeSelectedFieldRequested>(_onChangeSelectedFieldRequested);
    on<DrawRouteRequested>(_onDrawRouteRequested);
    on<ConnectSocketIo>(_onConnectSocketIo);
    on<DisconnectSocketIo>(_onDisconnectSocketIo);
    on<ListenDriverPositionSocket>(_onListenDriverPositionSocket);
    on<AddDriverPositionMarker>(_onAddDriverPositionMarker);
    on<ClientMapCameraCentered>(_onClientMapCameraCentered);
  }

  final DebouncerLocation _debouncer;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketUseCases _socketUseCases;

  StreamSubscription<dynamic>? _socketStreamSub;
  StreamSubscription<Position>? _positionStreamSub;

  LatLng? lastLatLng;

  SelectedField _currentSelectedField = SelectedField.origin;

  @override
  Future<void> close() {
    _debouncer.dispose();
    _socketStreamSub?.cancel();
    _positionStreamSub?.cancel();
    return super.close();
  }

  Future<void> _onGetCurrentPositionRequested(
    GetCurrentPositionRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    emit(ClientMapSeekerLoading());

    final result = await _geolocatorUseCases.findPositionUseCase();
    result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
      position,
    ) {
      // emit a success state if not already
      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();
      emit(current.copyWith(userPosition: position));
    });
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
          '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';

      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();

      // Diferenciar por selectedField
      if (event.selectedField == SelectedField.origin) {
        print('**** Selected field is origin');
        print('**** ORIGIN: ${event.latLng}');
        print('**** ORIGIN address : $address');
        emit(
          current.copyWith(
            origin: event.latLng,
            originAddress: address,
            selectedField: event.selectedField,
            userMarker: Marker(
              markerId: const MarkerId('origin'),
              position: event.latLng,
            ),
          ),
        );
      } else {
        print('**** Selected field is destination');
        print('**** Destination: ${event.latLng}');
        print('**** Destination address : $address');

        emit(
          current.copyWith(
            destination: event.latLng,
            destinationAddress: address,
            selectedField: SelectedField.destination,
            userMarker: Marker(
              markerId: const MarkerId('destination'),
              position: event.latLng,
            ),
          ),
        );
      }
    } catch (e) {
      emit(const ClientMapSeekerError('Error while getting address.'));
    }
  }

  void _onConfirmTripDataEntered(
    ConfirmTripDataEntered event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    add(
      DrawRouteRequested(
        origin: event.originLatLng,
        destination: event.destinationLatLng,
        originText: event.origin,
        destinationText: event.destination,
      ),
    );
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

      emit(current.copyWith(isDrawingRoute: true));

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
            isDrawingRoute: false,
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
  // SOCKET: conectar y suscribirse
  Future<void> _onConnectSocketIo(
    ConnectSocketIo event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final result = await _socketUseCases.connectSocketUseCase();

    result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (_) {
      final current = state is ClientMapSeekerSuccess
          ? state as ClientMapSeekerSuccess
          : const ClientMapSeekerSuccess();
      emit(current.copyWith(isSocketConnected: true));

      // luego lanzamos la escucha de driver positions
      //  add(const ListenDriverPositionSocket());
    });
  }

  Future<void> _onDisconnectSocketIo(
    DisconnectSocketIo event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    await _socketUseCases.disconnectSocketUseCase();
    await _socketStreamSub?.cancel();

    final current = state is ClientMapSeekerSuccess
        ? state as ClientMapSeekerSuccess
        : const ClientMapSeekerSuccess();
    emit(current.copyWith(isSocketConnected: false));
  }

  // --------------------------
  // Suscribirse al stream del socket y actualizar markers
  Future<void> _onListenDriverPositionSocket(
    ListenDriverPositionSocket event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    // Cancela suscripción previa si existiera
    await _socketStreamSub?.cancel();

    final result = await _socketUseCases.onSocketMessageUseCase(
      'new_driver_position',
    );

    result.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
      stream,
    ) {
      // Si necesitas un icono de marker, créalo una vez y guárdalo en el estado.
      // Aquí asumimos que getMarkerUseCase crea un Marker dado id y LatLng,
      // pero para eficiencia deberías crear el BitmapDescriptor una vez (icon).
      _socketStreamSub = stream.listen((data) {
        try {
          final idSocket = data['id_socket'] as String;
          final id = data['id'] as int;
          final lat = (data['lat'] as num).toDouble();
          final lng = (data['lng'] as num).toDouble();

          // En vez de crear el Marker sin el icon (coste), puedes crear una "marker info" y delegar icon -> getMarkerUseCase
          add(
            AddDriverPositionMarker(
              idSocket: idSocket,
              id: id,
              lat: lat,
              lng: lng,
            ),
          );
        } catch (e) {
          debugPrint('Invalid driver data from socket: $e');
        }
      });
    });
  }

  // --------------------------
  // Evento que crea/actualiza el marker (usa usecases)
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

    iconResult.fold((failure) => emit(ClientMapSeekerError(failure.message)), (
      icon,
    ) async {
      final markerResult = await _geolocatorUseCases.getMarkerUseCase(
        event.idSocket,
        'Driver',
        'Available driver',
        LatLng(event.lat, event.lng),
        icon,
      );

      markerResult.fold(
        (failure) => emit(ClientMapSeekerError(failure.message)),
        (marker) {
          // copiamos y actualizamos set
          final updated = {
            ...current.driverMarkers.where(
              (m) => m.markerId.value != event.idSocket,
            ),
            marker,
          };

          emit(current.copyWith(driverMarkers: updated));
        },
      );
    });
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
