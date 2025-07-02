// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/circular_checkbox.dart';
import 'package:flutter/material.dart';

typedef CircularCheckboxListCallback = void Function(String value);

class CircularCheckboxList extends StatefulWidget {
  final List<String> items;
  // Giá trị khởi tạo cho selected. Nếu items rỗng, sẽ dùng ''
  final String? initialSelected; // Sử dụng String? để cho phép null
  final CircularCheckboxListCallback? onChange;

  const CircularCheckboxList({
    super.key,
    required this.items,
    this.initialSelected, // Không gán giá trị mặc định trực tiếp ở đây
    this.onChange,
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
            String newValue = _selected == item ? '' : item;
            setState(() {
              _selected = newValue;
            });
            if (widget.onChange != null) {
              widget.onChange!(newValue);
            }
          },
        );
      }).toList(),
    );
  }
}
