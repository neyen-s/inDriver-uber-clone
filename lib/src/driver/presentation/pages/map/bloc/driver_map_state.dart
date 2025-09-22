part of 'driver_map_bloc.dart';

sealed class DriverMapState extends Equatable {
  const DriverMapState();

  @override
  List<Object?> get props => [];
}

final class DriverMapInitial extends DriverMapState {}

class DriverMapLoading extends DriverMapState {}

class DriverMapLoaded extends DriverMapState {
  const DriverMapLoaded({
    required this.position,
    required this.markers,
    this.idDriver,
    this.isLoading = false,
  });

  final Position? position;
  final List<Marker> markers;
  final int? idDriver;
  final bool isLoading; //TODO optional

  DriverMapLoaded copyWith({
    Position? position,
    List<Marker>? markers,
    int? idDriver,
    bool? isLoading,
  }) {
    return DriverMapLoaded(
      position: position ?? this.position,
      markers: markers ?? this.markers,
      idDriver: idDriver ?? this.idDriver,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [position, markers, idDriver, isLoading];
}

class DriverMapError extends DriverMapState {
  const DriverMapError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
