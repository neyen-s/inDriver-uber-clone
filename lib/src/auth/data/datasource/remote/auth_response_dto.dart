import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
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
    final rawToken =
        (json['token'] as String?) ?? (json['access'] as String?) ?? '';
    final cleanedToken = rawToken.replaceFirst('Bearer ', '');
    final rawRefresh =
        (json['refreshToken'] as String?) ??
        (json['refresh'] as String?) ??
        (json['refresh_token'] as String?);

    return AuthResponseDTO(
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
      token: cleanedToken,
      refreshToken: rawRefresh,
    );
  }

  @override
  AuthResponseDTO copyWith({
    UserEntity? user,
    String? token,
    String? refreshToken,
  }) {
    final userDto = user == null
        ? (this.user is UserDTO
              ? this.user as UserDTO
              : UserDTO.fromEntity(this.user))
        : (user is UserDTO ? user : UserDTO.fromEntity(user));
    return AuthResponseDTO(
      user: userDto,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': (user as UserDTO).toJson(),
    'token': token,
    'refresh': refreshToken,
  };

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token,'
        ' refreshToken: $refreshToken)';
  }
}
