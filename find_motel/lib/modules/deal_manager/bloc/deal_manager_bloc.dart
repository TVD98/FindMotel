import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_manager_state.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_manager_event.dart';
import 'package:find_motel/services/customer/customer_service.dart';

class DealManagerBloc extends Bloc<DealManagerEvent, DealManagerState> {
  final ICustomerService _customerService;

  DealManagerBloc({ICustomerService? customerService})
    : _customerService = customerService ?? FirestoreService(),
      super(const DealManagerState()) {
    on<LoadDealsEvent>(_onLoadDeals);
    on<DealUpdatedEvent>(_updateDeal);
  }

  Future<void> _onLoadDeals(
    LoadDealsEvent event,
    Emitter<DealManagerState> emit,
  ) async {
    emit(state.copyWith(status: DealManagerStatus.loading));
    final userProfile = AppDataManager().currentUserProfile;
    final (deals, error) = await _customerService.fetchDeals(
      saleId: userProfile?.email ?? '',
    );
    if (error != null) {
      emit(
        state.copyWith(status: DealManagerStatus.failure, errorMessage: error),
      );
    } else {
      emit(
        state.copyWith(status: DealManagerStatus.success, deals: deals ?? []),
      );
    }
  }

  void _updateDeal(DealUpdatedEvent event, Emitter<DealManagerState> emit) {
    final updatedDeals = state.deals.map((deal) {
      if (deal.id == event.deal.id) {
        return event.deal;
      }
      return deal;
    }).toList();

    emit(
      state.copyWith(deals: updatedDeals, status: DealManagerStatus.success),
    );
  }
}
