part of 'login_bloc.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get canLogin => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isSubmitting,
    errorMessage,
    isSuccess,
  ];
}
