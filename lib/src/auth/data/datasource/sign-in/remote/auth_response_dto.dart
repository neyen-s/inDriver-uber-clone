import 'package:indriver_uber_clone/src/auth/data/datasource/sign-in/remote/user_dto.dart';

class AuthResponseDTO {
  const AuthResponseDTO({required this.user, required this.token});

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  final UserDTO user;
  final String token;

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'token': token};

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: $token)';
  }
}
