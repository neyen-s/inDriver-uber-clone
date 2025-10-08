import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class GetNearbyTripRequestUseCase {
  GetNearbyTripRequestUseCase(this.repository);

  final ClientRequestRepository repository;

  ResultFuture<List<ClientRequestResponseEntity>> call(
    double driverLat,
    double driverLng,
  ) => repository.getNearbyTripRequest(driverLat, driverLng);
}
