import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState('User Name', 'user@example.com')) {
    on<ProfileEvent>((event, emit) {
      if (event == ProfileEvent.updateName) {
        emit(ProfileState('User Updated', state.email));
      }
    });
  }
}
