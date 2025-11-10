part of 'driver_client_requests_bloc.dart';

sealed class DriverClientRequestsEvent extends Equatable {
  const DriverClientRequestsEvent();

  @override
  List<Object> get props => [];
}

class GetNearbyTripRequestEvent extends DriverClientRequestsEvent {
  const GetNearbyTripRequestEvent();

  @override
  List<Object> get props => [];
}

class CreateDriverTripRequestEvent extends DriverClientRequestsEvent {
  const CreateDriverTripRequestEvent({required this.driverTripRequestEntity});

  final DriverTripRequestEntity driverTripRequestEntity;

  @override
  List<Object> get props => [driverTripRequestEntity];
}

class FareOfferedChangeEvent extends DriverClientRequestsEvent {
  const FareOfferedChangeEvent({required this.fareOffered});

  final double fareOffered;

  @override
  List<Object> get props => [fareOffered];
}

class RemoveClientRequestLocally extends DriverClientRequestsEvent {
  const RemoveClientRequestLocally({required this.idClientRequest});
  final String idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}
