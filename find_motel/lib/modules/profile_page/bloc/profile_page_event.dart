import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final UserProfile? userProfile;

  const LoadProfileEvent({this.userProfile});
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}
