import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CommonContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const CommonContainer({
    super.key,
    required this.child,
    this.height = 38,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    this.color = AppColors.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.strokeLight),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
