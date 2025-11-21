import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/domain/entities/client_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

abstract class ClientRequestRepository {
  ResultFuture<TimeAndDistanceValuesEntity> getTimeAndDistanceClientRequests(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  );

  ResultFuture<int> createClientRequest(
    ClientRequestEntity clientRequestEntity,
  );

  ResultFuture<List<ClientRequestResponseEntity>> getNearbyTripRequest(
    double driverLat,
    double driverLng,
  );

  ResultFuture<List<DriverTripRequestEntity>>
  getDriverTripOffersByClientRequest(int idClientRequest);

  ResultFuture<bool> updateDriverAssigned(
    int idClientRequest,
    int idDriver,
    double fareAssigned,
  );

  ResultFuture<ClientRequestResponseEntity> getClientRequestById(
    int idClientRequest,
  );
}
