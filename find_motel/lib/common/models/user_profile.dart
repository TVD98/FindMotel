enum UserRole {
  admin,
  sale,
}

class UserProfile {
  final String id;
  final String? name;
  final String email;
  final String? avatar;
  final UserRole role;

  UserProfile({
    required this.id,
    this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      avatar: map['avatar'],
      role: UserRole.values.firstWhere((e) => e.name == map['role'], orElse: () => UserRole.sale),
    );
  }
}