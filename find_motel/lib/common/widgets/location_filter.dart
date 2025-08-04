import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/common/widgets/fixed_dropdown_button.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';

class LocationFilter extends StatefulWidget {
  final Address? address;

  // Thêm các hàm callback
  final void Function(Address? newAddress)? onAddressChanged;

  const LocationFilter({
    super.key,
    required this.address,
    this.onAddressChanged,
  });

  @override
  State<LocationFilter> createState() => _LocationFilterState();
}

class _LocationFilterState extends State<LocationFilter> {
  final List<Province> _province = AppDataManager().allProvinces;
  late List<District> _districts;
  late List<Ward> _wards;
  late String _selectedProvince;
  late String _selectedDistrict;
  late String _selectedWard;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.address?.province ?? 'Tất cả';
    _selectedDistrict = widget.address?.district ?? 'Tất cả';
    _selectedWard = widget.address?.ward ?? 'Tất cả';
    _updateDistricts(_selectedProvince);
    _updateWards(_selectedDistrict);
  }

  void _updateDistricts(String province) {
    if (province == 'Tất cả') {
      _districts = [District(code: 0, name: 'Tất cả', wards: [])];
    } else {
      _districts =
          [District(code: 0, name: 'Tất cả', wards: [])] +
          _province.firstWhere((e) => e.name == province).districts;
    }
  }

  void _updateWards(String district) {
    if (district == 'Tất cả') {
      _wards = [Ward(code: 0, name: 'Tất cả')];
    } else {
      _wards =
          [Ward(code: 0, name: 'Tất cả')] +
          _districts.firstWhere((e) => e.name == district).wards;
    }
  }

  String? _formatStringSelection(String? input) =>
      input == 'Tất cả' ? null : input;

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
                        value: _selectedProvince,
                        items:
                            ['Tất cả'] + _province.map((e) => e.name).toList(),
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onAddressChanged != null) {
                            final newAddress = Address(
                              province: _formatStringSelection(value),
                              district: null,
                              ward: null,
                            );
                            widget.onAddressChanged!(newAddress);
                            setState(() {
                              _selectedProvince = value ?? 'Tất cả';
                              _updateDistricts(_selectedProvince);
                              _selectedDistrict =
                                  _districts.firstOrNull?.name ?? 'Tất cả';
                              _updateWards(_selectedDistrict);
                              _selectedWard =
                                  _wards.firstOrNull?.name ?? 'Tất cả';
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
                        value: _selectedDistrict,
                        items: _districts.map((e) => e.name).toList(),
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onAddressChanged != null) {
                            final newAddress = Address(
                              province: _selectedProvince,
                              district: _formatStringSelection(value),
                              ward: null,
                            );
                            widget.onAddressChanged!(newAddress);
                            setState(() {
                              _selectedDistrict = value ?? 'Tất cả';
                              _updateWards(_selectedDistrict);
                              _selectedWard =
                                  _wards.firstOrNull?.name ?? 'Tất cả';
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
                        value: _selectedWard,
                        items: _wards.map((e) => e.name).toList(),
                        style: DropdownStyle.large,
                        onChanged: (value) {
                          if (widget.onAddressChanged != null) {
                            final newAddress = Address(
                              province: _selectedProvince,
                              district: _selectedDistrict,
                              ward: _formatStringSelection(value),
                            );
                            widget.onAddressChanged!(newAddress);
                            setState(() {
                              _selectedWard = value ?? 'Tất cả';
                            });
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
