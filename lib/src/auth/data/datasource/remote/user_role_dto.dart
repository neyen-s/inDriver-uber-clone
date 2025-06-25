import 'package:indriver_uber_clone/src/auth/domain/entities/user_role_entity.dart';

class UserRoleDTO extends UserRoleEntity {
  UserRoleDTO({
    required super.id,
    required super.name,
    required super.image,
    required super.route,
  });

  factory UserRoleDTO.fromJson(Map<String, dynamic> json) {
    return UserRoleDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      route: json['route'] as String,
    );
  }

  factory UserRoleDTO.fromEntity(UserRoleEntity entity) {
    return UserRoleDTO(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      route: entity.route,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'route': route};
  }
}
