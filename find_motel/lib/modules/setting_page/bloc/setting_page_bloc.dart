import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_page_event.dart';
import 'setting_page_state.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';


class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final userSetting = AppDataManager().currentUserProfile;
  final IUserDataService _userDataService;

  SettingBloc({IUserDataService? userDataService})
    : _userDataService = userDataService ?? FirestoreService(),
    super(SettingState()) {
    on<LoadSettingEvent>((event, emit) async {
      // Cập nhật trạng thái với thông tin người dùng
      emit(
        state.copyWith(
          name: userSetting?.name,
          avatar: userSetting?.avatar,
          email: userSetting?.email,
        ),
      );
    });
    on<UsernameChanged>((event, emit) {
      emit(state.copyWith(name: event.username));
    });
    on<AvatarChanged>((event, emit) {
      emit(state.copyWith(avatar: event.avatar));
    });
    on<SaveSetting>((event, emit) async {
      emit(state.copyWith(isSaving: true));
      final bool success = await _userDataService.updateUserProfile(
        userId: userSetting?.id ?? '',
        name: state.name ?? '',
        avatar: state.avatar ?? '',
      );
      if (success) {
        emit(state.copyWith(isSaving: false, isSaved: true));
      } else {
        emit(state.copyWith(isSaving: false));
      }
    });
  }
}
