import 'package:indriver_uber_clone/core/mappers/user_mapper.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/auth_response_dto.dart';
import 'package:indriver_uber_clone/src/auth/domain/entities/auth_response_entity.dart';

extension AuthResponseEntityMapper on AuthResponseEntity {
  AuthResponseDTO toDto() {
    return AuthResponseDTO(
      user: user.toDto(),
      token: token,
      refreshToken: refreshToken,
    );
  }
}

extension AuthResponseDTOMapper on AuthResponseDTO {
  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      user: user,
      token: token,
      refreshToken: refreshToken,
    );
  }
}
