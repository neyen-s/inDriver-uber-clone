import 'package:indriver_uber_clone/core/domain/usecases/client-requests/get_time_and_distance_values_usecase.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/create_client_request_use_case.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/get_driver_trip_offers_by_client_request_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/client-requests/get_nearby_trip_request_use_case.dart';

class ClientRequestsUsecases {
  ClientRequestsUsecases({
    required this.getTimeAndDistanceValuesUsecase,
    required this.createClientRequestUseCase,
    required this.getNearbyTripRequestUseCase,
    required this.getDriverTripOffersByClientRequestUseCase,
  });

  final GetTimeAndDistanceValuesUsecase getTimeAndDistanceValuesUsecase;
  final CreateClientRequestUseCase createClientRequestUseCase;
  final GetNearbyTripRequestUseCase getNearbyTripRequestUseCase;
  final GetDriverTripOffersByClientRequestUseCase
  getDriverTripOffersByClientRequestUseCase;
}
