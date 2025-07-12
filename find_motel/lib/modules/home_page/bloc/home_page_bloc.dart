import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';

import 'home_page_event.dart';
import 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IMotelsService _motelsService;

  HomePageBloc({IMotelsService? motelsService})
    : _motelsService = motelsService ?? FirestoreService(),
      super(HomePageInitial()) {
    on<LoadMotels>(_onLoadMotels);
  }

  Future<void> _onLoadMotels(
    LoadMotels event,
    Emitter<HomePageState> emit,
  ) async {
    try {
      emit(HomePageLoading());

      final result = await _motelsService.getMotels(limit: 100);

      if (result.error != null) {
        emit(HomePageError(result.error!));
        return;
      }

      if (result.motels == null) {
        emit(const HomePageError('No motels found'));
        return;
      }

      emit(HomePageLoaded(result.motels!));
    } catch (e) {
      emit(HomePageError(e.toString()));
    }
  }
}
