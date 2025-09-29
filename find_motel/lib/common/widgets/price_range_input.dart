import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyParentOnPriceChange();
    });
  }

  void _notifyParentOnPriceChange() {
    // Lấy giá trị sau khi loại bỏ định dạng để truyền đi
    final double minPrice = _minPriceController.text.replaceAll(RegExp(r'[^0-9]'), '').toPrice();
    final double maxPrice = _maxPriceController.text.replaceAll(RegExp(r'[^0-9]'), '').toPrice();

    widget.onPriceRangeChanged?.call(minPrice, maxPrice);
  }

  @override
  void dispose() {
    _minPriceController.removeListener(_notifyParentOnPriceChange);
    _maxPriceController.removeListener(_notifyParentOnPriceChange);
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isError;
    if (_minPriceController.text.isNotEmpty &&
        _maxPriceController.text.isNotEmpty) {
      isError = 
          _minPriceController.text.toPrice() >
          _maxPriceController.text.toPrice();
    } else {
      isError = false;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CommonTextfield(
              controller: _minPriceController,
              label: 'Từ',
              hintText: 'Giá tối thiểu',
              keyboardType: TextInputType.number,
              style: TextFieldStyle.medium,
              backgroundColor: AppColors.onSurface1,
              bolderColor: isError ? AppColors.error : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '-',
              style: AppTextStyle.body.copyWith(
                fontSize: 24,
                fontWeight: AppFontWeight.medium,
                color: AppColors.elementPrimary,
              ),
            ),
          ),
          Expanded(
            child: CommonTextfield(
              controller: _maxPriceController,
              label: 'Đến',
              hintText: 'Giá tối đa',
              keyboardType: TextInputType.number,
              style: TextFieldStyle.medium,
              backgroundColor: AppColors.onSurface1,
            ),
          ),
        ],
      ),
    );
  }
}
