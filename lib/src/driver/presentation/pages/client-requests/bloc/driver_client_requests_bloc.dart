import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/driver_trip_offers_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/drivers-position/driver_position_usecases.dart';

part 'driver_client_requests_event.dart';
part 'driver_client_requests_state.dart';

class DriverClientRequestsBloc
    extends Bloc<DriverClientRequestsEvent, DriverClientRequestsState> {
  DriverClientRequestsBloc(
    this.clientRequestsUsecases,
    this.driverPositionUsecases,
    this.authUseCases,
    this.driverTripOffersUseCases,
    this.socketBloc,
  ) : super(const DriverClientRequestsState()) {
    on<GetNearbyTripRequestEvent>(_onGetNearbyTripRequestEvent);
    on<CreateDriverTripRequestEvent>(_onCreateDriverTripRequestEvent);
    on<RemoveClientRequestLocally>(_onRemoveClientRequestLocally);

    // Start listening to socket events from the provided SocketBloc
    listenToSocket();
  }

  final ClientRequestsUsecases clientRequestsUsecases;
  final DriverPositionUsecases driverPositionUsecases;
  final DriverTripOffersUseCases driverTripOffersUseCases;
  final AuthUseCases authUseCases;
  final SocketBloc socketBloc;

  StreamSubscription? _socketBlocSub;

  @override
  Future<void> close() async {
    await _socketBlocSub?.cancel();
    return super.close();
  }

  void listenToSocket() {
    _socketBlocSub = socketBloc.stream.listen(
      (socketState) {
        debugPrint('DriverClientRequestsBloc: socketState -> $socketState');

        if (socketState is SocketClientRequestCreated) {
          final id = socketState.idClientRequest;
          debugPrint(
            'DriverClientRequestsBloc: SOCKET created_client_request $id — trying local removal',
          );
          final currentList = state.clientRequestResponseEntity;
          if (currentList != null && currentList.isNotEmpty) {
            final found = currentList.any((r) => (r.id.toString()) == id);
            if (found) {
              add(RemoveClientRequestLocally(idClientRequest: id));
              return;
            }
          }
          add(const GetNearbyTripRequestEvent());
        }

        // NUEVA RAMA: cuando el servidor notifica explícitamente que el request fue removido / asignado
        if (socketState is SocketRequestRemovedState) {
          final id = socketState.idClientRequest;
          debugPrint(
            'DriverClientRequestsBloc: SOCKET request_removed $id — removing locally',
          );
          add(RemoveClientRequestLocally(idClientRequest: id));
        }

        // también podrías soportar SocketDriverOfferArrived aquí si quieres reaccionar
        if (socketState is SocketDriverOfferArrived) {
          // opcional: refrescar lista o actualizar un item concreto
          // add(const GetNearbyTripRequestEvent());
        }
      },
      onError: (e, st) {
        debugPrint(
          'DriverClientRequestsBloc: error in socket subscription: $e\n$st',
        );
      },
    );
  }

  Future<void> _onGetNearbyTripRequestEvent(
    GetNearbyTripRequestEvent event,
    Emitter<DriverClientRequestsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));

    // Gets the driver id from the state or asks for the user session
    int driverId;
    if (state.idDriver != null) {
      driverId = state.idDriver!;
    } else {
      final authEither = await authUseCases.getUserSessionUseCase();
      final auth = await foldOrEmitError(
        authEither,
        emit,
        (msg) =>
            state.copyWith(isLoading: false, hasError: true, errorMessage: msg),
      );
      if (auth == null) return;
      driverId = auth.user.id;
      emit(state.copyWith(idDriver: driverId));
      socketBloc.add(ListenDriverAssignedChannel(driverId.toString()));
    }

    //gets driver position
    final driverPosEither = await driverPositionUsecases
        .getDriverPositionUseCase(idDriver: driverId);
    final driverPos = await foldOrEmitError(
      driverPosEither,
      emit,
      (msg) =>
          state.copyWith(isLoading: false, hasError: true, errorMessage: msg),
    );
    if (driverPos == null) return;

    //gets nearby client requests
    final requestsEither = await clientRequestsUsecases
        .getNearbyTripRequestUseCase(driverPos.lat, driverPos.lng);
    final requestList = await foldOrEmitError(
      requestsEither,
      emit,
      (msg) =>
          state.copyWith(isLoading: false, hasError: true, errorMessage: msg),
    );
    if (requestList == null) return;

    emit(
      state.copyWith(
        clientRequestResponseEntity: requestList,
        idDriver: driverId,
        isLoading: false,
        hasError: false,
      ),
    );
  }

  Future<void> _onCreateDriverTripRequestEvent(
    CreateDriverTripRequestEvent event,
    Emitter<DriverClientRequestsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final response = await driverTripOffersUseCases
        .createDriverTripOfferUseCase(event.driverTripRequestEntity);

    response.fold(
      (l) => emit(state.copyWith(isLoading: false, hasError: true)),
      (r) {
        emit(state.copyWith(isLoading: false, hasError: false));
        try {
          socketBloc.add(
            SendDriverOfferRequested(
              idClientRequest: event.driverTripRequestEntity.idClientRequest,
              idDriver: event.driverTripRequestEntity.idDriver,
              fare: event.driverTripRequestEntity.fareOffered,
              time: event.driverTripRequestEntity.time,
              distance: event.driverTripRequestEntity.distance,
            ),
          );
          debugPrint(
            'DriverClientRequestsBloc: notified socket about new offer',
          );
        } catch (e) {
          debugPrint('DriverClientRequestsBloc: error notifying socket: $e');
        }
      },
    );
  }

  Future<void> _onRemoveClientRequestLocally(
    RemoveClientRequestLocally event,
    Emitter<DriverClientRequestsState> emit,
  ) async {
    try {
      final currentList = state.clientRequestResponseEntity ?? [];
      final filtered = currentList
          .where((r) => (r.id.toString()) != event.idClientRequest)
          .toList();

      // Sólo emitir si realmente hubo cambio (evitamos re-renders inútiles)
      if (filtered.length != currentList.length) {
        emit(state.copyWith(clientRequestResponseEntity: filtered));
        debugPrint(
          'DriverClientRequestsBloc: removed request ${event.idClientRequest} locally',
        );
      } else {
        debugPrint(
          'DriverClientRequestsBloc: request ${event.idClientRequest} not found locally',
        );
      }
    } catch (e, st) {
      debugPrint('Error in _onRemoveClientRequestLocally: $e\n$st');
    }
  }
}
