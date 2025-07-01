// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/circular_checkbox.dart';
import 'package:flutter/material.dart';

class CircularCheckboxList extends StatefulWidget {
  final List<String> items;
  // Giá trị khởi tạo cho selected. Nếu items rỗng, sẽ dùng ''
  final String? initialSelected; // Sử dụng String? để cho phép null

  const CircularCheckboxList({
    super.key,
    required this.items,
    this.initialSelected, // Không gán giá trị mặc định trực tiếp ở đây
  });

  @override
  State<CircularCheckboxList> createState() => _CircularCheckboxListState();
}

class _CircularCheckboxListState extends State<CircularCheckboxList> {
  late String _selected; // Sử dụng late để khởi tạo trong initState

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selected
    _selected = widget.initialSelected ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dàn trải các item
      children: widget.items.map((String item) {
        return CircularCheckbox(
          isSelected: _selected == item,
          text: item,
          onTap: () {
            setState(() {
              if (_selected == item) {
                _selected = '';
              } else {
                _selected = item;
              }
            });
          },
        );
      }).toList(),
    );
  }
}
