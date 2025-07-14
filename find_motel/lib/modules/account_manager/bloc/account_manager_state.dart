import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/user_profile.dart';

enum AccountManagerStatus { initial, loading, success, failure }

class AccountManagerState extends Equatable {
  final AccountManagerStatus status;
  final List<UserProfile> accounts;
  final String? errorMessage;

  const AccountManagerState({
    this.status = AccountManagerStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  AccountManagerState copyWith({
    AccountManagerStatus? status,
    List<UserProfile>? accounts,
    String? errorMessage,
  }) {
    return AccountManagerState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}
