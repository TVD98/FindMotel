import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/widgets/common_selection_view.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/common/widgets/fixed_dropdown_button.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';

class MotelFeesForm extends StatefulWidget {
  final List<Fee> fees;
  final Function(Fee fee) onFeeAdded;
  final Function(Fee fee) onFeeDeleted;
  final Function(Fee fee) onFeeUpdated;

  const MotelFeesForm({
    super.key,
    required this.fees,
    required this.onFeeAdded,
    required this.onFeeDeleted,
    required this.onFeeUpdated,
  });

  @override
  State<MotelFeesForm> createState() => _MotelFeesFormState();
}

class _MotelFeesFormState extends State<MotelFeesForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.fees.map((fee) => _buildFeeItem(fee)),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => _showAddFeeDialog(null),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.onSecondary,
            ),
            label: Text(
              'Thêm phí khác',
              style: AppTextStyle.smallLabel.copyWith(
                color: AppColors.onPrimary,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.tertiary,
              side: const BorderSide(color: AppColors.strokeLight, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeItem(Fee fee) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: CommonSelectionView(
              value: '${fee.price.toVND()}/${fee.unit}',
              title: fee.name,
              titleBackground: Theme.of(context).scaffoldBackgroundColor,
              suffixIcon: const Icon(
                Icons.edit,
                color: AppColors.elementPrimary,
                size: 20,
              ),
              onTap: () => _showAddFeeDialog(fee),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => widget.onFeeDeleted(fee),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFeeDialog(Fee? fee) async {
    final nameControllerDialog = TextEditingController(text: fee?.name);
    final priceControllerDialog = TextEditingController(
      text: fee?.price.toVND(),
    );
    String selectedUnit = fee?.unit ?? 'người';
    final units = ['số', 'người', 'phòng', 'tháng', 'lần'];

    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Thêm Phí Dịch Vụ',
                style: AppTextStyle.heading5.copyWith(color: AppColors.primary),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 326, maxWidth: 326),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonTextfield(
                      controller: nameControllerDialog,
                      label: 'Tên phí',
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                    ),
                    const SizedBox(height: 16),
                    CommonTextfield(
                      controller: priceControllerDialog,
                      label: 'Số tiền',
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FixedDropdownButton(
                        items: units,
                        value: selectedUnit,
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final name = nameControllerDialog.text.trim();
                    final price =
                        double.tryParse(
                          priceControllerDialog.text.replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                        ) ??
                        0;

                    if (name.isNotEmpty && price > 0) {
                      Navigator.pop(
                        context,
                        Fee(name: name, price: price, unit: selectedUnit),
                      );
                    }
                  },
                  child: Text(
                    fee == null ? 'Thêm' : 'Cập nhật',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (result is Fee) {
      if (fee != null) {
        widget.onFeeUpdated(result);
      } else {
        widget.onFeeAdded(result);
      }
    }
  }
}
