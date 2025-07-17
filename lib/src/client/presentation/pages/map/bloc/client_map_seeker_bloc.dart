import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/utils/either_extensions.dart';
import 'package:indriver_uber_clone/core/utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/geolocator_use_cases.dart';

part 'client_map_seeker_event.dart';
part 'client_map_seeker_state.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  ClientMapSeekerBloc(this._geolocatorUseCases)
    : super(ClientMapSeekerInitial()) {
    on<GetCurrentPositionRequested>(_onGetCurrentPositionRequested);
    on<LoadCurrentLocationWithMarkerRequested>(
      _onLoadCurrentLocationWithMarkerRequested,
    );
    on<MapMoved>(_onMapMoved);
    on<MapIdle>(_onMapIdle);
    on<GetAddressFromLatLng>(_onGetAddressFromLatLng);
  }
  final GeolocatorUseCases _geolocatorUseCases;
  LatLng? lastLatLng;

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

  Future<void> _onLoadCurrentLocationWithMarkerRequested(
    LoadCurrentLocationWithMarkerRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    emit(ClientMapSeekerLoading());

    final positionResult = await _geolocatorUseCases.findPositionUseCase();
    final position = await foldOrEmitError(
      positionResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (position == null) return;

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/location_blue.png',
    );
    final icon = await foldOrEmitError(
      iconResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (icon == null) return;

    final markerResult = await _geolocatorUseCases.getMarkerUseCase(
      'me',
      'My location',
      'I am here',
      LatLng(position.latitude, position.longitude),
      icon,
    );
    final marker = await foldOrEmitError(
      markerResult,
      emit,
      ClientMapSeekerError.new,
    );
    if (marker == null) return;

    emit(
      PositionWithMarkerSuccess(
        position: LatLng(position.latitude, position.longitude),
        marker: marker,
      ),
    );
  }

  void _onMapMoved(MapMoved event, Emitter<ClientMapSeekerState> emit) {
    lastLatLng = event.target;
    // No emitimos nada aquí si el marcador es fijo (centrado con UI).
  }

  Future<void> _onMapIdle(
    MapIdle event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    try {
      final address = await getAddressFromLatLng(event.latLng);
      emit(AddressUpdatedSuccess(address));
    } catch (e) {
      emit(const ClientMapSeekerError('No se pudo obtener la dirección.'));
    }
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
            "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}";
        emit(AddressUpdatedSuccess(address));
      } else {
        emit(const ClientMapSeekerError('Address not found.'));
      }
    } catch (e) {
      emit(const ClientMapSeekerError('Error while getting address. '));
    }
  }
}
