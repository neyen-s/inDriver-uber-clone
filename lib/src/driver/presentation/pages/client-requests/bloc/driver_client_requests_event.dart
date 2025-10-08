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
