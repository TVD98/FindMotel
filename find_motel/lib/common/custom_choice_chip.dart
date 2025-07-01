import 'package:flutter/material.dart';

class CustomChoiceChip extends StatelessWidget {
  final String title;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const CustomChoiceChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(title),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Color(0xFF248078),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: selected ? Color(0xFF248078) : Color(0xFFD1D1D1),
          width: 1.0,
        ),
      ),
    );
  }
}
