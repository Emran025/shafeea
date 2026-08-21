import '../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final bool isEmailVerified;
  final String genderScope;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.isEmailVerified = false,
    this.genderScope = 'all',
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      genderScope: json['gender_scope'] ?? 'all',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? '',
      avatar: map['avatar'],
      phone: map['phone'] ?? '',
      isEmailVerified: map['is_email_verified'] as bool? ?? false,
      genderScope: map['gender_scope'] ?? 'all',
      roles: map['roles'] != null ? map['roles'].toString().split(',') : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'is_email_verified': isEmailVerified,
      'gender_scope': genderScope,
      'roles': roles,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'is_email_verified': isEmailVerified,
      'gender_scope': genderScope,
      'roles': roles.join(','),
    };
  }

  UserEntity toUserEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
      isEmailVerified: isEmailVerified,
      genderScope: genderScope,
      roles: roles,
    );
  }
}
