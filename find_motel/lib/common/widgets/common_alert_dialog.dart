import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CommonAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final String? leadingActionTitle; // Tiêu đề cho nút leading (ví dụ: "Thoát")
  final String?
  trailingActionTitle; // Tiêu đề cho nút trailing (ví dụ: "Tiếp tục")
  final VoidCallback? onLeadingPressed; // Callback cho nút leading
  final VoidCallback? onTrailingPressed; // Callback cho nút trailing
  final MainAxisAlignment actionsAlignment;

  const CommonAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.titleStyle,
    this.contentStyle,
    this.leadingActionTitle,
    this.trailingActionTitle,
    this.onLeadingPressed,
    this.onTrailingPressed,
    this.actionsAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style:
            titleStyle ??
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
      ),
      content: Text(
        content,
        style:
            contentStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.elementSecondary,
            ),
      ),
      actions: [
        Row(
          mainAxisAlignment: actionsAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingActionTitle != null)
              SizedBox(
                width: 90,
                height: 38,
                child: CustomButton(
                  title: leadingActionTitle!,
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.onPrimary,
                  strokeColor: AppColors.strokeLight,
                  radius: 4.0,
                  onPressed: onLeadingPressed ?? () {},
                ),
              ),
            if (leadingActionTitle != null && trailingActionTitle != null)
              const SizedBox(width: 16),
            if (trailingActionTitle != null)
              SizedBox(
                width: 90,
                height: 38,
                child: CustomButton(
                  title: trailingActionTitle!,
                  textColor: AppColors.onPrimary,
                  backgroundColor: AppColors.primary,
                  strokeColor: AppColors.strokeLight,
                  radius: 4.0,
                  onPressed: onTrailingPressed ?? () {},
                ),
              ),
          ],
        ),
      ],
    );
  }
}
