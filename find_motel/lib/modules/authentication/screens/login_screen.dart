import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/theme/app_textStyle.dart';
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
        child: _LoginForm(),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(_onEmailChange);
    passwordController.addListener(_onPasswordChange);
  }

  void _onEmailChange() {
    context.read<LoginBloc>().add(EmailChanged(emailController.text));
  }

  void _onPasswordChange() {
    context.read<LoginBloc>().add(PasswordChanged(passwordController.text));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 80),
                          SvgPicture.asset(
                            'assets/images/ic_logo.svg',
                            fit: BoxFit.scaleDown,
                          ),
                          const SizedBox(height: 40),
                          CommonTextfield(
                            controller: emailController,
                            hintText: 'Email',
                            borderRadius: BorderRadius.circular(100),
                          ),
                          const SizedBox(height: 12),
                          CommonTextfield(
                            controller: passwordController,
                            hintText: 'Password',
                            borderRadius: BorderRadius.circular(100),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: CustomButton(
                              label: 'Login',
                              textStyle: AppTextStyle.title,
                              textColor: AppColors.onPrimary,
                              backgroundColor: AppColors.primary,
                              onPressed: () => context.read<LoginBloc>().add(
                                LoginSubmitted(),
                              ),
                              radius: 100,
                              isDisabled: !state.canLogin,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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
