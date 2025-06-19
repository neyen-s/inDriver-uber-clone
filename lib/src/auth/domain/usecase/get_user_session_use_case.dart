import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class GetUserSessionUseCase {
  GetUserSessionUseCase(this.authRepository);

  AuthRepository authRepository;

  ResultFuture<void> call() => authRepository.getUserSession();
}
