part of 'client_map_trip_bloc.dart';

class ClientMapTripState extends Equatable {
  const ClientMapTripState({
    this.isLoading = false,
    this.errorMessage,
    this.clientRequestResponse,
    this.origin,
    this.destination,
    this.originAddress,
    this.destinationAddress,
    this.polylines = const {},
    this.driverMarker,
    this.distanceKm,
    this.estimatedTripDurationSeconds,
    this.timeAndDistanceValues,
    this.isEstimated = false,
    this.routeDrawn = false,
    this.routePhases = RoutePhases.created,
  });

  final bool isLoading;
  final String? errorMessage;
  final ClientRequestResponseEntity? clientRequestResponse;
  final LatLng? origin;
  final LatLng? destination;
  final String? originAddress;
  final String? destinationAddress;
  final Map<PolylineId, Polyline> polylines;
  final Marker? driverMarker;
  final double? distanceKm;
  final int? estimatedTripDurationSeconds;
  final TimeAndDistanceValuesEntity? timeAndDistanceValues;
  final bool isEstimated;
  final bool routeDrawn;
  final RoutePhases routePhases;

  ClientMapTripState copyWith({
    bool? isLoading,
    String? errorMessage,

    ClientRequestResponseEntity? clientRequestResponse,
    LatLng? origin,
    LatLng? destination,
    String? originAddress,
    String? destinationAddress,
    Map<PolylineId, Polyline>? polylines,
    Marker? driverMarker,
    double? distanceKm,
    int? estimatedTripDurationSeconds,
    TimeAndDistanceValuesEntity? timeAndDistanceValues,
    bool? isEstimated,
    bool? routeDrawn,
    RoutePhases? routePhases,
  }) {
    return ClientMapTripState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      clientRequestResponse:
          clientRequestResponse ?? this.clientRequestResponse,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      polylines: polylines ?? this.polylines,
      driverMarker: driverMarker ?? this.driverMarker,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedTripDurationSeconds:
          estimatedTripDurationSeconds ?? this.estimatedTripDurationSeconds,
      timeAndDistanceValues:
          timeAndDistanceValues ?? this.timeAndDistanceValues,
      isEstimated: isEstimated ?? this.isEstimated,
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
    originAddress,
    destinationAddress,
    polylines,
    driverMarker,
    distanceKm,
    estimatedTripDurationSeconds,
    timeAndDistanceValues,
    isEstimated,
    routeDrawn,
    routePhases,
  ];
}
