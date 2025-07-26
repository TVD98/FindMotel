
import 'package:find_motel/common/models/filter_option.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CommonBottomSheet extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final List<FilterOption> initialSelectedOptions;
  final bool isMultiSelect;
  final ValueChanged<List<FilterOption>> onApply;
  final VoidCallback? onCancel;

  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.initialSelectedOptions = const [], // Mặc định là rỗng
    this.isMultiSelect = false, // Mặc định là chọn 1 mục
    required this.onApply,
    this.onCancel,
  });

  @override
  State<CommonBottomSheet> createState() => _CommonBottomSheetState();
}

class _CommonBottomSheetState extends State<CommonBottomSheet> {
  late Set<FilterOption> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = Set.from(widget.initialSelectedOptions);
  }

  void _toggleOption(FilterOption option) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
      } else {
        if (_selectedOptions.contains(option)) {
          _selectedOptions.clear();
        } else {
          _selectedOptions.clear();
          _selectedOptions.add(option);
        }
      }
    });
  }

  void _applySelection() {
    widget.onApply(_selectedOptions.toList());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.elementSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Divider(color: AppColors.strokeLight),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              final isSelected = _selectedOptions.contains(option);

              return InkWell(
                onTap: () => _toggleOption(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.elementPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          widget.isMultiSelect
                              ? Icons.check_box
                              : Icons.radio_button_checked,
                          color: AppColors.primary,
                        )
                      else
                        Icon(
                          widget.isMultiSelect
                              ? Icons.check_box_outline_blank
                              : Icons.radio_button_off,
                          color: AppColors.elementPrimary,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Nút "Áp dụng"
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _applySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20,
          ),
        ],
      ),
    );
  }
}
