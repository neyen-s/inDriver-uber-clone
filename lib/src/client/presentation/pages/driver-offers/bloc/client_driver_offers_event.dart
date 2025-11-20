part of 'client_driver_offers_bloc.dart';

sealed class ClientDriverOffersEvent extends Equatable {
  const ClientDriverOffersEvent();

  @override
  List<Object> get props => [];
}

class GetDriverTripOffersByClientRequest extends ClientDriverOffersEvent {
  const GetDriverTripOffersByClientRequest(this.idClientRequest);
  final int idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}

class AsignDriver extends ClientDriverOffersEvent {
  const AsignDriver({
    required this.idDriver,
    required this.idClientRequest,
    required this.fareAssigned,
  });
  final int idDriver;
  final int idClientRequest;
  final double fareAssigned;

  @override
  List<Object> get props => [idDriver, idClientRequest, fareAssigned];
}

class EmitNewClientRequestSocketIO extends ClientDriverOffersEvent {
  const EmitNewClientRequestSocketIO(this.idClientRequest, this.idDriver);
  final int idClientRequest;
  final int idDriver;

  @override
  List<Object> get props => [idClientRequest, idDriver];
}

class EmitNewDriverAssignedSocketIO extends ClientDriverOffersEvent {
  const EmitNewDriverAssignedSocketIO(this.idClientRequest, this.idDriver);
  final int idClientRequest;
  final int idDriver;

  @override
  List<Object> get props => [idClientRequest, idDriver];
}
