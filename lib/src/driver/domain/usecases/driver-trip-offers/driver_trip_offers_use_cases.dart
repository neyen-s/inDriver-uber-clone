import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/create_driver_trip_request_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-trip-offers/get_driver_trip_request_use_case.dart';

class DriverTripOffersUseCases {
  DriverTripOffersUseCases({
    required this.createDriverTripOfferUseCase,
    required this.getDriverTripOffersUseCase,
  });

  final CreateDriverTripRequestUseCase createDriverTripOfferUseCase;
  final GetDriverTripRequestUseCase getDriverTripOffersUseCase;
}
