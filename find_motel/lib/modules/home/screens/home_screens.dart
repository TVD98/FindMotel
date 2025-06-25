import 'package:find_motel/modules/home/bloc/home_bloc.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, TabState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state.selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.selectedIndex,
            onTap: (index) {
              final bloc = context.read<TabBloc>();
              switch (index) {
                case 0:
                  bloc.add(TabEvent.selectHome);
                  break;
                case 1:
                  bloc.add(TabEvent.selectMap);
                  break;
                case 2:
                  bloc.add(TabEvent.selectProfile);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text('Home Screen'));
      case 1:
        return const Center(child: Text('Map Screen'));
      case 2:
        return const Center(child: Text('Profile Screen'));
      default:
        return const SizedBox.shrink();
    }
  }
}
