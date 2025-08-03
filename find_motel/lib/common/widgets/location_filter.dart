import 'dart:math';

import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/common/widgets/fixed_dropdown_button.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:find_motel/services/location_api_service.dart';
import 'package:find_motel/common/constants/constant.dart';

class LocationFilter extends StatefulWidget {
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedWard;

  // Thêm các hàm callback
  final void Function(String? newProvince)? onProvinceChanged;
  final void Function(String? newDistrict)? onDistrictChanged;
  final void Function(String? newWard)? onWardChanged;

  const LocationFilter({
    super.key,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedWard,
    this.onProvinceChanged,
    this.onDistrictChanged,
    this.onWardChanged,
  });

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  final List<Province> _province = AppDataManager().allProvinces;
  // Lưu trữ danh sách Quận/Huyện và Phường/Xã nội bộ
  List<District> _districts = [];
  List<Ward> _wards = []; 


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        value: widget.selectedProvince,
                        items:
                            ['Tất cả'] + _province.map((e) => e.name).toList(),
                        // width: 162.0,
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onProvinceChanged != null) {
                            widget.onProvinceChanged!(value);
                            setState(() {
                              _districts = _province[_province.indexWhere((e) => e.name == value)].districts;
                              _wards = _districts[_districts.indexWhere((e) => e.name == widget.selectedDistrict)].wards;
                            });
                          }
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
                        'Quận/huyện:',
                        style: AppTextStyle.smallLabel.copyWith(
                          color: AppColors.elementPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FixedDropdownButton(
                        value: widget.selectedDistrict,
                        items:
                            ['Tất cả'] + _districts.map((e) => e.name).toList(),
                        // ['Tất cả'] +
                        // province[province.indexWhere(
                        //       (e) => e.name == widget.selectedProvince,
                        //     )]
                        //     .wards,
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onDistrictChanged != null) {
                            widget.onDistrictChanged!(value);
                            setState(() {
                              _wards = _districts[_districts.indexWhere((e) => e.name == value)].wards;
                            });

                          }
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
                        value: widget.selectedWard,
                        items: ['Tất cả'] + _wards.map((e) => e.name).toList(),
                        // ['Tất cả'] +
                        // province[province.indexWhere(
                        //       (e) => e.name == widget.selectedProvince,
                        //     )]
                        //     .wards,
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onWardChanged != null) {
                            widget.onWardChanged!(value);
                          }
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
}
