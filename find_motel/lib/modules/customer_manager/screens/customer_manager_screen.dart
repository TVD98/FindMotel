import 'package:find_motel/modules/customer_manager/bloc/customer_manager_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_bloc.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomerManagerScreen extends StatefulWidget {
  const CustomerManagerScreen({super.key});

  @override
  State<CustomerManagerScreen> createState() => _CustomerManagerScreenState();
}

class _CustomerManagerScreenState extends State<CustomerManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerManagerBloc()..add(LoadCustomersEvent()),
      child: Scaffold(
        appBar: const CommonAppBar(title: 'Quản Lý Khách Hàng'),
        body: BlocBuilder<CustomerManagerBloc, CustomerManagerState>(
          builder: (context, state) {
            if (state.status == CustomerManagerStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CustomerManagerStatus.failure) {
              return Center(
                child: Text(
                  'Đã xảy ra lỗi: ${state.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state.customers.isEmpty) {
              return const Center(child: Text('Không có khách hàng nào'));
            }

            return ListView.builder(
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return _CustomerItem(
                  customer: customer,
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CustomerItem extends StatelessWidget {
  final UserProfile customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerItem({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return SvgPicture.asset(
        'assets/images/ic_logo.svg', // Make sure this asset exists
        width: 64,
        height: 64,
        fit: BoxFit.contain,
      );
    }
    return CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatar));
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'staff':
        return 'Nhân viên';
      case 'customer':
      default:
        return 'Khách hàng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: AppColors.strokeLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(customer.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TVD',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'tvd@gmail.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vai trò: Khách hàng',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
