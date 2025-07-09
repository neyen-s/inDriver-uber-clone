import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/either_extensions.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
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
  }
  final GeolocatorUseCases _geolocatorUseCases;

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

    emit(PositionWithMarkerSuccess(position: position, marker: marker));
  }
}
