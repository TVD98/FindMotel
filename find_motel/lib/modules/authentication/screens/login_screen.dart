import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_motel/modules/home/screens/home_screens.dart';
import 'package:find_motel/theme/app_colors.dart';
import '../bloc/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (prev, curr) =>
            prev.isSubmitting != curr.isSubmitting ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Lỗi đăng nhập'),
                content: Text(state.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          } else if (state.isSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        child: const _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        SvgPicture.asset(
                          'assets/images/ic_logo.svg',
                          fit: BoxFit.scaleDown,
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          hint: 'Email',
                          onChanged: (value) => context.read<LoginBloc>().add(
                            EmailChanged(value),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          hint: 'Password',
                          obscureText: true,
                          onChanged: (value) => context.read<LoginBloc>().add(
                            PasswordChanged(value),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.canLogin
                                  ? () => context.read<LoginBloc>().add(
                                      LoginSubmitted(),
                                    )
                                  : null,
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.disabled,
                                      )) {
                                        return AppColors.primary.withOpacity(
                                          0.5,
                                        );
                                      }
                                      return AppColors.primary;
                                    }),
                                foregroundColor: WidgetStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                shape:
                                    WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(44),
                                      ),
                                    ),
                                elevation: WidgetStateProperty.all(0),
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.isSubmitting)
                Positioned.fill(
                  child: Stack(
                    children: const [
                      ModalBarrier(
                        dismissible: false,
                        color: AppColors.strokeLight,
                      ),
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    bool obscureText = false,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        height: 44,
        child: TextField(
          obscureText: obscureText,
          onChanged: onChanged,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            hintText: hint,
            hintStyle: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(44),
              borderSide: const BorderSide(color: AppColors.strokeLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(44),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
