import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/authentication/authentication_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';
import 'package:find_motel/services/authentication/firebase_auth_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IAuthentication _authenticationService;
  ProfileBloc({IAuthentication? authenticationService})
    : _authenticationService = authenticationService ?? FirebaseAuthService(),
      super(ProfileState()) {
    on<LoadProfileEvent>((event, emit) {
      final userProfile = AppDataManager().currentUserProfile;
      List<Future> futures = [Future.customer];
      if (userProfile?.role == UserRole.admin) {
        futures += [Future.import, Future.account];
      }
      emit(
        state.copyWith(
          name: userProfile?.name,
          avatar: userProfile?.avatar,
          email: userProfile?.email,
          futures: futures,
        ),
      );
    });

    on<LogoutEvent>((event, emit) async {
      await _authenticationService.signOut();
    });
  }
}
