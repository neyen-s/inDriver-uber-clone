import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class UpdateDriverAssignedUseCase {
  UpdateDriverAssignedUseCase(this.clientRequestRepository);

  final ClientRequestRepository clientRequestRepository;

  ResultFuture<bool> call(
    int idClientRequest,
    int idDriver,
    double fareAssigned,
  ) async => clientRequestRepository.updateDriverAssigned(
    idClientRequest,
    idDriver,
    fareAssigned,
  );
}
