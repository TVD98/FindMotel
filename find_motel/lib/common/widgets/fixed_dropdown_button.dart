import 'package:find_motel/common/widgets/custom_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';

enum DropdownStyle { large, medium }

class FixedDropdownButton extends StatefulWidget {
  final List<String> items;
  final String? value;
  final double width;
  final double height;
  final DropdownStyle style;
  final ValueChanged<String?>? onChanged;

  const FixedDropdownButton({
    super.key,
    required this.items,
    this.value,
    this.width = 120.0,
    this.height = 26,
    this.style = DropdownStyle.large,
    this.onChanged,
  });

  @override
  State<FixedDropdownButton> createState() => _FixedDropdownButtonState();
}

class _FixedDropdownButtonState extends State<FixedDropdownButton> {
  @override
  Widget build(BuildContext context) {
    final double iconSize;
    switch (widget.style) {
      case DropdownStyle.large:
        iconSize = 24;
      case DropdownStyle.medium:
        iconSize = 16;
        break;
    }
    return CustomDropdownButton<String>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.onChanged,
      borderColor: AppColors.strokeLight,
      borderRadius: 4.0,
      backgroundColor: Colors.white,
      width: widget.width,
      height: widget.height,
      horizontalPadding: 8.0,
      iconSize: iconSize,
      menuItemFontSize: 14.0,
      menuItemTextColor: AppColors.elementSecondary,
    );
  }
}
