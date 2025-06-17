import 'package:indriver_uber_clone/src/auth/domain/entities/user_entity.dart';

class AuthResponseEntity {
  const AuthResponseEntity({required this.user, required this.token});

  final UserEntity user;
  final String token;

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token)';
  }
}
