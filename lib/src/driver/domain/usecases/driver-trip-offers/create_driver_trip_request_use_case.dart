import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_trip_request_repository.dart';

class CreateDriverTripRequestUseCase {
  const CreateDriverTripRequestUseCase(this.repository);

  final DriverTripRequestRepository repository;

  ResultFuture<void> call(DriverTripRequestEntity driverTripRequest) {
    return repository.createDriverTripRequests(driverTripRequest);
  }
}
