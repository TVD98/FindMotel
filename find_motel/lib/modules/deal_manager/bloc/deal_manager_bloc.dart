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
    on<DeleteDealEvent>(_deleteDeal);
  }

  Future<void> _onLoadDeals(
    LoadDealsEvent event,
    Emitter<DealManagerState> emit,
  ) async {
    emit(state.copyWith(status: DealManagerStatus.loading));
    final userProfile = AppDataManager().currentUserProfile;
    final (deals, error) = await _customerService.fetchDeals(
      saleId: userProfile?.email ?? '',
      motelId: event.motelId,
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
    bool isExist = false;
    final updatedDeals = state.deals.map((deal) {
      if (deal.id == event.deal.id) {
        isExist = true;
        return event.deal;
      }
      return deal;
    }).toList();
    if (!isExist) {
      updatedDeals.insert(0, event.deal);
    }
    emit(
      state.copyWith(deals: updatedDeals, status: DealManagerStatus.success),
    );
  }

  Future<void> _deleteDeal(
    DeleteDealEvent event,
    Emitter<DealManagerState> emit,
  ) async {
    emit(state.copyWith(status: DealManagerStatus.loading));
    final (result, error) = await _customerService.deleteDeal(event.dealId);
    if (result) {
      final updatedDeals = state.deals
          .where((deal) => deal.id != event.dealId)
          .toList();
      emit(
        state.copyWith(deals: updatedDeals, status: DealManagerStatus.success),
      );
    } else {
      emit(
        state.copyWith(
          status: DealManagerStatus.failure,
          errorMessage: error ?? 'Xóa lịch hẹn thất bại',
        ),
      );
    }
  }
}
