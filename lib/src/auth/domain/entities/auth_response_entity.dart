import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';

class AuthResponseEntity {
  const AuthResponseEntity({required this.user, required this.token});

  final UserEntity user;
  final String token;

  AuthResponseEntity copyWith({UserEntity? user, String? token}) {
    return AuthResponseEntity(
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token)';
  }
}
