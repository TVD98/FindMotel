import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_motel/services/authentication/authentication_service.dart';
import 'package:find_motel/services/authentication/firebase_auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthentication _auth;

  LoginBloc({IAuthentication? authService})
    : _auth = authService ?? FirebaseAuthService(),
      super(const LoginState()) {
    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<LoginSubmitted>((event, emit) async {
      emit(state.copyWith(isSubmitting: true, errorMessage: null));
      try {
        await _auth.signInWithEmailAndPassword(
          email: state.email.trim(),
          password: state.password.trim(),
        );
        emit(state.copyWith(isSubmitting: false));
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      }
    });
  }
}
