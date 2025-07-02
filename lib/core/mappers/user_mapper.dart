import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';

extension UserEntityMapper on UserEntity {
  UserDTO toDto() {
    return UserDTO(
      id: id,
      name: name,
      lastname: lastname,
      email: email,
      phone: phone,
      image: image,
      notificationToken: notificationToken,
      roles: roles,
    );
  }
}

extension UserDTOMapper on UserDTO {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      lastname: lastname,
      email: email,
      phone: phone,
      image: image,
      notificationToken: notificationToken,
      roles: roles,
    );
  }
}
