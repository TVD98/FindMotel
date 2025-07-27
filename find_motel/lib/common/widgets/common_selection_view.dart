import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define an enum for the TextField style (có thể giữ hoặc điều chỉnh tên cho phù hợp với SelectionView)
enum SelectionViewStyle { large, medium }

class CommonSelectionView extends StatefulWidget {
  final String? value; // Giá trị hiển thị, thay thế controller
  final String? title;
  final String? hintText;
  final bool enabled;
  final SelectionViewStyle style; // Đổi tên enum nếu muốn
  final Color? titleBackground;
  final VoidCallback? onTap; // Callback khi người dùng nhấn vào
  final Widget? suffixIcon; // Icon ở bên phải, mặc định là mũi tên xuống

  const CommonSelectionView({
    super.key,
    this.value, // Không còn là required vì có thể không có giá trị ban đầu
    this.title,
    this.hintText,
    this.enabled = true,
    this.style = SelectionViewStyle.large,
    this.titleBackground,
    this.onTap,
    this.suffixIcon, // Mặc định là mũi tên xuống
  });

  @override
  State<CommonSelectionView> createState() => _CommonSelectionViewState();
}

class _CommonSelectionViewState extends State<CommonSelectionView> {
  @override
  Widget build(BuildContext context) {
    double selectionFontSize;
    EdgeInsets contentPadding;
    FontWeight selectionFontWeight;

    double titleFontSize;
    FontWeight titleFontWeight;

    switch (widget.style) {
      case SelectionViewStyle.large:
        selectionFontSize = 16;
        contentPadding = const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        );
        selectionFontWeight = FontWeight.w400;

        titleFontSize = 12;
        titleFontWeight = FontWeight.w600;
        break;
      case SelectionViewStyle.medium:
        selectionFontSize = 14;
        contentPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 5);
        selectionFontWeight = FontWeight.w400;
        titleFontSize = 10;
        titleFontWeight = FontWeight.w600;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: widget.enabled ? widget.onTap : null, // Chỉ cho phép tap khi enabled
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: widget.enabled ? AppColors.elementPrimary : AppColors.elementPrimary.withOpacity(0.5),
                width: 1,
              ),
            ),
            padding: contentPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value?.isNotEmpty == true ? widget.value! : (widget.hintText ?? ''),
                    style: GoogleFonts.quicksand(
                      fontSize: selectionFontSize,
                      fontWeight: selectionFontWeight,
                      color: widget.value?.isNotEmpty == true
                          ? (widget.enabled ? Colors.black : Colors.grey)
                          : (widget.enabled ? AppColors.elementPrimary : AppColors.elementPrimary.withOpacity(0.5)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                widget.suffixIcon ??
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.enabled ? AppColors.elementPrimary : AppColors.elementPrimary.withOpacity(0.5),
                    ),
              ],
            ),
          ),
        ),
        if (widget.title != null && widget.title!.isNotEmpty)
          Positioned(
            top: -8.0,
            left: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              decoration: BoxDecoration(color: widget.titleBackground ?? Colors.white),
              child: Text(
                widget.title!,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: titleFontWeight,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}