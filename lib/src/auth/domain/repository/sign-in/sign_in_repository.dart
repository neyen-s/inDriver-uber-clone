import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class SignInRepository {
  const SignInRepository();

  /// Signs in a user with the provided [email] and [password].
  ///
  /// Returns a [ResultFuture] containing
  /// a [UserEntity] on success or an error on failure.

  ResultFuture<UserEntity> signIn({
    required String email,
    required String password,
  });
}
