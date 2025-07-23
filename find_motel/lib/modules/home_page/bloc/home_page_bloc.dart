import 'dart:async';

import 'package:find_motel/common/models/motel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';

import 'home_page_event.dart';
import 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IMotelsService _motelsService;
  final int _pageSize = 6;
  int? _lastCreatedAt;

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
        lastCreatedAt: event.isRefresh ? null : _lastCreatedAt,
        limit: _pageSize,
      );
      _lastCreatedAt = result.motels?.last.createdAt;
      List<Motel> motels = [];
      if (event.isRefresh) {
        motels = result.motels ?? [];
      } else {
        motels = state.motels ?? [];
        motels.addAll(result.motels ?? []);
      }
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          motels: motels,
          hasMoreData: (result.motels?.length ?? 0) == _pageSize,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
