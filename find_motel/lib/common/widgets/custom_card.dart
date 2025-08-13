import 'package:flutter/material.dart';

// Widget có thể tái sử dụng, nhận một widget làm hình ảnh
class CustomCard extends StatelessWidget {
  final Widget imageWidget; // Thay thế String imageUrl bằng Widget imageWidget
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;

  const CustomCard({
    super.key,
    required this.imageWidget,
    required this.title,
    this.titleColor = Colors.black,
    this.backgroundColor = const Color.fromARGB(255, 240, 240, 240),
    this.borderRadius = 15.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 8.0, 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sử dụng widget được truyền vào
          imageWidget,
          const SizedBox(width: 8.0),
          // Phần văn bản chỉ có tiêu đề
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
