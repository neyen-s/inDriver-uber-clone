import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SignOutUseCase extends UsecaseWithoutParams<void> {
  const SignOutUseCase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  ResultFuture<void> call() => authRepository.signOut();
}
