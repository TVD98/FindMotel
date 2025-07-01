import 'package:find_motel/common/custom_dropdown_button.dart';
import 'package:flutter/material.dart';

class FixedDropdownButton extends StatefulWidget {
  final List<String> items;
  final String? value;
  final double width;
  final ValueChanged<String?>? onChanged;

  const FixedDropdownButton({
    super.key,
    required this.items,
    this.value,
    this.width = 120.0,
    this.onChanged,
  });

  @override
  State<FixedDropdownButton> createState() => _FixedDropdownButtonState();
}

class _FixedDropdownButtonState extends State<FixedDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return CustomDropdownButton<String>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.onChanged,
      borderColor: const Color(0xFFD1D1D1),
      borderRadius: 4.0,
      backgroundColor: Colors.white,
      rightIconAsset: 'assets/images/ic_arrow_down_rectange.png',
      width: widget.width,
      height: 26.0,
      horizontalPadding: 8.0,
      iconSize: 18.0,
      menuItemFontSize: 14.0,
      menuItemTextColor: const Color(0xFF474747),
    );
  }
}
