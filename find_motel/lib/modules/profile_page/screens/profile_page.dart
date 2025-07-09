import 'package:find_motel/modules/profile_page/bloc/profile_page_event.dart';
import 'package:find_motel/theme/app_colors.dart';
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
            title: 'Hello ${state.name}',
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
              return SingleChildScrollView(
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
                    ],
                  ),
                ),
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
        'assets/images/img_empty_avatar.svg',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }
    return CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatar));
  }
}
