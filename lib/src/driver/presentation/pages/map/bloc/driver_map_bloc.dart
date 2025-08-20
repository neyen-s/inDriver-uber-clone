import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/domain/usecases/geolocator_use_cases.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/socket_use_cases.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';

part 'driver_map_event.dart';
part 'driver_map_state.dart';

class DriverMapBloc extends Bloc<DriverMapEvent, DriverMapState> {
  DriverMapBloc(
    this.socketUseCases,
    this.authUseCases,
    this._geolocatorUseCases,
  ) : super(DriverMapInitial()) {
    on<DriverLocationStreamStarted>(_onDriverLocationUpdated);

    on<ConnectSocketIo>(_onConnectSocketIo);
    on<DisconnectSocketIo>(_onDisconnectSocketIo);
    on<DriverLocationSentToSocket>(_onDriverLocationSentToSocket);
  }

  final GeolocatorUseCases _geolocatorUseCases;
  final SocketUseCases socketUseCases;
  final AuthUseCases authUseCases;

  StreamSubscription<void>? _positionSubscription;

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

              add(
                DriverLocationSentToSocket(
                  position.latitude,
                  position.longitude,
                ),
              );

              yield markerResult.fold<DriverMapState>(
                (failure) => DriverMapError(failure.message),
                (marker) => DriverMapPositionWithMarker(marker),
              );
            });

        await emit.forEach<DriverMapState>(
          stateStream,
          onData: (state) => state,
          onError: (error, _) => DriverMapError(error.toString()),
        );
      },
    );
  }

  Future<void> _onConnectSocketIo(
    ConnectSocketIo event,
    Emitter<DriverMapState> emit,
  ) async {
    await socketUseCases.connectSocketUseCase();
  }

  Future<void> _onDisconnectSocketIo(
    DisconnectSocketIo event,
    Emitter<DriverMapState> emit,
  ) async {
    await socketUseCases.disconnectSocketUseCase();
  }

  Future<void> _onDriverLocationSentToSocket(
    DriverLocationSentToSocket event,
    Emitter<DriverMapState> emit,
  ) async {
    final authResponse = await authUseCases.getUserSessionUseCase();

    authResponse.fold((failure) => emit(DriverMapError(failure.message)), (
      authResponse,
    ) async {
      try {
        await socketUseCases.sendSocketMessageUseCase(
          'change_driver_position',
          {'id': authResponse.user.id, 'lat': event.lat, 'lng': event.lng},
        );
      } catch (e) {
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
