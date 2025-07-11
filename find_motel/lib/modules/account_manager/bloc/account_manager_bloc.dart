import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/modules/account_manager/bloc/account_manager_state.dart';
import 'package:find_motel/modules/account_manager/bloc/account_manager_event.dart';

class AccountManagerBloc
    extends Bloc<AccountManagerEvent, AccountManagerState> {
  final IUserDataService _userDataService;

  AccountManagerBloc({IUserDataService? userDataService})
    : _userDataService = userDataService ?? FirestoreService(),
      super(const AccountManagerState()) {
    on<LoadAccountsEvent>(_onLoadAccounts);
    on<UpdateAccountRoleEvent>(_onUpdateAccountRole);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onLoadAccounts(
    LoadAccountsEvent event,
    Emitter<AccountManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AccountManagerStatus.loading));
      final result = await _userDataService.getAllUsers();
      final accounts = result.users;
      final currentUser = AppDataManager().currentUserProfile;
      accounts?.removeWhere((element) => element.email == currentUser?.email);
      emit(
        state.copyWith(
          status: AccountManagerStatus.success,
          accounts: accounts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AccountManagerStatus.failure,
          errorMessage: 'Failed to load accounts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateAccountRole(
    UpdateAccountRoleEvent event,
    Emitter<AccountManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AccountManagerStatus.loading));
      final result = await _userDataService.updateUserRole(
        userId: event.userId,
        newRole: event.newRole,
      );
      if (result) {
        final updatedAccounts = List<UserProfile>.from(state.accounts);
        var updatedAccountIndex = updatedAccounts.indexWhere(
          (element) => element.id == event.userId,
        );
        updatedAccounts[updatedAccountIndex] =
            updatedAccounts[updatedAccountIndex].copyWith(role: event.newRole);
        emit(state.copyWith(accounts: updatedAccounts));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AccountManagerStatus.failure,
          errorMessage: 'Failed to update account role: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AccountManagerStatus.loading));
      final result = await _userDataService.deleteUser(event.userId);
      if (result) {
        final updatedAccounts = List<UserProfile>.from(state.accounts)
          ..removeWhere((e) => e.id == event.userId);
        emit(state.copyWith(accounts: updatedAccounts));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AccountManagerStatus.failure,
          errorMessage: 'Failed to delete account: ${e.toString()}',
        ),
      );
    }
  }
}
