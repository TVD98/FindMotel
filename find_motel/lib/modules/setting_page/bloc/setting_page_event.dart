import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingEvent extends SettingEvent {
  const LoadSettingEvent();
}

class UsernameChanged extends SettingEvent {
  final String username;
  const UsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

class AvatarChanged extends SettingEvent {
  final String? avatar;
  const AvatarChanged(this.avatar);

  @override
  List<Object?> get props => [avatar];
}

class SaveSetting extends SettingEvent {}