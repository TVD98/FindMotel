import 'package:find_motel/common/widgets/common_alert_dialog.dart';
import 'package:find_motel/modules/account_manager/bloc/account_manager_event.dart';
import 'package:find_motel/modules/account_manager/screens/edit_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:flutter_svg/svg.dart';
import '../bloc/account_manager_bloc.dart';
import '../bloc/account_manager_state.dart';

class AccountManagerScreen extends StatelessWidget {
  const AccountManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountManagerBloc()..add(LoadAccountsEvent()),
      child: Scaffold(
        appBar: const CommonAppBar(title: 'Danh Sách Tài Khoản'),
        body: BlocBuilder<AccountManagerBloc, AccountManagerState>(
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return _AccountItem(
                  account: account,
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context
                              .read<
                                AccountManagerBloc
                              >(), // dùng lại MapBloc hiện có
                          child: EditAccountScreen(userProfile: account),
                        ),
                      ),
                    );
                  },
                  onDelete: () {
                    context.read<AccountManagerBloc>().add(
                      DeleteAccountEvent(userId: account.id),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final UserProfile account;
  final Function() onEdit;
  final Function() onDelete;

  const _AccountItem({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildAvatar(String? avatar) {
    if (avatar == null) {
      return SvgPicture.asset(
        'assets/images/ic_logo.svg',
        width: 64,
        height: 64,
        fit: BoxFit.contain,
      );
    }
    return CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatar));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: AppColors.strokeLight,
        ), // Đường viền với độ dày và màu
        borderRadius: BorderRadius.circular(20), // Bo góc với bán kính 10
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa theo chiều dọc
          children: [
            // Leading: Avatar
            _buildAvatar(account.avatar),
            SizedBox(width: 12), // Khoảng cách giữa avatar và nội dung
            // Title và Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Căn trái cho title và subtitle
                mainAxisSize: MainAxisSize.min, // Giữ kích thước tối thiểu
                children: [
                  Text(
                    account.email,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        account.role.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.elementSecondary,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          onEdit();
                        },
                        child: SvgPicture.asset(
                          'assets/images/ic_edit.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          _showDeleteConfirmation(context, account);
                        },
                        child: SvgPicture.asset(
                          'assets/images/ic_trash.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserProfile account) {
    showDialog(
      context: context,
      builder: (context) => CommonAlertDialog(
        title: 'Xoá tài khoản',
        content: 'Bạn có chắc chắn muốn xoá tài khoản ${account.email}?',
        leadingActionTitle: 'Huỷ',
        trailingActionTitle: 'Xoá',
        onLeadingPressed: () => Navigator.pop(context),
        onTrailingPressed: () {
          onDelete();
          Navigator.pop(context);
        },
      ),
    );
  }
}
