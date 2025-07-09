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
