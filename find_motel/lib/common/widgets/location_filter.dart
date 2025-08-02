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
  final LocationApiService _apiService = LocationApiService();
  final List<Province> _province = [];
  // Lưu trữ danh sách Quận/Huyện và Phường/Xã nội bộ
  List<District> _districts = [];
  List<Ward> _wards = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
    // _fetchDistrictsAndWards(Constant.provinceCodeHCM);
    // _updateDropdownData(widget.selectedDistrict, widget.selectedWard);
  }

  // Phương thức để cập nhật danh sách quận/huyện và phường/xã
  // void _updateDropdownData(String? district, String? ward) {
  //   if (district != null) {
  //     setState(() {
  //       widget.onDistrictChanged!(district);
  //       if(ward != null) {
  //         widget.onWardChanged!(ward);
  //       }
  //     });
  //   } else {
  //     setState(() {
  //       widget.onDistrictChanged!('Tất cả');
  //     });
  //   }
  // }

  Future<void> _fetchProvinces() async {
    try {
      final provinces = await _apiService.fetchProvinces();
      setState(() {
        _isLoading = true;
      });
      _province.addAll(provinces);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching provinces: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDistrictsAndWards(String provinceCode) async {
    int provinceCodeInt = int.parse(provinceCode);
    try {
      // Lấy chi tiết tỉnh, bao gồm cả huyện và xã
      final provinceDetails = await _apiService.fetchProvinceWithDetails(
        provinceCodeInt,
      );
      setState(() {
        _districts.addAll(provinceDetails.districts);
        widget.onDistrictChanged!('Tất cả');
        _wards=[];
      });
    } catch (e) {
      print('Error fetching districts and wards: $e');
    }
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
                            _fetchDistrictsAndWards(_province[_province.indexWhere((e) => e.name == value)].id);
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
                        value: widget.selectedWard,
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
                            _wards = _districts[_districts.indexWhere((e) => e.name == value)].wards;
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
