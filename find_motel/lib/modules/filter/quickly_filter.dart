import 'package:find_motel/common/models/filter_option.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/widgets/common_container.dart';
import 'package:find_motel/common/widgets/common_search.dart';
import 'package:find_motel/common/widgets/selection_bottom_sheet.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/filter/filter_page.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

typedef FilterChipCallback = MotelsFilter Function(List<FilterOption> options);

class QuicklyFilter extends StatefulWidget {
  const QuicklyFilter({super.key});

  @override
  State<QuicklyFilter> createState() => _QuicklyFilterState();
}

class _QuicklyFilterState extends State<QuicklyFilter> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotelsFilterCubit, MotelsFilter>(
      builder: (context, state) {
        return Column(
          children: [
            SearchBarWithCallback(
              initialText: state.keywords ?? '',
              hintText: 'Nhập vào tên hoặc địa chỉ…',
              onSearchPressed: (value) {
                context.read<MotelsFilterCubit>().search(value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _iconFilter(context),
                  const SizedBox(width: 10),
                  _statusFilterChip(context, state),
                  const SizedBox(width: 10),
                  _textureFilterChip(context, state),
                  const SizedBox(width: 10),
                  _amenitiesFilterChip(context, state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconFilter(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<MotelsFilterCubit>(),
              child: const FilterPage(),
            ),
          ),
        );
      },
      child: CommonContainer(
        child: SvgPicture.asset(
          'assets/images/ic_filter.svg',
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  Widget _statusFilterChip(BuildContext context, MotelsFilter filter) =>
      _FilterChip(
        context: context,
        label: 'Tình trạng',
        selectedOptions:
            filter.status
                ?.map(
                  (e) => RentalStatus.values.firstWhere(
                    (element) => element.name == e,
                  ),
                )
                .map((e) => FilterOption(id: e.name, name: e.title))
                .toList() ??
            [],
        allOptions: AppDataManager().allStatus
            .map((e) => FilterOption(id: e.name, name: e.title))
            .toList(),
        onApply: (options) {
          return filter.copyWith(status: options.map((e) => e.id).toList());
        },
      );

  Widget _textureFilterChip(BuildContext context, MotelsFilter filter) =>
      _FilterChip(
        context: context,
        label: 'Kết cấu',
        selectedOptions:
            filter.texturies
                ?.map((e) => FilterOption(id: e, name: e))
                .toList() ??
            [],
        allOptions: AppDataManager().allTexturies
            .map((e) => FilterOption(id: e, name: e))
            .toList(),
        onApply: (options) {
          return filter.copyWith(texturies: options.map((e) => e.id).toList());
        },
      );

  Widget _amenitiesFilterChip(BuildContext context, MotelsFilter filter) =>
      _FilterChip(
        context: context,
        label: 'Tiện ích',
        selectedOptions:
            filter.amenities
                ?.map((e) => FilterOption(id: e, name: e))
                .toList() ??
            [],
        allOptions: AppDataManager().allAmenities
            .map((e) => FilterOption(id: e, name: e))
            .toList(),
        onApply: (options) {
          return filter.copyWith(amenities: options.map((e) => e.id).toList());
        },
      );
}

class _FilterChip extends StatelessWidget {
  final BuildContext context;
  final String label;
  final List<FilterOption> selectedOptions;
  final List<FilterOption> allOptions;
  final bool isMultiSelect;
  final FilterChipCallback onApply;

  const _FilterChip({
    required this.context,
    required this.label,
    required this.selectedOptions,
    required this.allOptions,
    required this.onApply,
  }) : isMultiSelect = true;

  String _getTitle() {
    if (selectedOptions.length == 1) {
      return selectedOptions.first.name;
    } else {
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => _showFilter(context),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.strokeLight),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Text(
                _getTitle(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              _rightIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rightIcon() {
    if (selectedOptions.length > 1) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            selectedOptions.length.toString(),
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.primary,
        size: 22,
      );
    }
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return CommonBottomSheet(
          title: label,
          options: allOptions,
          initialSelectedOptions: selectedOptions,
          isMultiSelect: isMultiSelect,
          onApply: (selected) {
            final updateFilter = onApply(selected);
            context.read<MotelsFilterCubit>().updateFilter(updateFilter);
          },
        );
      },
    );
  }
}
