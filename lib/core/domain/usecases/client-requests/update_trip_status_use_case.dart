import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class UpdateTripStatusUseCase
    extends UsecaseWithParams<void, UpdateTripStatusParams> {
  UpdateTripStatusUseCase(this._clientRequestRepository);
  final ClientRequestRepository _clientRequestRepository;

  @override
  ResultFuture<bool> call(UpdateTripStatusParams params) {
    return _clientRequestRepository.updateTripStatus(
      params.idClientRequest,
      params.status,
    );
  }
}

class UpdateTripStatusParams extends Equatable {
  const UpdateTripStatusParams({
    required this.idClientRequest,
    required this.status,
  });
  final int idClientRequest;
  final String status;

  @override
  List<Object?> get props => [idClientRequest, status];
}
