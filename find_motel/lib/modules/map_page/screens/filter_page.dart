// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/common/widgets/rectange_checkbox_list.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/common/widgets/custom_choice_chip.dart';
import 'package:find_motel/common/widgets/integer_range_slider.dart';
import 'package:find_motel/common/widgets/integer_slider.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/screens/fixed_dropdown_button.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final List<String> _allAmenitiesOptions = ['Thang máy', 'Xe'];
  final List<String> _allRoomCodeOptions = [
    'Tất cả',
    'L3',
    '301',
    '201',
    'P4',
    '101',
    'lửng B',
    'G01',
  ];
  final List<Province> _allProvinceOptions = AppDataManager().allProvinces;
  final List<CheckboxItem> _allStatusOptions = AppDataManager().allStatus
      .map((e) => (e.name, e.title))
      .toList();

  late String _selectedRoomCode;
  late String _selectedProvince;
  late String _selectedWard;
  late List<String> _selectedAmenities;
  late List<String> _selectedStatusList;
  late RangeValues _selectedPriceRangeValues;
  late int _selectedDistanceKm;

  @override
  void initState() {
    super.initState();
    final initialData = AppDataManager().filterMotels;
    _selectedRoomCode = initialData.roomCode ?? 'Tất cả';
    _selectedProvince = initialData.address?.province ?? 'Tất cả';
    _selectedWard = initialData.address?.ward ?? 'Tất cả';
    _selectedAmenities = initialData.amenities ?? [];
    _selectedStatusList = initialData.status ?? [];
    _selectedPriceRangeValues =
        initialData.priceRange?.values ?? const RangeValues(0, 11);
    _selectedDistanceKm = initialData.distanceRange?.value.toInt() ?? 11;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Tim kiếm'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomCodeRow(),
              _divider(),
              _buildAreaSection(),
              _divider(),
              _buildAmenitiesSection(),
              _divider(),
              _buildStatusSection(),
              _divider(),
              _buildPriceRangeSection(),
              _divider(),
              _buildDistanceSection(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
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
        const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Text(
            'Mã phòng:',
            style: TextStyle(
              fontSize: 16.0,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FixedDropdownButton(
          value: _selectedRoomCode,
          items: _allRoomCodeOptions,
          onChanged: (value) {
            setState(() {
              _selectedRoomCode = value ?? 'Tất cả';
            });
          },
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
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
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
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Tỉnh/Tp:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.elementSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FixedDropdownButton(
                        value: _selectedProvince,
                        items: _allProvinceOptions.map((e) => e.name).toList(),
                        width: 162.0,
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
                    const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Phường/xã:',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.elementSecondary,
                          fontWeight: FontWeight.w500,
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
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildStatusSection() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Text(
            'Tình trạng:',
            style: TextStyle(
              fontSize: 16.0,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: RectangeCheckboxList(
            items: _allStatusOptions,
            initialSelected: _selectedStatusList,
            onChange: (value) {
              _selectedStatusList = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Giá thuê:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildRangeValueText(_selectedPriceRangeValues, 10, 'triệu'),
          ],
        ),
        IntegerRangeSlider(
          minValue: 0,
          maxValue: 11,
          initialRange: _selectedPriceRangeValues,
          labelsBuilder: (values) {
            final int maxValue = values.end.round();
            return RangeLabels(
              '${values.start.round()}',
              maxValue == 11 ? '10+' : '$maxValue',
            );
          },
          onChanged: (values) {
            setState(() {
              _selectedPriceRangeValues = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Phạm vi:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildRangeValueText(
              RangeValues(0, _selectedDistanceKm.toDouble()),
              10,
              'km',
            ),
          ],
        ),
        IntegerSlider(
          minValue: 1,
          maxValue: 11,
          initialValue: _selectedDistanceKm,
          labelBuilder: (v) => v == 11 ? '10+' : v.toString(),
          onChanged: (val) {
            setState(() {
              _selectedDistanceKm = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: CustomButton(
              title: 'Xoá',
              textColor: AppColors.onPrimary,
              backgroundColor: AppColors.primary,
              strokeColor: AppColors.strokeLight,
              radius: 4.0,
              onPressed: () {},
            ),
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          child: SizedBox(
            height: 38,
            child: CustomButton(
              title: 'Apply',
              textColor: AppColors.onPrimary,
              backgroundColor: AppColors.primary,
              strokeColor: AppColors.strokeLight,
              radius: 4.0,
              onPressed: () {
                final MotelsFilter filters = MotelsFilter(
                  roomCode: _formatStringSelection(_selectedRoomCode),
                  address: Address(
                    province: _formatStringSelection(_selectedProvince),
                    ward: _formatStringSelection(_selectedWard),
                  ),
                  amenities: _selectedAmenities.isEmpty
                      ? null
                      : _selectedAmenities,
                  status: _selectedStatusList.isEmpty
                      ? null
                      : _selectedStatusList,
                  priceRange: Range2D(
                    values: _selectedPriceRangeValues,
                    maxValue: 10,
                  ),
                  distanceRange: Range(
                    value: _selectedDistanceKm.toDouble(),
                    maxValue: 10,
                  ),
                );

                _saveFilterMotels(filters);

                context.read<MapBloc>().add(FilterMotelsEvent(filter: filters));
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

  void _saveFilterMotels(MotelsFilter filter) {
    AppDataManager().filterMotels = filter;
  }

  Widget buildRangeValueText(RangeValues values, int maxValue, String unit) {
    final int startValue = values.start.round();
    final int endValue = values.end.round();
    final String content;
    if (endValue > maxValue) {
      content = '> $startValue $unit';
    } else if (startValue == 0) {
      content = '< $endValue $unit';
    } else {
      content = '$startValue - $endValue $unit';
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
