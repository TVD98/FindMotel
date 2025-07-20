import 'package:equatable/equatable.dart';

class SettingState extends Equatable {
  final String? name;
  final String? avatar;
  final String? email;
  final bool isSaving;
  final bool isSaved;

  const SettingState({
    this.name,
    this.avatar,
    this.email,
    this.isSaving = false,
    this.isSaved = false,
  });

  SettingState copyWith({
    String? name,
    String? avatar,
    String? email,
    bool? isSaving,
    bool? isSaved,
  }) {
    return SettingState(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [name, avatar, email, isSaving, isSaved];
}
