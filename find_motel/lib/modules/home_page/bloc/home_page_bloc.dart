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
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  FutureOr<void> _onLoadMotels(
    LoadMotels event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final result = await _motelsService.getMotels();
      if (result.motels != null) {
        emit(
          state.copyWith(
            isLoading: false,
            motels: result.motels,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onLoadUserProfile(LoadUserProfile event, Emitter<HomePageState> emit) {
    try {
      final userProfile = AppDataManager().currentUserProfile;
      emit(state.copyWith(userProfile: userProfile, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
