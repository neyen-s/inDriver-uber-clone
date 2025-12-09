import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

class GetDriverTripOffersByClientRequestUseCase
    extends UsecaseWithParams<void, int> {
  const GetDriverTripOffersByClientRequestUseCase(this.repository);

  final ClientRequestRepository repository;

  @override
  ResultFuture<List<DriverTripRequestEntity>> call(int idClientRequest) {
    return repository.getDriverTripOffersByClientRequest(idClientRequest);
  }
}
