import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';

class AuthResponseDTO extends AuthResponseEntity {
  const AuthResponseDTO({required super.user, required super.token});

  factory AuthResponseDTO.fromEntity(AuthResponseEntity entity) {
    return AuthResponseDTO(
      user: UserDTO.fromEntity(entity.user), // Necesitas este también
      token: entity.token,
    );
  }

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': (user as UserDTO).toJson(),
    'token': token,
  };

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token)';
  }
}
