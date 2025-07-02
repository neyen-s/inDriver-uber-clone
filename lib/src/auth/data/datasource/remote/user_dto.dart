import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_role_dto.dart';

class UserDTO extends UserEntity {
  UserDTO({
    required super.id,
    required super.name,
    required super.lastname,
    required super.email,
    required super.phone,
    required super.image,
    required super.notificationToken,
    required super.roles,
  });

  const UserDTO.empty() : super.empty();

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      image: json['image'] as String?,
      notificationToken: json['notificationToken'] as String?,

      roles: (json['roles'] as List<dynamic>)
          .map((e) => UserRoleDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory UserDTO.fromEntity(UserEntity entity) {
    return UserDTO(
      id: entity.id,
      name: entity.name,
      lastname: entity.lastname,
      email: entity.email,
      phone: entity.phone,
      image: entity.image,
      notificationToken: entity.notificationToken,
      roles: entity.roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'image': image,
      'notificationToken': notificationToken,
      'roles': roles
          .map((role) => UserRoleDTO.fromEntity(role).toJson())
          .toList(),
    };
  }

  @override
  String toString() {
    return 'UserDTO(id: $id, name: $name, lastname: $lastname, email: $email,'
        ' phone: $phone, image: $image, '
        'notificationToken: $notificationToken, roles: $roles)';
  }

  /*   @override
  List<Object?> get props => [
    id,s
    name,
    lastname,
    email,
    phone,
    image,
    notificationToken,
    roles,
  ]; */
}
