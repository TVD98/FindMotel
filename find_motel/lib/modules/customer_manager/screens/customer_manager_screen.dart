import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_bloc.dart';
import 'package:find_motel/modules/customer_manager/bloc/customer_manager_state.dart';
import 'package:find_motel/common/models/customer.dart';
import 'package:intl/intl.dart';

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
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerItem({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: AppColors.strokeLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trên: name và deal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_customer.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Đảm bảo width cố định cho cột deal
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/ic_money.png',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        customer.deal.toVND(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Dòng dưới: motelName và schedule
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_motel.png',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customer.motelName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.elementSecondary,
                      ),
                    ),
                  ],
                ),
                // Đảm bảo width cố định cho cột schedule
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/ic_schedule.png',
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(customer.schedule),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.elementSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
