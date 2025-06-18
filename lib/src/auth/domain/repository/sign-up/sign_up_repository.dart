import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class SignUpRepository {
  const SignUpRepository();

  /// Registers a new user with the provided [email] and [password].
  ///
  /// Returns a [ResultFuture] containing
  /// a [UserEntity] on success or an error on failure.
  ResultFuture<UserEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
}
