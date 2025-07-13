import 'package:find_motel/services/customer/customer_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'deal_detail_event.dart';
import 'deal_detail_state.dart';

class DealDetailBloc extends Bloc<DealDetailEvent, DealDetailState> {
  final ICustomerService _customerService;
  final IMotelsService _motelsService;

  DealDetailBloc({
    ICustomerService? customerService,
    IMotelsService? motelsService,
  }) : _customerService = customerService ?? FirestoreService(),
       _motelsService = motelsService ?? FirestoreService(),
       super(const DealDetailState()) {
    on<DealDetailStarted>((event, emit) {
      emit(state.copyWith(isViewMode: true));
    });

    on<DealDetailMotelLoaded>((event, emit) async {
      final result = await _motelsService.getMotelById(event.motelId);
      if (result.error != null) {
        emit(state.copyWith(error: result.error));
      } else if (result.motel != null) {
        emit(state.copyWith(motelAddress: result.motel!.address));
      } else {
        emit(state.copyWith(error: 'Motel not found for ID: ${event.motelId}'));
      }
    });

    on<DealDetailEditToggled>((event, emit) {
      emit(state.copyWith(isViewMode: !state.isViewMode));
    });

    on<DealDetailCountinueEditing>((event, emit) {
      emit(state.copyWith(error: null));
    });

    on<DealDetailSaved>((event, emit) async {
      final deal = event.deal;
      if (deal.name.isEmpty || deal.phone.isEmpty) {
        emit(state.copyWith(error: 'Hãy nhập đầy đủ thông tin'));
        await Future.delayed(Duration(milliseconds: 100));
        emit(state.copyWith(error: null));
        return;
      }
      emit(state.copyWith(isSaving: true));
      final result = deal.id.isEmpty
          ? await _customerService.addDeal(deal)
          : await _customerService.updateDeal(deal);
      if (result.$2 != null) {
        emit(state.copyWith(isSaving: false, error: result.$2!));
      } else {
        emit(state.copyWith(isSaving: false, isSaved: true));
      }
    });
  }
}
