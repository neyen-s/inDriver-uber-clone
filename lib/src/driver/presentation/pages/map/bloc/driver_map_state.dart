part of 'driver_map_bloc.dart';

sealed class DriverMapState extends Equatable {
  const DriverMapState();

  @override
  List<Object?> get props => [];
}

final class DriverMapInitial extends DriverMapState {}

class DriverMapLoading extends DriverMapState {}

class DriverMapLoaded extends DriverMapState {
  const DriverMapLoaded({required this.position, required this.markers});

  final Position? position;
  final List<Marker> markers; //marker list of all the drivers

  @override
  List<Object?> get props => [position, markers];
}

class DriverMapError extends DriverMapState {
  const DriverMapError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
