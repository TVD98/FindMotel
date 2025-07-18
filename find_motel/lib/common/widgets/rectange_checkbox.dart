import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Đây là widget CircularCheckbox của bạn
class RectangeCheckbox extends StatelessWidget {
  final bool isSelected;
  final String text;
  final String selectedIcon;
  final String unselectedIcon;
  final VoidCallback onTap; // Callback khi người dùng chạm vào

  const RectangeCheckbox({
    super.key,
    required this.isSelected,
    required this.text,
    required this.onTap,
    required this.selectedIcon,
    required this.unselectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Sử dụng onTap từ bên ngoài
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Đảm bảo Row chỉ chiếm không gian cần thiết
        children: [
          SvgPicture.asset(
            isSelected ? selectedIcon : unselectedIcon,
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 5.0), // Khoảng cách nhỏ giữa checkbox và text
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF474747),
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis, // Xử lý tràn text
            ),
          ),
        ],
      ),
    );
  }
}
