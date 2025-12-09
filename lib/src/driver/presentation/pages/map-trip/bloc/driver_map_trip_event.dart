part of 'driver_map_trip_bloc.dart';

sealed class DriverMapTripEvent extends Equatable {
  const DriverMapTripEvent();

  @override
  List<Object?> get props => [];
}

class GetClientRequestById extends DriverMapTripEvent {
  const GetClientRequestById(this.idClientRequest);
  final int idClientRequest;

  @override
  List<Object> get props => [idClientRequest];
}

final class DrawRouteForTrip extends DriverMapTripEvent {
  const DrawRouteForTrip({required this.origin, required this.destination});
  final LatLng origin;
  final LatLng destination;

  @override
  List<Object> get props => [origin, destination];
}

final class DriverLocationUpdated extends DriverMapTripEvent {
  const DriverLocationUpdated(this.lat, this.lng);
  final double lat;
  final double lng;

  @override
  List<Object> get props => [lat, lng];
}

final class StartLocationTracking extends DriverMapTripEvent {}

final class StopLocationTracking extends DriverMapTripEvent {}

class StartTrip extends DriverMapTripEvent {
  const StartTrip();
}

class ResetRoute extends DriverMapTripEvent {
  //TODO check utility later
  const ResetRoute();
}

class UpdateTripStatus extends DriverMapTripEvent {
  const UpdateTripStatus(this.status);
  final RoutePhases status;
  @override
  List<Object?> get props => [status];
}

class TripStatusReceivedFromSocketDriver extends DriverMapTripEvent {
  const TripStatusReceivedFromSocketDriver({required this.status});
  final String status;
  @override
  List<Object?> get props => [status];
}
