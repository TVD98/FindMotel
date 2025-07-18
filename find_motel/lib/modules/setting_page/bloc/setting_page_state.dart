import 'package:equatable/equatable.dart';

class SettingState extends Equatable {
  final String? name;
  final String? avatar;
  final String? email;
  final bool isSaving;

  const SettingState({
    this.name,
    this.avatar,
    this.email,
    this.isSaving = false,
  });

  SettingState copyWith({
    String? name,
    String? avatar,
    bool? isSaving,
    String? email,
  }) {
    return SettingState(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isSaving: isSaving ?? this.isSaving,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [name, avatar, email, isSaving];
}