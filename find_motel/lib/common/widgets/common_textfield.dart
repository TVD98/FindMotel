import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Define an enum for the TextField style
enum TextFieldStyle { large, medium }

class CommonTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String? title;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextFieldStyle style;
  final Color? titleBackground;

  const CommonTextfield({
    super.key,
    required this.controller,
    this.title,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.inputFormatters,
    this.style = TextFieldStyle.large,
    this.titleBackground,
  });

  @override
  State<CommonTextfield> createState() => _CommonTextfieldState();
}

class _CommonTextfieldState extends State<CommonTextfield> {
  // Biến để kiểm tra xem có nên áp dụng định dạng tiền tệ không
  bool _shouldFormatAsCurrency = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra keyboardType để xác định có định dạng tiền tệ hay không
    _shouldFormatAsCurrency =
        widget.keyboardType == TextInputType.number &&
        widget.inputFormatters == null;

    if (_shouldFormatAsCurrency) {
      widget.controller.addListener(_formatCurrencyText);
      // Áp dụng định dạng ngay lập tức nếu có giá trị ban đầu và là số
      if (widget.controller.text.isNotEmpty) {
        _formatCurrencyText();
      }
    }
  }

  @override
  void dispose() {
    if (_shouldFormatAsCurrency) {
      widget.controller.removeListener(_formatCurrencyText);
    }
    super.dispose();
  }

  // Hàm định dạng tiền tệ
  void _formatCurrencyText() {
    final TextEditingController priceController = widget.controller;
    // Xóa tất cả các ký tự không phải số
    final text = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Nếu rỗng, đặt lại giá trị rỗng và thoát
    if (text.isEmpty) {
      if (priceController.text.isNotEmpty) {
        priceController.value = const TextEditingValue(text: '');
      }
      return;
    }

    // Parse thành số và định dạng lại
    final formatted = NumberFormat('#,###', 'vi_VN').format(int.parse(text));

    // Nếu giá trị đã định dạng khác với giá trị hiện tại của controller, cập nhật lại
    if (priceController.text != formatted) {
      priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double textFieldFontSize;
    EdgeInsets contentPadding;
    FontWeight textFieldFontWeight;

    double titleFontSize;
    FontWeight titleFontWeight;

    switch (widget.style) {
      case TextFieldStyle.large:
        textFieldFontSize = 16;
        contentPadding = const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        );
        textFieldFontWeight =
            FontWeight.w400; // Default font weight for medium TextField input

        titleFontSize = 12; // Default title font size
        titleFontWeight = FontWeight.w600; // Default title font weight
        break;
      case TextFieldStyle.medium:
        textFieldFontSize = 14;
        contentPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 5);
        textFieldFontWeight =
            FontWeight.w400; // Default font weight for medium TextField input

        titleFontSize = 10; // Default title font size
        titleFontWeight = FontWeight.w600; // Default title font weight
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType ?? TextInputType.text,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          style: GoogleFonts.quicksand(
            fontSize: textFieldFontSize,
            fontWeight: textFieldFontWeight,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? '',
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.strokeLight),
            ),
            isDense: true,
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
