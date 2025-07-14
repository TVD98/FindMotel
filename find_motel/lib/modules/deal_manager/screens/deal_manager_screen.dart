// ignore_for_file: use_build_context_synchronously

import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_detail_bloc.dart';
import 'package:find_motel/modules/deal_manager/screens/deal_detail_screen.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_manager_bloc.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_manager_event.dart';
import 'package:find_motel/modules/deal_manager/bloc/deal_manager_state.dart';
import 'package:find_motel/common/models/deal.dart';
import 'package:intl/intl.dart';

class DealManagerScreen extends StatefulWidget {
  const DealManagerScreen({super.key});

  @override
  State<DealManagerScreen> createState() => _DealManagerScreenState();
}

class _DealManagerScreenState extends State<DealManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DealManagerBloc()..add(LoadDealsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Quản lý deal')),
        body: BlocBuilder<DealManagerBloc, DealManagerState>(
          builder: (context, state) {
            if (state.status == DealManagerStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == DealManagerStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Đã có lỗi xảy ra'),
              );
            }
            if (state.deals.isEmpty) {
              return const Center(child: Text('Chưa có deal nào'));
            }
            return ListView.builder(
              itemCount: state.deals.length,
              itemBuilder: (context, index) {
                final deal = state.deals[index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DealDetailScreen(deal: deal),
                      ),
                    );
                    if (result is Deal) {
                      context.read<DealManagerBloc>().add(DealUpdatedEvent(result));
                    }
                  },
                  child: _DealItem(deal: deal),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DealItem extends StatelessWidget {
  final Deal deal;

  const _DealItem({required this.deal});

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
                      deal.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
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
                        deal.price.toVND(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
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
                      deal.motelName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
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
                        DateFormat('dd/MM/yyyy').format(deal.schedule),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
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
