import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color textColor;
  final Color backgroundColor;
  final Color strokeColor; // Màu viền
  final Color? iconColor; // Màu icon
  final double radius;
  final VoidCallback? onPressed; // Hàm callback khi nút được nhấn
  final bool isDisabled; // Trạng thái disable

  const CustomButton({
    super.key,
    required this.title,
    this.icon,
    this.textColor = Colors.white, // Mặc định màu chữ trắng
    this.backgroundColor = Colors.blue, // Mặc định màu nền xanh
    this.strokeColor = Colors.transparent, // Mặc định không có viền
    this.iconColor,
    this.radius = 8.0, // Mặc định bo tròn 8.0
    this.onPressed,
    this.isDisabled = false, // Mặc định nút không bị disable
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Chỉ gọi onPressed nếu nút không bị disable
      onTap: isDisabled ? null : onPressed,
      child: Opacity(
        // Làm mờ nút khi bị disable
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          alignment: Alignment.center, // Căn giữa nội dung
          decoration: BoxDecoration(
            color: isDisabled
                ? backgroundColor.withOpacity(0.9)
                : backgroundColor, // Màu nền nhạt hơn khi disable
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: strokeColor,
              width: 1.0, // Độ dày viền
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    icon,
                    color: isDisabled
                        ? (iconColor ?? textColor).withOpacity(0.9)
                        : (iconColor ?? textColor),
                    size: 20.0,
                  ),
                ),
              Text(
                title,
                style: TextStyle(
                  color: isDisabled ? textColor.withOpacity(0.9) : textColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
