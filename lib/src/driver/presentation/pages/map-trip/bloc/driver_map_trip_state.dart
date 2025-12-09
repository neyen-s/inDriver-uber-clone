part of 'driver_map_trip_bloc.dart';

class DriverMapTripState extends Equatable {
  const DriverMapTripState({
    this.isLoading = false,
    this.errorMessage,
    this.clientRequestResponse,
    this.origin,
    this.destination,
    this.polylines = const {},
    this.driverMarker,
    this.routeDrawn = false,
    this.routePhases = RoutePhases.created,
  });

  final bool isLoading;
  final String? errorMessage;
  final ClientRequestResponseEntity? clientRequestResponse;
  final LatLng? origin;
  final LatLng? destination;
  final Map<PolylineId, Polyline> polylines;
  final Marker? driverMarker;
  final bool routeDrawn;
  final RoutePhases routePhases;

  DriverMapTripState copyWith({
    bool? isLoading,
    String? errorMessage,
    ClientRequestResponseEntity? clientRequestResponse,
    LatLng? origin,
    LatLng? destination,
    Map<PolylineId, Polyline>? polylines,
    Marker? driverMarker,
    bool? routeDrawn,
    RoutePhases? routePhases,
  }) {
    return DriverMapTripState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      clientRequestResponse:
          clientRequestResponse ?? this.clientRequestResponse,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      polylines: polylines ?? this.polylines,
      driverMarker: driverMarker ?? this.driverMarker,
      routeDrawn: routeDrawn ?? this.routeDrawn,
      routePhases: routePhases ?? this.routePhases,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    clientRequestResponse,
    origin,
    destination,
    polylines,
    driverMarker,
    routeDrawn,
    routePhases,
  ];
}
