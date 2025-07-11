import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_state.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_event.dart';

class CustomerManagerBloc
    extends Bloc<CustomerManagerEvent, CustomerManagerState> {
  final IUserDataService _userDataService;

  CustomerManagerBloc({IUserDataService? userDataService})
    : _userDataService = userDataService ?? FirestoreService(),
      super(const CustomerManagerState()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerManagerState> emit,
  ) async {
    try {
      emit(state.copyWith(status: CustomerManagerStatus.loading));
      final result = await _userDataService.getAllUsers();
      final customers = result.users;
      final currentUser = AppDataManager().currentUserProfile;
      // Filter out the current user and only show customers (you might want to adjust this filter)
      customers?.removeWhere(
        (element) =>
            element.email == currentUser?.email || element.role != 'customer',
      );
      emit(
        state.copyWith(
          status: CustomerManagerStatus.success,
          customers: customers ?? [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerManagerStatus.failure,
          errorMessage: 'Failed to load customers: ${e.toString()}',
        ),
      );
    }
  }
}
