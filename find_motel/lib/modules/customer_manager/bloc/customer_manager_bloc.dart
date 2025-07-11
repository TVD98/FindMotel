import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_state.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_event.dart';
import 'package:find_motel/services/customer/customer_service.dart';

class CustomerManagerBloc
    extends Bloc<CustomerManagerEvent, CustomerManagerState> {
  final ICustomerService _customerService;

  CustomerManagerBloc({ICustomerService? customerService})
      : _customerService = customerService ?? FirestoreService(),
        super(const CustomerManagerState()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerManagerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerManagerStatus.loading));
    final (customers, error) = await _customerService.fetchCustomers();
    if (error != null) {
      emit(state.copyWith(
        status: CustomerManagerStatus.failure,
        errorMessage: error,
      ));
    } else {
      emit(state.copyWith(
        status: CustomerManagerStatus.success,
        customers: customers ?? [],
      ));
    }
  }
}
