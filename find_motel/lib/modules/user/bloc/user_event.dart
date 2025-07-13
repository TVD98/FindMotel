abstract class UserEvent {}

class LoadUserProfile extends UserEvent {
  final String email;

  LoadUserProfile(this.email);
}
