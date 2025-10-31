part of 'client_driver_offers_bloc.dart';

class ClientDriverOffersState extends Equatable {
  const ClientDriverOffersState({
    this.driverTripRequestEntity,
    this.idDriver,
    this.idClientRequest,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<DriverTripRequestEntity>? driverTripRequestEntity;
  final int? idDriver;
  final int? idClientRequest;
  final bool isLoading;
  final bool hasError;
  ClientDriverOffersState copyWith({
    List<DriverTripRequestEntity>? driverTripRequestEntity,
    int? idDriver,
    int? idClientRequest,
    bool? isLoading,
    bool? hasError,
  }) {
    return ClientDriverOffersState(
      driverTripRequestEntity:
          driverTripRequestEntity ?? this.driverTripRequestEntity,
      idDriver: idDriver ?? this.idDriver,
      idClientRequest: idClientRequest ?? this.idClientRequest,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [
    driverTripRequestEntity,
    idDriver,
    isLoading,
    hasError,
  ];
}
