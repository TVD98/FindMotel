import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileCubit extends Cubit<UserProfile> {
  UserProfileCubit()
    : super(UserProfile(id: '', email: '123@gmail.com', role: UserRole.sale));

  void updateUserProfile(UserProfile userProfile) {
    AppDataManager().currentUserProfile = userProfile;
    emit(userProfile);
  }
}

class MotelsFilterCubit extends Cubit<MotelsFilter> {
  MotelsFilterCubit()
    : super(
        MotelsFilter(
          roomCode: null,
          address: Address(province: 'Tp. Hồ Chí Minh', ward: null),
          amenities: null,
          status: null,
          texturies: null,
          type: 'Khác',
          priceRange: Range2D(
            values: RangeValues(1000000, 10000000),
            maxValue: 20000000,
          ),
          distanceRange: Range(value: 10, maxValue: 100),
        ),
      );

  void loadFilter() {
    AppDataManager().filterMotels = state;
  }

  void updateFilter(MotelsFilter filter) {
    AppDataManager().filterMotels = filter;
    emit(filter);
  }
}
