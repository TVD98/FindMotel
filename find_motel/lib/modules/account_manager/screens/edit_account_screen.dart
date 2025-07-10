import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/modules/map_page/screens/fixed_dropdown_button.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../bloc/account_manager_bloc.dart';
import '../bloc/account_manager_event.dart';

class EditAccountScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditAccountScreen({super.key, required this.userProfile});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userProfile.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Chỉnh sửa tài khoản'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
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
                      _buildAvatar(widget.userProfile.avatar),
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
                            widget.userProfile.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.elementPrimary,
                            ),
                          ),
                        ],
                      ),
                      _buildRoleSelection(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: CustomButton(
                          title: 'Đặt lại',
                          textColor: AppColors.primary,
                          backgroundColor: AppColors.onPrimary,
                          strokeColor: AppColors.strokeLight,
                          radius: 4.0,
                          onPressed: () {
                            setState(() {
                              _selectedRole = widget.userProfile.role;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: CustomButton(
                          title: 'Lưu',
                          textColor: AppColors.onPrimary,
                          backgroundColor: AppColors.primary,
                          strokeColor: AppColors.strokeLight,
                          radius: 4.0,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildRoleSelection() {
    return Stack(
      clipBehavior: Clip.none, // Cho phép title vượt ra ngoài border
      children: [
        Expanded(
          child: FixedDropdownButton(
            value: _selectedRole.name,
            items: UserRole.values.map((e) => e.name).toList(),
            //width: 162.0,
            height: 44,
            onChanged: (value) {
              setState(() {
                _selectedRole = UserRole.values.firstWhere(
                  (e) => e.name == value,
                  orElse: () => UserRole.sale,
                );
              });
            },
          ),
        ),
        // Title đè lên border
        Positioned(
          top: -12.0, // Đẩy title lên để đè lên border
          left: 16.0, // Căn lề trái cho title
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6 / 2),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              'Phân quyền',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_selectedRole != widget.userProfile.role) {
      context.read<AccountManagerBloc>().add(
        UpdateAccountRoleEvent(
          userId: widget.userProfile.id,
          newRole: _selectedRole,
        ),
      );
    }
    Navigator.pop(context);
  }
}
