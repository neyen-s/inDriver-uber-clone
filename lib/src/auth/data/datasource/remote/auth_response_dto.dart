import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';

class AuthResponseDTO extends AuthResponseEntity {
  const AuthResponseDTO({
    required super.user,
    required super.token,
    super.refreshToken,
  });

  factory AuthResponseDTO.fromEntity(AuthResponseEntity entity) {
    return AuthResponseDTO(
      user: UserDTO.fromEntity(entity.user),
      token: entity.token,
      refreshToken: entity.refreshToken,
    );
  }

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    final rawToken = json['token'] as String;
    final cleanedToken = rawToken.replaceFirst('Bearer ', '');
    return AuthResponseDTO(
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
      token: cleanedToken,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': (user as UserDTO).toJson(),
    'token': token,
    'refreshToken': refreshToken,
  };

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token,'
        ' refreshToken: $refreshToken)';
  }
}
