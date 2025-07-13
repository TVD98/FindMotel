import 'package:find_motel/common/models/user_profile.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserProfile userProfile;

  UserLoaded(this.userProfile);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
