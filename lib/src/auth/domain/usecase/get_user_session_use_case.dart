import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class GetUserSessionUseCase extends UsecaseWithoutParams<AuthResponseEntity> {
  GetUserSessionUseCase(this.authRepository);

  AuthRepository authRepository;

  @override
  ResultFuture<AuthResponseEntity> call() => authRepository.getUserSession();
}
