import 'package:find_motel/common/constants/constant.dart';
import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/common/widgets/price_range_input.dart';
import 'package:find_motel/common/widgets/rectange_checkbox_list.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/common/widgets/custom_choice_chip.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/common/widgets/fixed_dropdown_button.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final List<String> _allAmenitiesOptions = AppDataManager().allAmenities;
  final List<Province> _allProvinceOptions = AppDataManager().allProvinces;
  final List<CheckboxItem> _allStatusOptions = AppDataManager().allStatus
      .map((e) => (e.name, e.title))
      .toList();
  final List<String> _allTextureOptions = AppDataManager().allTexturies;
  final List<String> _allRoomTypeOptions = AppDataManager().allRoomTypies;

  late String _selectedProvince;
  late String _selectedWard;
  late String _selectedRoomType;
  late List<String> _selectedAmenities;
  late List<String> _selectedStatusList;
  late List<String> _selectedTextureList;
  late RangeValues _selectedPriceRangeValues;
  late TextEditingController _roomCodeController;
  late TextEditingController _distanceController;

  MotelsFilter get _motelsFilter => AppDataManager().filterMotels.copyWith(
    roomCode: _roomCodeController.text.isEmpty ? '' : _roomCodeController.text,
    address: Address(
      province: _formatStringSelection(_selectedProvince),
      ward: _formatStringSelection(_selectedWard),
    ),
    amenities: _selectedAmenities.isEmpty ? [] : _selectedAmenities,
    status: _selectedStatusList.isEmpty ? [] : _selectedStatusList,
    texturies: _selectedTextureList.isEmpty ? [] : _selectedTextureList,
    type: _selectedRoomType,
    priceRange: Range2D(
      values: _selectedPriceRangeValues,
      maxValue: Constant.maxPrice,
    ),
    distanceRange: Range(
      value: double.tryParse(_distanceController.text) ?? Constant.maxDistance,
      maxValue: Constant.maxDistance,
    ),
  );

  MotelsFilter get _motelsFilterDefault =>
      AppDataManager().filterMotels.copyWith(
        roomCode: '',
        address: Address(
          province: _formatStringSelection(_selectedProvince),
          ward: _formatStringSelection('Tất cả'),
        ),
        amenities: [],
        status: [],
        texturies: [],
        type: 'Khác',
        priceRange: Range2D(
          values: const RangeValues(1_000_000, 10_000_000),
          maxValue: Constant.maxPrice,
        ),
        distanceRange: Range(
          value: Constant.defaultDistance,
          maxValue: Constant.maxDistance,
        ),
      );

  @override
  void initState() {
    super.initState();

    _setupFieldsByFilters();
  }

  void _setupFieldsByFilters() {
    final initialData = AppDataManager().filterMotels;
    _selectedProvince = initialData.address?.province ?? 'Tất cả';
    _selectedWard = initialData.address?.ward ?? 'Tất cả';
    _selectedAmenities = initialData.amenities ?? [];
    _selectedStatusList = initialData.status ?? [];
    _selectedTextureList = initialData.texturies ?? [];
    _selectedRoomType = initialData.type ?? '';
    _selectedPriceRangeValues =
        initialData.priceRange?.values ??
        const RangeValues(1_000_000, 10_000_000);
    _roomCodeController = TextEditingController(text: initialData.roomCode);
    _distanceController = TextEditingController(
      text: initialData.distanceRange?.value.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onSurface1,
      appBar: CommonAppBar(title: 'Bộ lọc'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomCodeRow(),
              _divider(),
              _buildAreaSection(),
              _divider(),
              _buildAmenitiesSection(),
              _divider(),
              _buildPriceRangeSection(),
              _divider(),
              _buildDistanceSection(),
              _divider(),
              _buildRoomTypeSection(),
              _divider(),
              _buildStatusSection(),
              _divider(),
              _buildTextureSection(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 30.0, thickness: 1.0, color: AppColors.strokeLight);

  Widget _buildRoomCodeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Text(
            'Mã phòng:',
            style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
          ),
        ),
        Expanded(
          child: CommonTextfield(
            controller: _roomCodeController,
            style: TextFieldStyle.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khu vực:',
          style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Tỉnh/Tp:',
                        style: AppTextStyle.smallLabel.copyWith(
                          color: AppColors.elementPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FixedDropdownButton(
                        value: _selectedProvince,
                        items: _allProvinceOptions.map((e) => e.name).toList(),
                        // width: 162.0,
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          setState(() {
                            _selectedProvince = value ?? 'Tất cả';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Phường/xã:',
                        style: AppTextStyle.smallLabel.copyWith(
                          color: AppColors.elementPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FixedDropdownButton(
                        value: _selectedWard,
                        items:
                            ['Tất cả'] +
                            _allProvinceOptions[_allProvinceOptions.indexWhere(
                                  (e) => e.name == _selectedProvince,
                                )]
                                .wards,
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          setState(() {
                            _selectedWard = value ?? 'Tất cả';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiện ích:',
          style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
        ),
        Wrap(
          spacing: 8.0,
          children: _allAmenitiesOptions.map((option) {
            return CustomChoiceChip(
              title: option,
              selected: _selectedAmenities.contains(option),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedAmenities.add(option);
                  } else {
                    _selectedAmenities.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Giá thuê:',
              style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
            ),
          ),
          Expanded(
            child: PriceRangeInputView(
              onPriceRangeChanged: (minPrice, maxPrice) {
                _selectedPriceRangeValues = RangeValues(minPrice, maxPrice);
              },
              initialValues: _selectedPriceRangeValues,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSection() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            'Phạm vi:',
            style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
          ),
        ),
        Text(
          '≤',
          style: AppTextStyle.smallLabel.copyWith(
            color: AppColors.elementSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            SizedBox(
              width: 90,
              child: CommonTextfield(
                controller: _distanceController,
                style: TextFieldStyle.medium,
                backgroundColor: AppColors.onSurface1,
              ),
            ),
            Positioned(
              right: 8,
              child: Text(
                'km',
                style: AppTextStyle.smallLabel.copyWith(
                  color: AppColors.elementSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomTypeSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Text(
            'Kiểu phòng:',
            style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RectangeCheckboxList(
            items: _allRoomTypeOptions.map((e) => (e, e)).toList(),
            initialSelected: [_selectedRoomType],
            selectionMode: CheckboxListSelectionMode.single,
            displayMode: CheckboxListDisplayMode.grid,
            gridCrossAxisCount: 2,
            gridChildAspectRatio: 4.0,
            onChange: (value) {
              _selectedRoomType = value.firstOrNull ?? '';
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Text(
            'Tình trạng:',
            style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RectangeCheckboxList(
            items: _allStatusOptions,
            initialSelected: _selectedStatusList,
            displayMode: CheckboxListDisplayMode.grid,
            gridCrossAxisCount: 3,
            onChange: (value) {
              _selectedStatusList = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kết cấu:',
          style: AppTextStyle.smallLabel.copyWith(color: AppColors.primary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RectangeCheckboxList(
            items: _allTextureOptions.map((e) => (e, e)).toList(),
            initialSelected: _selectedTextureList,
            displayMode: CheckboxListDisplayMode.grid,
            gridCrossAxisCount: 2,
            gridChildAspectRatio: 4.0,
            onChange: (value) {
              _selectedTextureList = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: CustomButton(
              label: 'Đặt lại',
              textColor: AppColors.primary,
              textStyle: AppTextStyle.smallLabel,
              backgroundColor: AppColors.onPrimary,
              isNoBorder: false,
              strokeColor: AppColors.strokeHighLight,
              radius: 4.0,
              onPressed: () {
                final MotelsFilter filters = _motelsFilterDefault;
                context.read<MotelsFilterCubit>().updateFilter(filters);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<MotelsFilterCubit>(),
                      child: const FilterPage(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 46),
        Expanded(
          child: SizedBox(
            height: 44,
            child: CustomButton(
              label: 'Áp dụng',
              textStyle: AppTextStyle.smallLabel,
              radius: 4.0,
              onPressed: () {
                final MotelsFilter filters = _motelsFilter;
                context.read<MotelsFilterCubit>().updateFilter(filters);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // Data helper methods
  // ----------------------------

  String? _formatStringSelection(String? input) =>
      input == 'Tất cả' ? null : input;

  Widget buildRangeValueText(RangeValues values, double maxValue) {
    final double startValue = values.start;
    final double endValue = values.end;
    final String content;
    if (endValue > maxValue) {
      content = '> ${startValue.toVND()}';
    } else if (startValue == 0) {
      content = '< ${endValue.toVND()}';
    } else {
      content = '${startValue.toVND()} - ${endValue.toVND()}';
    }

    return Text(
      content,
      style: const TextStyle(
        color: AppColors.elementSecondary,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
