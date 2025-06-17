import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class SignInRepository {
  const SignInRepository();

  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  });
}
