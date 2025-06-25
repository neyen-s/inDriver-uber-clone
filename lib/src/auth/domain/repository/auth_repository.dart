import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  const AuthRepository();

  /// Signs in a user with the provided [email] and [password].
  ///
  /// Returns a [ResultFuture] containing
  /// a [UserEntity] on success or an error on failure.

  ResultFuture<AuthResponseEntity> signIn({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided
  ///  [name], [lastName], [email], [phone], and [password].

  ResultFuture<AuthResponseEntity> signUp({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });

  ResultFuture<AuthResponseDTO> getUserSession();

  ResultFuture<void> saveUserSession(AuthResponseEntity authResponse);

  ResultFuture<void> signOut();
}
