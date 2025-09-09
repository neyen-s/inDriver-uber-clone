import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';

part 'driver_map_event.dart';
part 'driver_map_state.dart';

class DriverMapBloc extends Bloc<DriverMapEvent, DriverMapState> {
  DriverMapBloc(this._socketBloc, this.authUseCases, this._geolocatorUseCases)
    : super(DriverMapInitial()) {
    on<DriverLocationStreamStarted>(_onDriverLocationUpdated);
    on<DriverLocationSentToSocket>(_onDriverLocationSentToSocket);
  }

  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;
  final AuthUseCases authUseCases;

  StreamSubscription<void>? _positionSubscription;

  DateTime? _lastPositionSentAt;
  LatLng? _lastPositionSent;
  final Duration _sendThrottle = const Duration(milliseconds: 900);
  final double _minDistanceMeters = 8.0;

  Future<void> _onDriverLocationUpdated(
    DriverLocationStreamStarted event,
    Emitter<DriverMapState> emit,
  ) async {
    print('**BLOC: DriverMapBloc: Starting location stream...');
    emit(DriverMapLoading());

    final iconResult = await _geolocatorUseCases.createMarkerUseCase(
      'assets/img/car-placeholder.png',
    );

    await iconResult.fold((failure) async => emit(DriverMapError(failure.message)), (
      icon,
    ) async {
      print('Icon return Right');
      final stateStream = _geolocatorUseCases.getPositionStreamUseCase().asyncExpand((
        position,
      ) async* {
        final markerResult = await _geolocatorUseCases.getMarkerUseCase(
          'driver_marker',
          'Conductor',
          'Ubicación actual',
          LatLng(position.latitude, position.longitude),
          icon,
        );
        final now = DateTime.now();
        final hasTime =
            _lastPositionSentAt == null ||
            now.difference(_lastPositionSentAt!) >= _sendThrottle;
        final distanceMoved = _lastPositionSent == null
            ? double.infinity
            : Geolocator.distanceBetween(
                _lastPositionSent!.latitude,
                _lastPositionSent!.longitude,
                position.latitude,
                position.longitude,
              );
        final hasMovedEnough = distanceMoved >= _minDistanceMeters;

        print(
          '**BLOC: Position update: $position , hasTime: $hasTime, hasMovedEnough: $hasMovedEnough',
        );

        if (hasTime || hasMovedEnough) {
          _lastPositionSentAt = now;
          _lastPositionSent = LatLng(position.latitude, position.longitude);
          print('**BLOC: Emitiendo DriverLocationSentToSocket');
          add(
            DriverLocationSentToSocket(position.latitude, position.longitude),
          );
        }
        yield markerResult.fold<
          DriverMapState
        >((failure) => DriverMapError(failure.message), (marker) {
          print(
            '**BLOC: Emitting DriverMapLoaded with new marker MARKER: $marker',
          );
          return DriverMapLoaded(position: null, markers: [marker]);
        });
      });
      print(
        '**BLOC: Emitting states from position stream...: stateStream : ${stateStream.toString()}',
      );
      await emit.forEach<DriverMapState>(
        stateStream,
        onData: (state) => state,
        onError: (error, _) => DriverMapError(error.toString()),
      );
    });
  }

  Future<void> _onDriverLocationSentToSocket(
    DriverLocationSentToSocket event,
    Emitter<DriverMapState> emit,
  ) async {
    print('**BLOC: _onDriverLocationSentToSocket');
    final authResponse = await authUseCases.getUserSessionUseCase();

    authResponse.fold((failure) => emit(DriverMapError(failure.message)), (
      authResponse,
    ) async {
      try {
        print('**BLOC: Sending position to socket...');
        _socketBloc.add(
          SendDriverPositionRequested(
            idDriver: authResponse.user.id,
            lat: event.lat,
            lng: event.lng,
          ),
        );
      } catch (e) {
        print('**BLOC: ERROR sending position to socket: $e');
        emit(DriverMapError('Error sending position to socket: $e'));
      }
    });
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
