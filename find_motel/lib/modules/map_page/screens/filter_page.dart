// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/circular_checkbox_list.dart';
import 'package:find_motel/common/custom_choice_chip.dart';
import 'package:find_motel/common/integer_range_slider.dart';
import 'package:find_motel/modules/map_page/screens/fixed_dropdown_button.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? _selectedValue;
  final List<String> _selectedChoices = [];
  final List<String> _allOptions = ['Thang máy', 'Xe'];
  RangeValues _selectedPriceRangeValues = const RangeValues(0, 2);
  RangeValues _selectedDistanceRangeValues = const RangeValues(0, 1);

  @override
  void initState() {
    super.initState();
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
                    value: _selectedValue,
                    items: ['Option 1', 'Option 2', 'Option 3'],
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
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
                  width: 250,
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
                              value: _selectedValue,
                              items: ['Option 1', 'Option 2', 'Option 3'],
                              width: 162.0,
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value;
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
                              value: _selectedValue,
                              items: ['Option 1', 'Option 2', 'Option 3'],
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value;
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
                children: _allOptions.map((option) {
                  return CustomChoiceChip(
                    title: option,
                    selected: _selectedChoices.contains(option),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedChoices.add(option);
                        } else {
                          _selectedChoices.remove(option);
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
                      items: ['Trống', 'Đặt cọc', 'Đã thuê'],
                      initialSelected: null,
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
                    initialRange: const RangeValues(0, 2),
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
                    initialRange: const RangeValues(1, 2),
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
                ],
              ),
            ],
          ),
        ),
      ),
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
