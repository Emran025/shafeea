
class UserEntity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final bool isEmailVerified;
  final String genderScope;
  final List<String> roles;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.isEmailVerified = false,
    this.genderScope = 'all',
    this.roles = const [],
  });
}
