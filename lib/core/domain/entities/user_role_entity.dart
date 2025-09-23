class UserRoleEntity {
  UserRoleEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.route,
  });

  const UserRoleEntity.empty() : id = '', name = '', image = '', route = '';

  final String id;
  final String name;
  final String image;
  final String route;

  @override
  String toString() {
    return 'UserRoleEntity(id: $id, name: $name, image: $image, route: $route)';
  }
}
