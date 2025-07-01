import 'package:flutter/material.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final T? value;
  final List<T> items; // Changed to List<T>
  final ValueChanged<T?>? onChanged;
  final Color borderColor;
  final double borderRadius;
  final Color backgroundColor;
  final String rightIconAsset;
  final double width;
  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double menuItemFontSize;
  final Color menuItemTextColor;

  const CustomDropdownButton({
    super.key,
    this.value,
    required this.items, // Made required since items are essential
    this.onChanged,
    this.borderColor = Colors.grey,
    this.borderRadius = 8.0,
    this.backgroundColor = Colors.white,
    this.rightIconAsset = 'assets/images/dropdown_icon.png',
    this.width = 200.0,
    this.height = 50.0,
    this.horizontalPadding = 16.0,
    this.iconSize = 24.0,
    this.menuItemFontSize = 16.0,
    this.menuItemTextColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: DropdownButton<T>(
          value: value,
          menuMaxHeight: 200.0,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(), // Convert item to string for display
                style: TextStyle(
                  fontSize: menuItemFontSize,
                  color: menuItemTextColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Image.asset(rightIconAsset, width: iconSize, height: iconSize),
          underline: const SizedBox.shrink(),
          dropdownColor: backgroundColor,
        ),
      ),
    );
  }
}
