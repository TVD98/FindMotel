import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color textColor;
  final Color backgroundColor;
  final Color strokeColor; // Màu viền
  final Color? iconColor; // Màu icon, mặc định sẽ dùng textColor nếu không chỉ định
  final double radius;
  final VoidCallback? onPressed; // Hàm callback khi nút được nhấn

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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center, // <-- Quan trọng: Căn giữa nội dung Text
        decoration: BoxDecoration(
          color: backgroundColor,
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
                  color: iconColor ?? textColor,
                  size: 20.0,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
