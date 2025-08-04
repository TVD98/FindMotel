import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';

class MotelPhoneNumbersForm extends StatefulWidget {
  final List<String> phoneNumbers;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onDelete;

  const MotelPhoneNumbersForm({
    super.key,
    required this.phoneNumbers,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<MotelPhoneNumbersForm> createState() => _MotelPhoneNumbersFormState();
}

class _MotelPhoneNumbersFormState extends State<MotelPhoneNumbersForm> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số điện thoại',
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.phoneNumbers.asMap().entries.map((entry) {
            final phone = entry.value;
            return Chip(
              label: Text(phone),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                widget.onDelete(phone);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CommonTextfield(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hintText: 'Nhập số điện thoại mới',
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newPhone = _phoneController.text.trim();
                if (newPhone.isNotEmpty &&
                    !widget.phoneNumbers.contains(newPhone)) {
                  widget.onAdd(newPhone);
                  _phoneController.clear();
                }
              },
              child: Text(
                'Thêm',
                style: AppTextStyle.label.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
