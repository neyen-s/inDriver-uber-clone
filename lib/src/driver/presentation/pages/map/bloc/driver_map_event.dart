part of 'driver_map_bloc.dart';

sealed class DriverMapEvent extends Equatable {
  const DriverMapEvent();

  @override
  List<Object> get props => [];
}

class DriverLocationRequested extends DriverMapEvent {
  const DriverLocationRequested();
}

class DriverMapMoveToCurrentLocationRequested extends DriverMapEvent {}

class DriverLocationStreamStarted extends DriverMapEvent {
  const DriverLocationStreamStarted();
}

class DriverLocationSentToSocket extends DriverMapEvent {
  const DriverLocationSentToSocket(this.lat, this.lng);
  final double lat;
  final double lng;
  @override
  List<Object> get props => [lat, lng];
}

class AddDriverPositionMarker extends DriverMapEvent {
  const AddDriverPositionMarker(this.idSocket, this.id, this.lat, this.lng);
  final String idSocket;
  final int id;
  final double lat;
  final double lng;
  @override
  List<Object> get props => [idSocket, id, lat, lng];
}
