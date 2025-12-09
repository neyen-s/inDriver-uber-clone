import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/domain/usecases/client-requests/client_requests_use_cases.dart';
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
    on<EmitNewClientRequestSocketIO>(_onEmitNewClientRequestSocketIO);
    on<EmitNewDriverAssignedSocketIO>(_onEmitNewDriverAssignedSocketIO);

    _socketSub = socketBloc.stream.listen(_handleSocketState);
  }

  final ClientRequestsUsecases clientRequestsUsecases;
  final SocketBloc socketBloc;
  StreamSubscription<dynamic>? _socketSub;

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
        add(
          EmitNewClientRequestSocketIO(event.idClientRequest, event.idDriver),
        );
        /*         add(
          EmitNewDriverAssignedSocketIO(event.idClientRequest, event.idDriver),
        ); */
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

  void _onEmitNewClientRequestSocketIO(
    EmitNewClientRequestSocketIO event,
    Emitter<ClientDriverOffersState> emit,
  ) {
    try {
      socketBloc.add(
        SendDriverAssignedRequested(
          idDriver: event.idDriver,
          idClientRequest: event.idClientRequest.toString(),
        ),
      );
      debugPrint(
        '*******************************************ClientDriverOffersBloc: notified socket about driver assigned',
      );
    } catch (e) {
      debugPrint('ClientDriverOffersBloc: error notifying socket: $e');
    }
  }

  void _onEmitNewDriverAssignedSocketIO(
    EmitNewDriverAssignedSocketIO event,
    Emitter<ClientDriverOffersState> emit,
  ) {
    try {
      socketBloc.add(
        SocketDriverAssignedEvent(
          idDriver: event.idDriver.toString(),
          idClientRequest: event.idClientRequest.toString(),
        ),
      );
    } catch (e) {
      debugPrint('ClientDriverOffersBloc: error notifying socket: $e');
    }
  }
}
