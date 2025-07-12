import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:flutter/material.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;

  const DealDetailScreen({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Chi tiết Deal'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${deal.name}'),
            Text('SĐT: ${deal.phone}'),
            Text('Giá: ${deal.price.toVND()}'),
            Text('Ngày hẹn: ${deal.schedule}'),
            Text('Sale ID: ${deal.saleId}'),
            Text('Motel: ${deal.motelName}'),
          ],
        ),
      ),
    );
  }
}