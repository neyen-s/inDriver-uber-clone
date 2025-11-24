part of 'driver_map_trip_bloc.dart';

sealed class DriverMapTripEvent extends Equatable {
  const DriverMapTripEvent();

  @override
  List<Object> get props => [];
}

class GetClientRequestById extends DriverMapTripEvent {
  const GetClientRequestById(this.idClientRequest);
  final int idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}
