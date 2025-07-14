import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
// CommonTextfield đã được cập nhật ở trên

// Định nghĩa typedef cho callback để dễ đọc hơn
typedef OnPriceRangeChanged = void Function(double minPrice, double maxPrice);

class PriceRangeInputView extends StatefulWidget {
  final OnPriceRangeChanged? onPriceRangeChanged;
  final RangeValues initialValues;

  const PriceRangeInputView({
    super.key,
    this.onPriceRangeChanged,
    this.initialValues = const RangeValues(0, 0),
  });

  @override
  State<PriceRangeInputView> createState() => _PriceRangeInputViewState();
}

class _PriceRangeInputViewState extends State<PriceRangeInputView> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gán giá trị khởi tạo cho controllers
    // Cần loại bỏ định dạng để thiết lập giá trị số thuần túy
    _minPriceController.text = widget.initialValues.start.toVND();
    _maxPriceController.text = widget.initialValues.end.toVND();

    // Lắng nghe sự thay đổi của text fields để kích hoạt callback
    _minPriceController.addListener(_notifyParentOnPriceChange);
    _maxPriceController.addListener(_notifyParentOnPriceChange);
  }

  // Hàm tiện ích để loại bỏ định dạng tiền tệ
  String _unformatCurrency(String formattedText) {
    return formattedText.replaceAll(RegExp(r'[^0-9]'), '');
  }

  void _notifyParentOnPriceChange() {
    // Lấy giá trị sau khi loại bỏ định dạng để truyền đi
    final double minPrice = double.parse(
      _unformatCurrency(_minPriceController.text),
    );
    final double maxPrice = double.parse(
      _unformatCurrency(_maxPriceController.text),
    );

    widget.onPriceRangeChanged?.call(minPrice, maxPrice);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CommonTextfield(
              controller: _minPriceController,
              title: 'Từ',
              hintText: 'Giá tối thiểu',
              keyboardType: TextInputType.number,
              style: TextFieldStyle.medium,
              titleBackground: AppColors.surface,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '-',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CommonTextfield(
              controller: _maxPriceController,
              title: 'Đến',
              hintText: 'Giá tối đa',
              keyboardType: TextInputType.number,
              style: TextFieldStyle.medium,
              titleBackground: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
