class UserRoleEntity {
  UserRoleEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.route,
  });
  factory UserRoleEntity.fromJson(Map<String, dynamic> json) {
    return UserRoleEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      route: json['route'] as String,
    );
  }
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
