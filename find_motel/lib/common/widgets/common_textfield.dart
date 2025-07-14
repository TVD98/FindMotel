import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String? title;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CommonTextfield({
    super.key,
    required this.controller,
    this.title,
    this.hintText,
    this.keyboardType,
    this.enabled = true, // Mặc định là true
    this.inputFormatters, // thêm dòng này
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          inputFormatters: inputFormatters,
          enabled: enabled,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.strokeLight),
            ),
            isDense: true,
          ),
        ),
        if (title != null && title!.isNotEmpty)
          Positioned(
            top: -12.0, // Đẩy title lên để đè lên border
            left: 16.0, // Căn lề trái cho title
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6 / 2),
              decoration: BoxDecoration(color: Colors.white),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
