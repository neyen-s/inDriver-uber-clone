import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SaveUserSessionUseCase {
  SaveUserSessionUseCase({required this.authRepository});
  AuthRepository authRepository;

  ResultFuture<void> call(AuthResponseEntity authResponse) =>
      authRepository.saveUserSession(authResponse);
}
