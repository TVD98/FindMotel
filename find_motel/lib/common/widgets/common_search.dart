import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWithCallback extends StatefulWidget {
  final String initialText;
  final String hintText;
  final ValueChanged<String>? onSearchPressed;

  const SearchBarWithCallback({
    super.key,
    required this.initialText,
    this.hintText = '',
    this.onSearchPressed,
  });

  @override
  State<SearchBarWithCallback> createState() => _SearchBarWithCallbackState();
}

class _SearchBarWithCallbackState extends State<SearchBarWithCallback> {
  final TextEditingController _textController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của text để hiển thị/ẩn nút xóa
    _textController.addListener(_onTextChanged);
    _textController.text = widget.initialText;
  }

  @override
  void didUpdateWidget(covariant SearchBarWithCallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText) {
      if (_textController.text != widget.initialText) {
        _textController.text = widget.initialText;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
      _onTextChanged();
    }
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _textController.text.isNotEmpty;
    });
  }

  void _clearText() {
    _textController.clear();
    widget.onSearchPressed!('');
    setState(() {
      _showClearButton = false;
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.elementPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(left: 16),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showClearButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: _clearText,
                    child: const Icon(
                      Icons.clear,
                      color: Color(0xFFBDBDBD),
                      size: 22,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    if (widget.onSearchPressed != null) {
                      widget.onSearchPressed!(_textController.text);
                    }
                  },
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFFBDBDBD),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
