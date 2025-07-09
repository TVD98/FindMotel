class ProfileState {
  final String? name;
  final String? avatar;
  final String? email;
  ProfileState({this.name, this.avatar, this.email});

  ProfileState copyWith({String? name, String? avatar, String? email}) {
    return ProfileState(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
    );
  }
}
