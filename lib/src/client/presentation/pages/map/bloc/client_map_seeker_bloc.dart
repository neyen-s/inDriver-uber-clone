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
    on<ListenDriverPositionSocket>(_onDriverLocationSentToSocket);
    on<AddDriverPositionMarker>(_onAddDriverPositionMarker);
  }

  final DebouncerLocation _debouncer;
  final GeolocatorUseCases _geolocatorUseCases;
  final SocketUseCases _socketUseCases;
  LatLng? lastLatLng;
  SelectedField _currentSelectedField = SelectedField.origin;

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }

  Future<void> _onGetCurrentPositionRequested(
    GetCurrentPositionRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    emit(ClientMapSeekerLoading());

    final result = await _geolocatorUseCases.findPositionUseCase();

    result.fold(
      (failure) => emit(ClientMapSeekerError(failure.message)),
      (position) => emit(FindPositionSuccess(position)),
    );
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

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.locality},'
            '${placemark.administrativeArea}';
        emit(
          AddressUpdatedSuccess(address, _currentSelectedField, event.latLng),
        );
      } else {
        emit(const ClientMapSeekerError('Address not found.'));
      }
    } catch (e) {
      emit(const ClientMapSeekerError('Error while getting address. '));
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

  void _onCancelTripConfirmation(
    CancelTripConfirmation event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    emit(const TripCancelled(polylines: {}));
  }

  void _onChangeSelectedFieldRequested(
    ChangeSelectedFieldRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    _currentSelectedField = event.selectedField;

    if (state is TripReadyToDisplay) {
      final tripState = state as TripReadyToDisplay;
      emit(
        TripReadyToDisplay(
          origin: tripState.origin,
          destination: tripState.destination,
          polylinePoints: tripState.polylinePoints,
          distanceKm: tripState.distanceKm,
          durationMinutes: tripState.durationMinutes,
          selectedLatLng: tripState.selectedLatLng,
          selectedField: event.selectedField,
        ),
      );
    } else {
      emit(SelectedFieldChanged(event.selectedField));
    }
  }

  Future<void> _onDrawRouteRequested(
    DrawRouteRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    try {
      emit(const RouteDrawingInProgress());

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
        final points = route.polylinePoints ?? [];

        debugPrint(
          '[BLOC] DrawRouteRequested: ${points.length} puntos en la ruta',
        );

        emit(
          TripReadyToDisplay(
            origin: event.originText ?? '',
            destination: event.destinationText ?? '',
            polylinePoints: points, // <-- solo datos crudos
            distanceKm: route.distanceKm ?? 0.0,
            durationMinutes: (route.durationMinutes ?? 0).toInt(),
          ),
        );
      } else {
        if (event.origin.latitude == 0.0 && event.origin.longitude == 0.0) {
          emit(const ClientMapSeekerError('Ubicación de origen no válida.'));
          return;
        }
        emit(const ClientMapSeekerError('No se pudo dibujar la ruta.'));
      }
    } catch (e) {
      emit(ClientMapSeekerError('Error al trazar ruta: $e'));
    }
  }

  Future<void> _onConnectSocketIo(
    ConnectSocketIo event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final result = await _socketUseCases.connectSocketUseCase();

    /*     result.fold(
      (failure) => emit(ClientMapSeekerError(failure.message)),
      (_) => add(ListenDriverPositionSocket(event.lat, event.lng)),
    ); */
  }

  Future<void> _onDisconnectSocketIo(
    DisconnectSocketIo event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    await _socketUseCases.disconnectSocketUseCase();
  }

  Future<void> _onDriverLocationSentToSocket(
    ListenDriverPositionSocket event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    try {
      final result = await _socketUseCases.onSocketMessageUseCase(
        'new_driver_position',
      );

      result.fold(
        (failure) {
          emit(
            ClientMapSeekerError('Error listening socket: ${failure.message}'),
          );
        },
        (stream) {
          stream.listen((data) {
            print('SOCKET IO DATA: $data');
            print('ID socket : ${data['id_socket']}');
            print('ID : ${data['id']}');
            print('Lat : ${data['lat']}');
            print('Lng : ${data['lng']}');

            // Aquí ya podrías hacer emit() con un nuevo estado
            // emit(ClientDriverPositionReceived(data));
            add(
              AddDriverPositionMarker(
                idSocket: data['id_socket'] as String,
                id: data['id'] as int,
                lat: data['lat'] as double,
                lng: data['lng'] as double,
              ),
            );
          });
        },
      );
    } catch (e) {
      emit(ClientMapSeekerError('Error subscribing to socket: $e'));
    }
  }

  Future<void> _onAddDriverPositionMarker(
    AddDriverPositionMarker event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    await iconResult.fold(
      (failure) async {
        emit(ClientMapSeekerError(failure.message));
      },
      (icon) async {
        final markerResult = await _geolocatorUseCases.getMarkerUseCase(
          event.idSocket,
          'Driver',
          'Available driver',
          LatLng(event.lat, event.lng),
          icon,
        );

        /*  markerResult.fold(
          (failure) => emit(ClientMapSeekerError(failure.message)),
          (marker) {
            // Recupero los markers previos si ya estoy en un estado con drivers
            final currentMarkers = state is ClientMapWithDrivers
                ? (state as ClientMapWithDrivers).drivers
                : <Marker>[];

            // Reemplazo si ya existía un marker con mismo idSocket, si no, lo agrego
            final updated = [
              ...currentMarkers.where(
                (m) => m.markerId.value != event.idSocket,
              ),
              marker,
            ];

            emit(ClientMapWithDrivers(updated));
          },
        ); */
      },
    );
  }
}
