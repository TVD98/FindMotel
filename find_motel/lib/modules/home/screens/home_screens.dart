import 'package:find_motel/modules/home/bloc/home_bloc.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:find_motel/modules/home_page/screens/home_page.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    Center(child: Text('Map Screen')),
    Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, TabState>(
      builder: (context, state) {
        return Scaffold(
          body: _pages[state.selectedIndex],
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
            backgroundColor: Color(0xFFF5F5F5),
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
}
