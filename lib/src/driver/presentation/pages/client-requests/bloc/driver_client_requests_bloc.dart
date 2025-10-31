import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
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
    //subscribe to socketBloc stream and refresh when
    // a new client request arrives
    _socketBlocSub = socketBloc.stream.listen((socketState) {
      if (socketState is SocketClientRequestCreated) {
        debugPrint(
          'DriverClientRequestsBloc: detected new client'
          ' request via SocketBloc -> refreshing list',
        );
        add(const GetNearbyTripRequestEvent());
      }
    });
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

    response.fold((l) => emit(state.copyWith(isLoading: false, hasError: true)), (
      r,
    ) {
      emit(state.copyWith(isLoading: false, hasError: false));
      // NOTIFY SOCKET: enviar nueva oferta para que backend la reemita al cliente
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
        debugPrint('DriverClientRequestsBloc: notified socket about new offer');
      } catch (e) {
        debugPrint('DriverClientRequestsBloc: error notifying socket: $e');
      }
    });
  }
}
