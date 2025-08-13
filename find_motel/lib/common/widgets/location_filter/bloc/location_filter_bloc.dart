import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_filter_event.dart';
import 'location_filter_state.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/common/models/area.dart';

class LocationFilterBloc
    extends Bloc<LocationFilterEvent, LocationFilterState> {
  LocationFilterBloc()
    : super(
        LocationFilterState(
          provinces: [Province(id: '0', name: 'Tất cả', units: [])],
          districts: [Unit(id: '0', name: 'Tất cả', units: [])],
          wards: [Unit(id: '0', name: 'Tất cả', units: [])],
        ),
      ) {
    on<LoadProvinces>((event, emit) async {
      if (event.address != null) {
        final allProvinces = AppDataManager().allProvinces;
        final selectedProvinceName = event.address!.province ?? 'Tất cả';
        final selectedProvinceId = allProvinces
            .firstWhere(
              (e) => e.name == selectedProvinceName,
              orElse: () => Province(id: '0', name: 'Tất cả', units: []),
            )
            .id;

        final List<Unit> districts = await AppDataManager().getDistricts(
          selectedProvinceId,
        );
        final selectedDistrictName = event.address!.district ?? 'Tất cả';
        final selectedDistrictId = districts
            .firstWhere(
              (e) => e.name == selectedDistrictName,
              orElse: () => Unit(id: '0', name: 'Tất cả', units: []),
            )
            .id;

        final List<Unit> wards = await AppDataManager().getWards(
          selectedProvinceId,
          selectedDistrictId,
        );
        final selectedWardName = event.address!.ward ?? 'Tất cả';

        emit(
          state.copyWith(
            address: Address(
              province: selectedProvinceName,
              district: selectedDistrictName,
              ward: selectedWardName,
            ),
            provinces:
                [Province(id: '0', name: 'Tất cả', units: [])] + allProvinces,
            districts: [Unit(id: '0', name: 'Tất cả', units: [])] + districts,
            wards: [Unit(id: '0', name: 'Tất cả', units: [])] + wards,
          ),
        );
      } else {
        emit(
          state.copyWith(
            provinces:
                [Province(id: '0', name: 'Tất cả', units: [])] +
                AppDataManager().allProvinces,
          ),
        );
      }
    });

    on<ProvinceSelected>((event, emit) async {
      final provinceId = state.provinces
          .firstWhere(
            (e) => e.name == event.provinceName,
            orElse: () => Province(id: '0', name: 'Tất cả', units: []),
          )
          .id;
      final districts = await AppDataManager().getDistricts(provinceId);
      emit(
        state.copyWith(
          address: Address(
            province: event.provinceName,
            district: 'Tất cả',
            ward: 'Tất cả',
          ),
          districts: [Unit(id: '0', name: 'Tất cả', units: [])] + districts,
          wards: [Unit(id: '0', name: 'Tất cả', units: [])],
        ),
      );
    });

    on<DistrictSelected>((event, emit) async {
      final provinceId = state.provinces
          .firstWhere(
            (e) => e.name == state.address?.province,
            orElse: () => Province(id: '0', name: 'Tất cả', units: []),
          )
          .id;
      final districtId = state.districts
          .firstWhere(
            (e) => e.name == event.districtName,
            orElse: () => Unit(id: '0', name: 'Tất cả', units: []),
          )
          .id;
      final wards = await AppDataManager().getWards(provinceId, districtId);
      emit(
        state.copyWith(
          address: Address(
            province: state.address?.province,
            district: event.districtName,
            ward: 'Tất cả',
          ),
          wards: [Unit(id: '0', name: 'Tất cả', units: [])] + wards,
        ),
      );
    });

    on<WardSelected>((event, emit) {
      emit(
        state.copyWith(
          address: Address(
            province: state.address?.province,
            district: state.address?.district,
            ward: event.wardName,
          ),
        ),
      );
    });
  }
}
