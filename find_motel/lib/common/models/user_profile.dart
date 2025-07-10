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

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    UserRole? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }
}