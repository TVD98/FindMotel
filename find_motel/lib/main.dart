import 'dart:ui';

import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/home/bloc/home_bloc.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/screens/home_screens.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/authentication/screens/login_screen.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:find_motel/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('[DEBUG] Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[DEBUG] Firebase initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMotel',
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang loading trạng thái đăng nhập
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => HomeBloc()..add(LoadUserDataEvent())),
              BlocProvider(create: (_) => HomePageBloc()),
              BlocProvider(
                create: (_) => MapBloc()..add(FirstLoadMotelsEvent()),
              ),
              BlocProvider(create: (_) => ProfileBloc()),
              BlocProvider(create: (_) => UserProfileCubit()),
              BlocProvider(create: (_) => MotelsFilterCubit()..loadFilter()),
            ],
            child: const HomeScreen(),
          );
        }

        // Chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}
