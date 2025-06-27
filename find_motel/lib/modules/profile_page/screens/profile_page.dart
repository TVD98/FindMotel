import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Name: ${state.name}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Email: ${state.email}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(ProfileEvent.updateName);
                },
                child: const Text('Update Name'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/images/image_sana.jpg',
                  width: 40, // Kích thước tùy chỉnh
                  height: 40,
                  fit: BoxFit.cover, // Điều chỉnh cách ảnh hiển thị
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
