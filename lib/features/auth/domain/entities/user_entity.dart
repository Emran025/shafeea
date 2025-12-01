
class UserEntity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
  });
}
