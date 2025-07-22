import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';

import 'home_page_event.dart';
import 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IMotelsService _motelsService;

  HomePageBloc({IMotelsService? motelsService})
    : _motelsService = motelsService ?? FirestoreService(),
      super(HomePageState.initial()) {
    on<LoadMotels>(_onLoadMotels);
  }

  FutureOr<void> _onLoadMotels(
    LoadMotels event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: event.isRefresh,
          isLoadingMore: !event.isRefresh,
        ),
      );
      final result = await _motelsService.getMotels(
        filter: event.filter,
        limit: 100,
      );
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          motels: result.motels,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, isLoadingMore: false, errorMessage: e.toString()));
    }
  }
}
