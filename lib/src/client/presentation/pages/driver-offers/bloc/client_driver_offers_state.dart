part of 'client_driver_offers_bloc.dart';

class ClientDriverOffersState extends Equatable {
  const ClientDriverOffersState({
    this.driverTripRequestEntity,
    this.idDriver,
    this.isLoading = false,
    this.hasError = false,
  });

  final List<DriverTripRequestEntity>? driverTripRequestEntity;
  final int? idDriver;
  final bool isLoading;
  final bool hasError;
  ClientDriverOffersState copyWith({
    List<DriverTripRequestEntity>? driverTripRequestEntity,
    int? idDriver,
    bool? isLoading,
    bool? hasError,
  }) {
    return ClientDriverOffersState(
      driverTripRequestEntity:
          driverTripRequestEntity ?? this.driverTripRequestEntity,
      idDriver: idDriver ?? this.idDriver,
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
