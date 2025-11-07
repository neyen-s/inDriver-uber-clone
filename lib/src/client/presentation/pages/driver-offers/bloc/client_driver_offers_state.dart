part of 'client_driver_offers_bloc.dart';

class ClientDriverOffersState extends Equatable {
  const ClientDriverOffersState({
    this.driverTripRequestEntity,
    this.idDriver,
    this.idClientRequest,
    this.isLoading = false,
    this.hasError = false,
    this.driverAssigned = false,
  });

  final List<DriverTripRequestEntity>? driverTripRequestEntity;
  final int? idDriver;
  final int? idClientRequest;
  final bool isLoading;
  final bool hasError;
  final bool driverAssigned;
  ClientDriverOffersState copyWith({
    List<DriverTripRequestEntity>? driverTripRequestEntity,
    int? idDriver,
    int? idClientRequest,
    bool? isLoading,
    bool? hasError,
    bool? driverAssigned,
  }) {
    return ClientDriverOffersState(
      driverTripRequestEntity:
          driverTripRequestEntity ?? this.driverTripRequestEntity,
      idDriver: idDriver ?? this.idDriver,
      idClientRequest: idClientRequest ?? this.idClientRequest,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      driverAssigned: driverAssigned ?? this.driverAssigned,
    );
  }

  @override
  List<Object?> get props => [
    driverTripRequestEntity,
    idDriver,
    isLoading,
    hasError,
    driverAssigned,
  ];
}
