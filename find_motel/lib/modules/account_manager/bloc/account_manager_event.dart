import 'package:find_motel/common/models/user_profile.dart';

abstract class AccountManagerEvent {}

class LoadAccountsEvent extends AccountManagerEvent {}

class UpdateAccountRoleEvent extends AccountManagerEvent {
  final String userId;
  final UserRole newRole;

  UpdateAccountRoleEvent({required this.userId, required this.newRole});
}

class DeleteAccountEvent extends AccountManagerEvent {
  final String userId;

  DeleteAccountEvent({required this.userId});
}
