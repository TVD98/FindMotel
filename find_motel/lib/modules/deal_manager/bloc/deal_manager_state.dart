import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/deal.dart';

enum DealManagerStatus { initial, loading, success, failure }

class DealManagerState extends Equatable {
  final DealManagerStatus status;
  final List<Deal> deals;
  final String? errorMessage;

  const DealManagerState({
    this.status = DealManagerStatus.initial,
    this.deals = const [],
    this.errorMessage,
  });

  DealManagerState copyWith({
    DealManagerStatus? status,
    List<Deal>? deals,
    String? errorMessage,
  }) {
    return DealManagerState(
      status: status ?? this.status,
      deals: deals ?? this.deals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, deals, errorMessage];
}