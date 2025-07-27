import 'package:bloc/bloc.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'motel_detail_event.dart';
import 'motel_detail_state.dart';

class MotelDetailBloc extends Bloc<MotelDetailEvent, MotelDetailState> {
  MotelDetailBloc({required Motel initialMotelDetail})
    : super(
        MotelDetailLoaded(
          motelDetail: initialMotelDetail,
          isCanEdit:
              AppDataManager().currentUserProfile?.role == UserRole.admin,
        ),
      ) {
    on<MotelDetailMotelUpdated>(_onMotelDetailMotelUpdated);
  }

  Future<void> _onMotelDetailMotelUpdated(
    MotelDetailMotelUpdated event,
    Emitter<MotelDetailState> emit,
  ) async {}
}
