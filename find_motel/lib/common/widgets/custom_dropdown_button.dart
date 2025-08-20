import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    this.borderColor = AppColors.strokeLight,
    this.borderRadius = 8.0,
    this.backgroundColor = AppColors.onSurface1,
    this.rightIconAsset = 'assets/images/ic_arrow_down.svg',
    this.width = 200.0,
    this.height = 50.0,
    this.horizontalPadding = 16.0,
    this.iconSize = 48.0,
    this.menuItemFontSize = 14.0,
    this.menuItemTextColor = AppColors.elementPrimary,
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
          menuMaxHeight: 320.0,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: AppTextStyle.smallBody.copyWith(
                  fontSize: menuItemFontSize,
                  color: menuItemTextColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: SvgPicture.asset(
            rightIconAsset,
            width: iconSize,
            height: iconSize,
          ),
          underline: const SizedBox.shrink(),
          dropdownColor: backgroundColor,
        ),
      ),
    );
  }
}
