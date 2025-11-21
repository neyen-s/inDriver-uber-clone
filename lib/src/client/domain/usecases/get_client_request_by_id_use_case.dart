import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class GetClientRequestByIdUseCase extends UsecaseWithParams<void, int> {
  GetClientRequestByIdUseCase(this._repository);
  final ClientRequestRepository _repository;

  @override
  ResultFuture<ClientRequestResponseEntity> call(int idClientRequest) {
    return _repository.getClientRequestById(idClientRequest);
  }
}
