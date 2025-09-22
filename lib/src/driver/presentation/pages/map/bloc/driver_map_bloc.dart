import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/driver_position_usecases.dart';

part 'driver_map_event.dart';
part 'driver_map_state.dart';

class DriverMapBloc extends Bloc<DriverMapEvent, DriverMapState> {
  DriverMapBloc(
    this._socketBloc,
    this.authUseCases,
    this._geolocatorUseCases,
    this._driverPositionUseCases,
  ) : super(DriverMapInitial()) {
    on<DriverLocationStreamStarted>(_onDriverLocationUpdated);
    on<DriverLocationSentToSocket>(_onDriverLocationSentToSocket);

    on<SaveLoactionData>(_onSaveLocationData);
    on<DeleteLoactionData>(_onDeleteLocationData);
  }

  final GeolocatorUseCases _geolocatorUseCases;
  final SocketBloc _socketBloc;
  final AuthUseCases authUseCases;
  final DriverPositionUsecases _driverPositionUseCases;

  StreamSubscription<void>? _positionSubscription;

  DateTime? _lastPositionSentAt;
  LatLng? _lastPositionSent;
  final Duration _sendThrottle = const Duration(milliseconds: 900);
  final double _minDistanceMeters = 8;

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

              debugPrint(
                '**BLOC: Position update: $position , hasTime: '
                ' $hasTime, hasMovedEnough: $hasMovedEnough',
              );

              if (hasTime || hasMovedEnough) {
                _lastPositionSentAt = now;
                _lastPositionSent = LatLng(
                  position.latitude,
                  position.longitude,
                );
                add(
                  DriverLocationSentToSocket(
                    position.latitude,
                    position.longitude,
                  ),
                );
              }
              yield markerResult.fold<DriverMapState>(
                (failure) => DriverMapError(failure.message),
                (marker) {
                  debugPrint(
                    '**BLOC: Emitting DriverMapLoaded with new marker '
                    ' MARKER: $marker',
                  );
                  return DriverMapLoaded(position: null, markers: [marker]);
                },
              );
            });
        debugPrint(
          '**BLOC: Emitting states from position stream...: '
          ' stateStream : $stateStream',
        );
        await emit.forEach<DriverMapState>(
          stateStream,
          onData: (state) => state,
          onError: (error, _) => DriverMapError(error.toString()),
        );
      },
    );
  }

  Future<void> _onDriverLocationSentToSocket(
    DriverLocationSentToSocket event,
    Emitter<DriverMapState> emit,
  ) async {
    debugPrint('**BLOC: _onDriverLocationSentToSocket');
    final authResponse = await authUseCases.getUserSessionUseCase();

    authResponse.fold((failure) => emit(DriverMapError(failure.message)), (
      authResponse,
    ) async {
      try {
        debugPrint('**BLOC: Sending position to socket...');
        _socketBloc.add(
          SendDriverPositionRequested(
            idDriver: authResponse.user.id,
            lat: event.lat,
            lng: event.lng,
          ),
        );
        add(
          SaveLoactionData(
            DriverPositionEntity(
              idDriver: authResponse.user.id,
              lat: event.lat,
              lng: event.lng,
            ),
          ),
        );
      } catch (e) {
        debugPrint('**BLOC: ERROR sending position to socket: $e');
        emit(DriverMapError('Error sending position to socket: $e'));
      }
    });
  }

  Future<void> _onSaveLocationData(
    SaveLoactionData event,
    Emitter<DriverMapState> emit,
  ) async {
    debugPrint('**BLOC: _onSaveLocationData');

    try {
      await _driverPositionUseCases.createDriverPositionUsecase(
        driverPosition: event.driverPositionEntity,
      );
    } catch (e) {
      debugPrint('**BLOC: ERROR saving location data: $e');
      emit(DriverMapError('Error saving location data: $e'));
    }
  }

  Future<void> _onDeleteLocationData(
    DeleteLoactionData event,
    Emitter<DriverMapState> emit,
  ) async {
    debugPrint('**BLOC: _onDeleteLocationData');
    try {
      final result = await _driverPositionUseCases.deleteDriverPositionUsecase(
        idDriver: event.idDriver,
      );

      final success = result.fold(
        (failure) {
          debugPrint('DeleteDriverPosition failed: ${failure.message}');
          return false;
        },
        (message) {
          debugPrint('DeleteDriverPosition success: $message');
          return true;
        },
      );

      event.completer?.complete(success);
    } catch (e, st) {
      debugPrint('Error deleting location: $e\n$st');
      event.completer?.complete(false);
      emit(DriverMapError('Error deleting location data: $e'));
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
