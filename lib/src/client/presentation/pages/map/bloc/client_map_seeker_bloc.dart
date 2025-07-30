import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/enums/enums.dart';
import 'package:indriver_uber_clone/core/utils/deboncer_location.dart';
import 'package:indriver_uber_clone/core/utils/either_extensions.dart';
import 'package:indriver_uber_clone/core/utils/get_adress_from_latlng.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/geolocator_use_cases.dart';

part 'client_map_seeker_event.dart';
part 'client_map_seeker_state.dart';

class ClientMapSeekerBloc
    extends Bloc<ClientMapSeekerEvent, ClientMapSeekerState> {
  ClientMapSeekerBloc(this._geolocatorUseCases, {DebouncerLocation? debouncer})
    : _debouncer =
          debouncer ?? DebouncerLocation(const Duration(milliseconds: 500)),

      super(ClientMapSeekerInitial()) {
    on<GetCurrentPositionRequested>(_onGetCurrentPositionRequested);
    on<LoadCurrentLocationWithMarkerRequested>(
      _onLoadCurrentLocationWithMarkerRequested,
    );
    // on<MapMoved>(_onMapMoved);
    on<MapIdle>(_onMapIdle);
    on<GetAddressFromLatLng>(_onGetAddressFromLatLng);
    on<ConfirmTripDataEntered>(_onConfirmTripDataEntered);
    on<CancelTripConfirmation>(_onCancelTripConfirmation);
    on<ChangeSelectedFieldRequested>(_onChangeSelectedFieldRequested);
  }

  final DebouncerLocation _debouncer;
  final GeolocatorUseCases _geolocatorUseCases;
  LatLng? lastLatLng;
  SelectedField _currentSelectedField = SelectedField.origin;
  bool _isFetchingAddress = false;

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

  /*   void _onMapMoved(MapMoved event, Emitter<ClientMapSeekerState> emit) {
    if (state is ReadyToConfirmTrip) return;
    lastLatLng = event.target;
    // No emitimos nada aquí si el marcador es fijo (centrado con UI).
  } */

  Future<void> _onMapIdle(
    MapIdle event,
    Emitter<ClientMapSeekerState> emit,
  ) async {
    if (_isFetchingAddress || state is ReadyToConfirmTrip) return;
    _isFetchingAddress = true;
    try {
      emit(AddressFetching(_currentSelectedField));
      final address = await getAddressFromLatLng(event.latLng);
      emit(AddressUpdatedSuccess(address, _currentSelectedField));
    } catch (e) {
      emit(ClientMapSeekerError('Error while getting address.  $e '));
      print('** Error while getting address: $e');
    } finally {
      _isFetchingAddress = false;
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

      print('*******************Reverse geocoding placemarks: $placemarks');
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            "${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}";
        emit(AddressUpdatedSuccess(address, _currentSelectedField));
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
    emit(
      ReadyToConfirmTrip(origin: event.origin, destination: event.destination),
    );
  }

  void _onCancelTripConfirmation(
    CancelTripConfirmation event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    emit(ClientMapSeekerInitial());
  }

  void _onChangeSelectedFieldRequested(
    ChangeSelectedFieldRequested event,
    Emitter<ClientMapSeekerState> emit,
  ) {
    _currentSelectedField = event.selectedField;
    emit(SelectedFieldChanged(event.selectedField));
  }
}
