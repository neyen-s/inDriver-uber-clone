part of 'client_driver_offers_bloc.dart';

sealed class ClientDriverOffersEvent extends Equatable {
  const ClientDriverOffersEvent();

  @override
  List<Object> get props => [];
}

class GetDriverTripOffersByClientReques extends ClientDriverOffersEvent {
  const GetDriverTripOffersByClientReques(this.idClientRequest);
  final int idClientRequest;
}
