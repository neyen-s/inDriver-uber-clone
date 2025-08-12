part of 'driver_map_bloc.dart';

sealed class DriverMapState extends Equatable {
  const DriverMapState();

  @override
  List<Object> get props => [];
}

final class DriverMapInitial extends DriverMapState {}

class DriverMapLoading extends DriverMapState {}

class DriverMapPositionLoaded extends DriverMapState {
  const DriverMapPositionLoaded(this.position);
  final Position position;

  @override
  List<Object> get props => [position];
}

class DriverMapPositionWithMarker extends DriverMapState {
  const DriverMapPositionWithMarker(this.marker);
  final Marker marker;

  @override
  List<Object> get props => [marker];
}

class DriverMapError extends DriverMapState {
  const DriverMapError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
