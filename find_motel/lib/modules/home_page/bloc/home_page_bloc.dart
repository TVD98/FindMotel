import 'dart:async';

import 'package:find_motel/managers/app_data_manager.dart';
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
      emit(state.copyWith(isLoading: true));
      final result = await _motelsService.getMotels(
        filter: event.filter,
        limit: 100,
      );
      if (result.motels != null) {
        emit(
          state.copyWith(
            isLoading: false,
            motels: result.motels,
            errorMessage: null,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, motels: null));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
