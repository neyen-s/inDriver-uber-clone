import 'package:indriver_uber_clone/src/auth/domain/entities/user_role_entity.dart';

class UserEntity {
  UserEntity({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.roles,
    this.image,
    this.notificationToken,
  });

  const UserEntity.empty()
    : id = 0,
      name = '',
      lastname = '',
      email = '',
      phone = '',
      image = null,
      notificationToken = null,
      roles = const [];
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String? image;
  final String? notificationToken;
  final List<UserRoleEntity> roles;

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, lastname: $lastname,'
        ' email: $email, phone: $phone, image: $image, '
        ' notificationToken: $notificationToken, roles: $roles)';
  }
}
