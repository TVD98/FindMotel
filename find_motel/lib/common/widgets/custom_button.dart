import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final Color backgroundColor;
  final Color strokeColor; // Màu viền
  final double radius;
  final VoidCallback? onPressed; // Hàm callback khi nút được nhấn

  const CustomButton({
    super.key,
    required this.title,
    this.textColor = Colors.white, // Mặc định màu chữ trắng
    this.backgroundColor = Colors.blue, // Mặc định màu nền xanh
    this.strokeColor = Colors.transparent, // Mặc định không có viền
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
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          // Không cần thuộc tính textAlign ở đây vì Container đã căn giữa
        ),
      ),
    );
  }
}
