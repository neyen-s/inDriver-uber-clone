import 'package:indriver_uber_clone/core/usecase/usecase.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/repository/auth_repository.dart';

class SignOutUseCase extends UsecaseWithoutParams<void> {
  const SignOutUseCase({required this.authRepository});

  final AuthRepository authRepository;

  @override
  ResultFuture<void> call() => authRepository.signOut();
}
