import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_request_entity.dart';

abstract class DriverTripRequestRepository {
  ResultFuture<void> createDriverTripRequests(
    DriverTripRequestEntity driverTripRequest,
  );
  ResultFuture<List<DriverTripRequestEntity>> getDriverTripRequests(
    int idDriver,
  );
}
