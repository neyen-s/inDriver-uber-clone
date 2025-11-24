part of 'driver_map_trip_bloc.dart';

class DriverMapTripState extends Equatable {
  const DriverMapTripState({
    this.clientRequestEntity,
    this.idClientRequest,
    this.isLoading,
    this.errorMessage,
  });

  final ClientRequestResponseEntity? clientRequestEntity;
  final int? idClientRequest;
  final bool? isLoading;
  final String? errorMessage;

  DriverMapTripState copyWith({
    ClientRequestResponseEntity? clientRequestEntity,
    int? idClientRequest,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DriverMapTripState(
      clientRequestEntity: clientRequestEntity ?? this.clientRequestEntity,
      idClientRequest: idClientRequest ?? this.idClientRequest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    clientRequestEntity,
    idClientRequest,
    isLoading,
    errorMessage,
  ];
}
