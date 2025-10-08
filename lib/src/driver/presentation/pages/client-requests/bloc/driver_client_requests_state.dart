part of 'driver_client_requests_bloc.dart';

class DriverClientRequestsState extends Equatable {
  const DriverClientRequestsState({
    this.clientRequestResponseEntity,
    this.isLoading = false,
    this.hasError = false,
  });
  final List<ClientRequestResponseEntity>? clientRequestResponseEntity;
  final bool isLoading;
  final bool hasError;

  DriverClientRequestsState copyWith({
    List<ClientRequestResponseEntity>? clientRequestResponseEntity,
    bool? isLoading,
    bool? hasError,
  }) {
    return DriverClientRequestsState(
      clientRequestResponseEntity:
          clientRequestResponseEntity ?? this.clientRequestResponseEntity,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [clientRequestResponseEntity, isLoading, hasError];
}
