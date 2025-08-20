import 'package:find_motel/common/widgets/fixed_dropdown_button.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/widgets/location_filter/bloc/location_filter_bloc.dart';
import 'package:find_motel/common/widgets/location_filter/bloc/location_filter_event.dart';
import 'package:find_motel/common/widgets/location_filter/bloc/location_filter_state.dart';

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
  String? _formatStringSelection(String? input) =>
      input == 'Tất cả' ? null : input;

  @override
  void initState() {
    super.initState();
    context.read<LocationFilterBloc>().add(LoadProvinces(widget.address));
  }

  @override
  void didUpdateWidget(covariant LocationFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      context.read<LocationFilterBloc>().add(LoadProvinces(widget.address));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationFilterBloc, LocationFilterState>(
      listenWhen: (previous, current) => previous.address != current.address,
      listener: (context, state) {
        widget.onAddressChanged?.call(
          Address(
            province: _formatStringSelection(state.address?.province),
            district: _formatStringSelection(state.address?.district),
            ward: _formatStringSelection(state.address?.ward),
          ),
        );
      },
      child: BlocBuilder<LocationFilterBloc, LocationFilterState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khu vực:',
                style: AppTextStyle.smallLabel.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: SizedBox(
                  width: double.infinity,
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
                              value: state.address?.province ?? 'Tất cả',
                              items: state.provinces
                                  .map((e) => e.name)
                                  .toList(),
                              style: DropdownStyle.large,
                              onChanged: (value) {
                                context.read<LocationFilterBloc>().add(
                                  ProvinceSelected(value!),
                                );
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
                              value: state.address?.district ?? 'Tất cả',
                              items: state.districts
                                  .map((e) => e.name)
                                  .toList(),
                              style: DropdownStyle.large,
                              onChanged: (value) {
                                context.read<LocationFilterBloc>().add(
                                  DistrictSelected(value!),
                                );
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
                              value: state.address?.ward ?? 'Tất cả',
                              items: state.wards.map((e) => e.name).toList(),
                              style: DropdownStyle.large,
                              onChanged: (value) {
                                context.read<LocationFilterBloc>().add(
                                  WardSelected(value!),
                                );
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
        },
      ),
    );
  }
}
