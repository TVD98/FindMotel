import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final IUserDataService userDataService;

  UserBloc({required this.userDataService}) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    try {
      final result = await userDataService.getUserProfileByEmail(event.email);

      if (result.error != null) {
        emit(UserError(result.error!));
      } else if (result.userProfile != null) {
        emit(UserLoaded(result.userProfile!));
      } else {
        emit(UserError('User not found'));
      }
    } catch (e) {
      emit(UserError('An error occurred: $e'));
    }
  }
}
