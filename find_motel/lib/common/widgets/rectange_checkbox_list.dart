// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/widgets/rectange_checkbox.dart';
import 'package:flutter/material.dart';

// Đảm bảo RectangeCheckbox của bạn có import này
// Nếu không có, bạn sẽ cần thêm nó vào file rectange_checkbox.dart
// import 'package:find_motel/theme/app_colors.dart';
// import 'package:google_fonts/google_fonts.dart';

typedef RectangeCheckboxListCallback = void Function(List<String> values);
typedef CheckboxItem = (String id, String text);

// Enum để định nghĩa kiểu hiển thị
enum CheckboxListDisplayMode { row, grid }

// Enum để định nghĩa chế độ chọn
enum CheckboxListSelectionMode {
  single, // Chỉ chọn 1
  multiple, // Chọn nhiều (mặc định)
}

class RectangeCheckboxList extends StatefulWidget {
  final List<CheckboxItem> items;
  final List<String>? initialSelected;
  final RectangeCheckboxListCallback? onChange;
  final CheckboxListDisplayMode displayMode;
  final int? gridCrossAxisCount;
  final double? gridChildAspectRatio;
  final CheckboxListSelectionMode
  selectionMode; // Thêm thuộc tính selectionMode mới

  const RectangeCheckboxList({
    super.key,
    required this.items,
    this.initialSelected,
    this.onChange,
    this.displayMode = CheckboxListDisplayMode.row,
    this.gridCrossAxisCount,
    this.gridChildAspectRatio = 3.0,
    this.selectionMode =
        CheckboxListSelectionMode.multiple, // Mặc định là chọn nhiều
  });

  @override
  State<RectangeCheckboxList> createState() => _RectangeCheckboxListState();
}

class _RectangeCheckboxListState extends State<RectangeCheckboxList> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    // Đảm bảo rằng nếu là chế độ single, chỉ có tối đa 1 item được chọn ban đầu
    if (widget.selectionMode == CheckboxListSelectionMode.single &&
        (widget.initialSelected?.length ?? 0) > 1) {
      _selected = {widget.initialSelected!.first}; // Chỉ lấy item đầu tiên
    } else {
      _selected = widget.initialSelected?.toSet() ?? {};
    }
  }

  // Hàm xử lý khi một item được tap
  void _handleItemTap(CheckboxItem tappedItem) {
    setState(() {
      if (widget.selectionMode == CheckboxListSelectionMode.single) {
        // Nếu là chế độ chọn đơn:
        if (_selected.contains(tappedItem.$1)) {
          // Nếu item đó đang được chọn, bỏ chọn nó (nếu muốn cho phép bỏ chọn)
          _selected.clear(); // Bỏ chọn tất cả
        } else {
          // Nếu item đó chưa được chọn, chọn nó và bỏ chọn tất cả các item khác
          _selected.clear(); // Bỏ chọn tất cả các item hiện có
          _selected.add(tappedItem.$1); // Chọn item mới
        }
      } else {
        // Nếu là chế độ chọn nhiều (logic cũ):
        if (_selected.contains(tappedItem.$1)) {
          _selected.remove(tappedItem.$1);
        } else {
          _selected.add(tappedItem.$1);
        }
      }
    });
    // Gọi callback với danh sách giá trị đã chọn
    widget.onChange?.call(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    // Hàm để tạo một RectangeCheckbox
    Widget buildCheckbox(CheckboxItem item) {
      return RectangeCheckbox(
        isSelected: _selected.contains(item.$1),
        text: item.$2,
        selectedIcon: widget.selectionMode == CheckboxListSelectionMode.single
            ? 'assets/images/ic_checked_circle.svg'
            : 'assets/images/ic_checked_box.svg',
        unselectedIcon: widget.selectionMode == CheckboxListSelectionMode.single
            ? 'assets/images/ic_unchecked_circle.svg'
            : 'assets/images/ic_unchecked_box.svg',
        onTap: () => _handleItemTap(item), // Gọi hàm xử lý tap mới
      );
    }

    // Kiểm tra displayMode để hiển thị Row hoặc GridView
    if (widget.displayMode == CheckboxListDisplayMode.grid) {
      assert(
        widget.gridCrossAxisCount != null,
        'gridCrossAxisCount must be provided when displayMode is GridView.',
      );

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridCrossAxisCount!,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: widget.gridChildAspectRatio!,
        ),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return buildCheckbox(item);
        },
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.items.map((CheckboxItem item) {
          return buildCheckbox(item);
        }).toList(),
      );
    }
  }
}
