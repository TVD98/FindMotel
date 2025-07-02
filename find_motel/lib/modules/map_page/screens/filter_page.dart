// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/circular_checkbox_list.dart';
import 'package:find_motel/common/custom_button.dart';
import 'package:find_motel/common/custom_choice_chip.dart';
import 'package:find_motel/common/integer_range_slider.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/models/filter_motels_model.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/screens/fixed_dropdown_button.dart';
import 'package:flutter/material.dart';
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
  final List<String> _allProvinceOptions = ['Tp. Hồ Chí Minh'];
  final List<String> _allWardOptions =
      ['Tất cả'] + AppDataManager().allWardOfTPHCM;
  final List<String> _allStatusOptions = ['Trống', 'Đã cọc', 'Đã thuê'];

  late String _selectedRoomCode;
  late String _selectedProvince;
  late String _selectedWard;
  late List<String> _selectedAmenities;
  late String? _selectedStatus;
  late RangeValues _selectedPriceRangeValues;
  late RangeValues _selectedDistanceRangeValues;

  @override
  void initState() {
    super.initState();
    final initialData = AppDataManager().filterMotels;
    _selectedRoomCode = initialData.roomCode ?? '';
    _selectedProvince = initialData.province ?? '';
    _selectedWard = initialData.ward ?? '';
    _selectedAmenities = initialData.amenities ?? [];
    _selectedStatus = initialData.status ?? '';
    _selectedPriceRangeValues = initialData.priceRange ?? RangeValues(0, 2);
    _selectedDistanceRangeValues =
        initialData.distanceRange ?? RangeValues(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lọc nhà trọ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 12.0,
                    ), // Space between text and dropdown
                    child: Text(
                      'Mã phòng:',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF248078),
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
              ),
              const Divider(
                height: 30.0, // Total height including spacing
                thickness: 1.0, // Line thickness
                color: Colors.grey, // Line color
              ),
              Text(
                'Khu vực:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF248078),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              right: 12.0,
                            ), // Space between text and dropdown
                            child: Text(
                              'Tỉnh/Tp:',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF1F1F1F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FixedDropdownButton(
                              value: _selectedProvince,
                              items: _allProvinceOptions,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              right: 12.0,
                            ), // Space between text and dropdown
                            child: Text(
                              'Phường/xã:',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF1F1F1F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FixedDropdownButton(
                              value: _selectedWard,
                              items: _allWardOptions,
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
              const Divider(
                height: 30.0, // Total height including spacing
                thickness: 1.0, // Line thickness
                color: Colors.grey, // Line color
              ),
              Text(
                'Tiện ích:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF248078),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 8.0, // Khoảng cách giữa các chip
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
              const Divider(
                height: 30.0, // Total height including spacing
                thickness: 1.0, // Line thickness
                color: Colors.grey, // Line color
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Text(
                      'Tình trạng:',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF248078),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CircularCheckboxList(
                      items: _allStatusOptions,
                      initialSelected: _selectedStatus == 'Tất cả'
                          ? null
                          : _selectedStatus,
                      onChange: (value) {
                        _selectedStatus = value.isEmpty ? 'Tất cả' : value;
                      },
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 30.0, // Total height including spacing
                thickness: 1.0, // Line thickness
                color: Colors.grey, // Line color
              ),
              Column(
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
                            color: Color(0xFF248078),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      buildRangeValueText(
                        _selectedPriceRangeValues,
                        10,
                        'triệu',
                      ),
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
              ),
              const Divider(
                height: 30.0, // Total height including spacing
                thickness: 1.0, // Line thickness
                color: Colors.grey, // Line color
              ),
              Column(
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
                            color: Color(0xFF248078),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      buildRangeValueText(
                        _selectedDistanceRangeValues,
                        10,
                        'km',
                      ),
                    ],
                  ),
                  IntegerRangeSlider(
                    minValue: 1,
                    maxValue: 11,
                    initialRange: _selectedDistanceRangeValues,
                    labelsBuilder: (values) {
                      final int maxValue = values.end.round();
                      return RangeLabels(
                        '${values.start.round()}',
                        maxValue == 11 ? '10+' : '$maxValue',
                      );
                    },
                    onChanged: (values) {
                      setState(() {
                        _selectedDistanceRangeValues = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: CustomButton(
                            title: 'Xoá',
                            textColor: Color(0xFF248078),
                            backgroundColor: Color(0xFFFAFFFD),
                            strokeColor: Color(0xFFD1D1D1),
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
                            textColor: Color(0xFFFAFFFD),
                            backgroundColor: Color(0xFF248078),
                            strokeColor: Color(0xFFD1D1D1),
                            radius: 4.0,
                            onPressed: () {
                              _saveFilterMotels();
                              context.read<MapBloc>().add(
                                FilterMarkersEvent(
                                  roomCode: _formatStringSelection(
                                    _selectedRoomCode,
                                  ),
                                  province: _formatStringSelection(
                                    _selectedProvince,
                                  ),
                                  ward: _formatStringSelection(_selectedWard),
                                  amenities: _selectedAmenities,
                                  status: _formatStringSelection(
                                    _selectedStatus,
                                  ),
                                  priceRange: _selectedPriceRangeValues,
                                  distanceRange: _selectedDistanceRangeValues,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatStringSelection(String? input) {
    return input == 'Tất cả' ? null : input;
  }

  void _saveFilterMotels() {
    AppDataManager().filterMotels = FilterMotelsModel(
      roomCode: _selectedRoomCode,
      province: _selectedProvince,
      ward: _selectedWard,
      amenities: _selectedAmenities,
      status: _selectedStatus,
      priceRange: _selectedPriceRangeValues,
      distanceRange: _selectedDistanceRangeValues,
    );
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
        color: Color(0xFF474747),
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
