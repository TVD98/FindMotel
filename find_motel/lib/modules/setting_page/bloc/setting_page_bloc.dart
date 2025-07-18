import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_page_event.dart';
import 'setting_page_state.dart';
import 'package:find_motel/managers/app_data_manager.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {

  SettingBloc() : super(SettingState()) {
    on<LoadSettingEvent>((event, emit) async {
      final userSetting = AppDataManager().currentUserProfile;
      // Cập nhật trạng thái với thông tin người dùng
      if (userSetting != null) {
        emit(
          state.copyWith(
            name: userSetting.name,
            avatar: userSetting.avatar,
            email: userSetting.email,
          ),
        );
      }

    });
    on<UsernameChanged>((event, emit) {
      emit(state.copyWith(name: event.username));
    });
    on<AvatarChanged>((event, emit) {
      emit(state.copyWith(avatar: event.avatar));
    });
    on<SaveSetting>((event, emit) async {
      emit(state.copyWith(isSaving: true));
      // TODO: Thêm logic lưu cài đặt vào backend hoặc local
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(isSaving: false));
    });
  }
}
