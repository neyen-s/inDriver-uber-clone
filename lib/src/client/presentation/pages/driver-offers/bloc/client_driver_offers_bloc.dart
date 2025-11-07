import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_usecases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

part 'client_driver_offers_event.dart';
part 'client_driver_offers_state.dart';

class ClientDriverOffersBloc
    extends Bloc<ClientDriverOffersEvent, ClientDriverOffersState> {
  ClientDriverOffersBloc(this.clientRequestsUsecases, this.socketBloc)
    : super(const ClientDriverOffersState()) {
    on<GetDriverTripOffersByClientRequest>(
      _onGetDriverTripOffersByClientRequest,
    );
    on<AsignDriver>(_onAsignDriver);

    _socketSub = socketBloc.stream.listen(_handleSocketState);
  }

  final ClientRequestsUsecases clientRequestsUsecases;
  final SocketBloc socketBloc;
  StreamSubscription? _socketSub;

  void _handleSocketState(SocketState s) {
    if (s is SocketDriverOfferArrived) {
      final socketId = s.idClientRequest;
      final currentId = state.idClientRequest;

      if (currentId == null) {
        return;
      }

      if (socketId == currentId.toString()) {
        add(GetDriverTripOffersByClientRequest(currentId));
      }
    }
  }

  @override
  Future<void> close() async {
    await _socketSub?.cancel();
    return super.close();
  }

  Future<void> _onGetDriverTripOffersByClientRequest(
    GetDriverTripOffersByClientRequest event,
    Emitter<ClientDriverOffersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final response = await clientRequestsUsecases
        .getDriverTripOffersByClientRequestUseCase(event.idClientRequest);

    return response.fold(
      (failure) {
        debugPrint('bloc failure ---> $failure');
        emit(state.copyWith(isLoading: false, hasError: true));
      },
      (request) {
        emit(
          state.copyWith(
            isLoading: false,
            hasError: false,
            driverTripRequestEntity: request,
            idClientRequest: event.idClientRequest,
          ),
        );
      },
    );
  }

  Future<void> _onAsignDriver(
    AsignDriver event,
    Emitter<ClientDriverOffersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final response = await clientRequestsUsecases.updateDriverAssignedUseCase(
      event.idClientRequest,
      event.idDriver,
      event.fareAssigned,
    );

    return response.fold(
      (failure) {
        debugPrint('bloc failure ---> $failure');
        emit(state.copyWith(isLoading: false, hasError: true));
      },
      (request) {
        debugPrint('bloc success request ---> $request');
        emit(
          state.copyWith(
            driverAssigned: request,
            isLoading: false,
            hasError: false,
          ),
        );
      },
    );
  }
}
