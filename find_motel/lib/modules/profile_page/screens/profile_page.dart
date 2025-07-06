// ignore_for_file: unused_field

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile',
        //leadingAsset: null,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: handle settings tap
            },
            icon: SvgPicture.asset(
              'assets/images/ic_setting.svg',
              height: 24,
              width: 24,
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Name: ${state.name}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${state.email}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _auth.signOut();
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
