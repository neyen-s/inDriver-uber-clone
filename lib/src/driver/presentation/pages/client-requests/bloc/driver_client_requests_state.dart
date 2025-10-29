part of 'driver_client_requests_bloc.dart';

class DriverClientRequestsState extends Equatable {
  const DriverClientRequestsState({
    this.clientRequestResponseEntity,
    this.idDriver,
    this.isLoading = false,
    this.hasError = false,
    this.driverTripRequest,
    this.errorMessage,
  });
  final List<ClientRequestResponseEntity>? clientRequestResponseEntity;
  final int? idDriver;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final DriverTripRequestEntity? driverTripRequest;

  DriverClientRequestsState copyWith({
    List<ClientRequestResponseEntity>? clientRequestResponseEntity,
    int? idDriver,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    DriverTripRequestEntity? driverTripRequest,
  }) {
    return DriverClientRequestsState(
      clientRequestResponseEntity:
          clientRequestResponseEntity ?? this.clientRequestResponseEntity,
      idDriver: idDriver ?? this.idDriver,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      driverTripRequest: driverTripRequest ?? this.driverTripRequest,
    );
  }

  @override
  List<Object?> get props => [
    clientRequestResponseEntity,
    idDriver,
    isLoading,
    hasError,
    errorMessage,
    driverTripRequest,
  ];
}
