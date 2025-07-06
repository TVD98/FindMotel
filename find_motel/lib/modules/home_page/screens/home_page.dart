// ignore_for_file: unused_import

import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.message,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'This is the main page of the app.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
