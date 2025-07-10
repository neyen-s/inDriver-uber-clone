part of 'client_map_seeker_bloc.dart';

sealed class ClientMapSeekerEvent extends Equatable {
  const ClientMapSeekerEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentPositionRequested extends ClientMapSeekerEvent {}

class LoadCurrentLocationWithMarkerRequested extends ClientMapSeekerEvent {
  const LoadCurrentLocationWithMarkerRequested();
}

final class MapMoved extends ClientMapSeekerEvent {
  const MapMoved(this.target);
  final LatLng target;

  @override
  List<Object> get props => [target];
}

final class MapIdle extends ClientMapSeekerEvent {
  const MapIdle();
}

final class GetAddressFromLatLng extends ClientMapSeekerEvent {
  const GetAddressFromLatLng(this.latLng);
  final LatLng latLng;

  @override
  List<Object> get props => [latLng];
}
