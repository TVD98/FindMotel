import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';

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
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.elementSecondary,
          width: 1.0,
        ),
      ),
    );
  }
}
