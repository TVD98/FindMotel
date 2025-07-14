// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/widgets/rectange_checkbox.dart';
import 'package:flutter/material.dart';

typedef RectangeCheckboxListCallback = void Function(List<String> values);
typedef CheckboxItem = (String id, String text);

class RectangeCheckboxList extends StatefulWidget {
  final List<CheckboxItem> items;
  // Giá trị khởi tạo cho selected. Nếu items rỗng, sẽ dùng ''
  final List<String>?
  initialSelected; // Danh sách giá trị được chọn ban đầu (có thể null)
  final RectangeCheckboxListCallback? onChange;

  const RectangeCheckboxList({
    super.key,
    required this.items,
    this.initialSelected, // Không gán giá trị mặc định trực tiếp ở đây
    this.onChange,
  });

  @override
  State<RectangeCheckboxList> createState() => _RectangeCheckboxListState();
}

class _RectangeCheckboxListState extends State<RectangeCheckboxList> {
  late Set<String> _selected; // Tập hợp giá trị đã chọn

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selected
    _selected =
        widget.initialSelected?.toSet() ?? {}; // Khởi tạo tập giá trị đã chọn
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Dàn trải các item
      children: widget.items.map((CheckboxItem item) {
        return RectangeCheckbox(
          isSelected: _selected.contains(item.$1),
          text: item.$2,
          onTap: () {
            setState(() {
              if (_selected.contains(item.$1)) {
                _selected.remove(item.$1);
              } else {
                _selected.add(item.$1);
              }
            });
            // Gọi callback với danh sách giá trị đã chọn
            widget.onChange?.call(_selected.toList());
          },
        );
      }).toList(),
    );
  }
}
