// ignore_for_file: use_build_context_synchronously

import 'package:find_motel/modules/account_manager/screens/account_manager_screen.dart';
import 'package:find_motel/modules/deal_manager/screens/deal_manager_screen.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_bloc.dart';
import 'package:find_motel/modules/import_motels/screens/import_motels_screen.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/utilities/excel_reader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_bloc.dart';
import 'package:find_motel/modules/profile_page/bloc/profile_page_state.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CommonAppBar(
            title: state.name ?? '',
            leadingAsset: null,
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
              return Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 48),
                            _buildAvatar(state.avatar),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Email: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  state.email ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.elementPrimary,
                                  ),
                                ),
                              ],
                            ),
                            _divider(),
                            Column(
                              children: [
                                for (Future future in state.futures)
                                  _buildCard(future),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 44,
                        child: CustomButton(
                          title: 'Đăng xuất',
                          icon: Icons.logout,
                          textColor: AppColors.onPrimary,
                          backgroundColor: AppColors.primary,
                          onPressed: () {
                            context.read<ProfileBloc>().add(
                              const LogoutEvent(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? avatar) {
    if (avatar == null) {
      return SvgPicture.asset(
        'assets/images/ic_logo.svg',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }
    return CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatar));
  }

  _divider() =>
      const Divider(height: 30.0, thickness: 1.0, color: AppColors.strokeLight);

  Widget _buildCard(Future future) {
    Widget leading = Image.asset(future.info.icon, width: 22, height: 22);
    return GestureDetector(
      onTap: () {
        _navigateFuture(future);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.strokeLight,
            width: 1,
          ), // Optional border
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            leading,
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  future.info.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.elementPrimary,
                  ),
                ),
                Text(
                  future.info.description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.elementSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/images/ic_arrow_right.svg',
              height: 24,
              width: 24,
            ),
          ],
        ),
      ),
    );
  }

  _navigateFuture(Future future) async {
    switch (future) {
      case Future.customer:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DealManagerScreen()),
        );
        break;
      case Future.import:
        final reader = ExcelReader();
        final data = await reader.readExcelFile();
        if (data.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => ImportMotelsBloc(),
                child: ImportMotelsScreen(data: data),
              ),
            ),
          );
        }
        break;
      case Future.account:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountManagerScreen()),
        );
        break;
    }
  }
}
