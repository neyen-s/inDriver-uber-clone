import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';

class AuthResponseEntity {
  const AuthResponseEntity({
    required this.user,
    required this.token,
    this.refreshToken,
  });

  AuthResponseEntity.empty()
    : user = const UserEntity.empty(),
      token = '',
      refreshToken = null;

  final UserEntity user;
  final String token;
  final String? refreshToken;

  AuthResponseEntity copyWith({
    UserEntity? user,
    String? token,
    String? refreshToken,
  }) {
    return AuthResponseEntity(
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token,'
        ' refreshToken: $refreshToken)';
  }
}
