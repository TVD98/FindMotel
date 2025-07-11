import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/customer.dart';

enum CustomerManagerStatus { initial, loading, success, failure }

class CustomerManagerState extends Equatable {
  final CustomerManagerStatus status;
  final List<Customer> customers;
  final String? errorMessage;

  const CustomerManagerState({
    this.status = CustomerManagerStatus.initial,
    this.customers = const [],
    this.errorMessage,
  });

  CustomerManagerState copyWith({
    CustomerManagerStatus? status,
    List<Customer>? customers,
    String? errorMessage,
  }) {
    return CustomerManagerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, customers, errorMessage];
}
