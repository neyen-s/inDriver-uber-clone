import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/domain/entities/client_request_entity.dart';

class CreateClientRequestUseCase
    extends UsecaseWithParams<void, CreateClientRequestParams> {
  CreateClientRequestUseCase(this._repository);
  final ClientRequestRepository _repository;

  @override
  ResultFuture<bool> call(CreateClientRequestParams params) {
    return _repository.createClientRequest(params.clientRequestEntity);
  }
}

class CreateClientRequestParams extends Equatable {
  const CreateClientRequestParams({required this.clientRequestEntity});

  final ClientRequestEntity clientRequestEntity;

  @override
  List<Object?> get props => [clientRequestEntity];
}
