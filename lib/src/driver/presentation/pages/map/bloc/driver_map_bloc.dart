import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/usecases/usecases/geolocator_use_cases.dart';

part 'driver_map_event.dart';
part 'driver_map_state.dart';

class DriverMapBloc extends Bloc<DriverMapEvent, DriverMapState> {
  DriverMapBloc(this._geolocatorUseCases) : super(DriverMapInitial()) {
    on<DriverLocationRequested>(_onDriverLocationRequested);
    on<DriverMapMoveToCurrentLocationRequested>(_onMoveToCurrentLocation);
    on<DriverLocationStreamStarted>(_onDriverLocationUpdated);
  }

  final GeolocatorUseCases _geolocatorUseCases;

  StreamSubscription<void>? _positionSubscription;

  Future<void> _onDriverLocationRequested(
    DriverLocationRequested event,
    Emitter<DriverMapState> emit,
  ) async {
    emit(DriverMapLoading());

    final positionResult = await _geolocatorUseCases.findPositionUseCase();

    positionResult.fold(
      (failure) => emit(DriverMapError(failure.message)),
      (position) => emit(DriverMapPositionLoaded(position)),
    );
  }

  Future<void> _onMoveToCurrentLocation(
    DriverMapMoveToCurrentLocationRequested event,
    Emitter<DriverMapState> emit,
  ) async {
    try {
      final position = await _geolocatorUseCases.findPositionUseCase();
      position.fold((failure) => emit(DriverMapError(failure.message)), (
        position,
      ) {
        emit(DriverMapPositionLoaded(position));
      });
    } catch (e) {
      emit(DriverMapError(e.toString()));
    }
  }

  Future<void> _onDriverLocationUpdated(
    DriverLocationStreamStarted event,
    Emitter<DriverMapState> emit,
  ) async {
    emit(DriverMapLoading());

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    await iconResult.fold(
      (failure) async => emit(DriverMapError(failure.message)),
      (icon) async {
        final stateStream = _geolocatorUseCases
            .getPositionStreamUseCase()
            .asyncExpand((position) async* {
              final markerResult = await _geolocatorUseCases.getMarkerUseCase(
                'driver_marker',
                'Conductor',
                'Ubicación actual',
                LatLng(position.latitude, position.longitude),
                icon,
              );

              yield markerResult.fold<DriverMapState>(
                (failure) => DriverMapError(failure.message),
                (marker) => DriverMapPositionWithMarker(marker),
              );
            });

        // Aquí el punto clave:
        await emit.forEach<DriverMapState>(
          stateStream,
          onData: (state) => state,
          onError: (error, _) => DriverMapError(error.toString()),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
