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
