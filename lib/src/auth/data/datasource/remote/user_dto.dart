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
    int tryInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String tryString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    final rolesJson = json['roles'];
    final roles = <dynamic>[];
    if (rolesJson != null && rolesJson is List) {
      roles.addAll(rolesJson);
    }

    return UserDTO(
      id: tryInt(json['id']),
      name: tryString(json['name']),
      lastname: tryString(json['lastname']),
      email: tryString(json['email']),
      phone: tryString(json['phone']),
      image: tryString(json['image']),
      notificationToken: (json['notificationToken'] != null)
          ? tryString(json['notificationToken'])
          : '',
      roles: roles
          .map((e) {
            try {
              return UserRoleDTO.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<UserRoleDTO>()
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
}
