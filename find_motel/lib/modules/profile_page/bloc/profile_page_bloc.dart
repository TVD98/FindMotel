import 'package:find_motel/managers/app_data_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState()) {
    on<LoadProfileEvent>((event, emit) {
      final userProfile = AppDataManager().currentUserProfile;
      emit(
        state.copyWith(
          name: userProfile?.name,
          avatar: userProfile?.avatar,
          email: userProfile?.email,
        ),
      );
    });
  }
}
