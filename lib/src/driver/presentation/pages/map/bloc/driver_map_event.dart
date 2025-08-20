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

class ConnectSocketIo extends DriverMapEvent {
  const ConnectSocketIo();
}

class DisconnectSocketIo extends DriverMapEvent {
  const DisconnectSocketIo();
}

class DriverLocationSentToSocket extends DriverMapEvent {
  const DriverLocationSentToSocket(this.lat, this.lng);
  final double lat;
  final double lng;
  @override
  List<Object> get props => [lat, lng];
}
