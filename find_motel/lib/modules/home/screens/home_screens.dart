import 'package:find_motel/modules/home/bloc/home_bloc.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:find_motel/modules/home_page/screens/home_page.dart';
import 'package:find_motel/modules/map_page/screens/map_page.dart';
import 'package:find_motel/modules/profile_page/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const ProfilePage(),
  ];
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load current location once when HomeScreen is first shown
    context.read<HomeBloc>().add(const LoadCurrentLocationEvent());
    context.read<HomeBloc>().add(const LoadCatalogEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: HomeScreen._pages[state.selectedIndex],
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: state.selectedIndex,
              onTap: (index) {
                context.read<HomeBloc>().add(TabSelected(index));
              },
              backgroundColor: Colors.white,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_home.svg',
                    width: 42,
                    height: 42,
                    colorFilter: ColorFilter.mode(
                      AppColors.tertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/images/ic_home.svg',
                    width: 42,
                    height: 42,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Transform.translate(
                    offset: Offset(0, -40), // shift icon upward
                    child: SvgPicture.asset(
                      'assets/images/ic_map.svg',
                      width: 52,
                      height: 52,
                    ),
                  ),
                  activeIcon: Transform.translate(
                    offset: Offset(0, -40), // shift icon upward
                    child: SvgPicture.asset(
                      'assets/images/ic_map_highlight.svg',
                      width: 52,
                      height: 52,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/images/ic_profile.svg',
                    width: 42,
                    height: 42,
                    colorFilter: ColorFilter.mode(
                      AppColors.tertiary,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/images/ic_profile.svg',
                    width: 42,
                    height: 42,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
