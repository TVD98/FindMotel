import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:find_motel/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/managers/app_data_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IGeolocatorService _geolocatorService;
  HomeBloc({IGeolocatorService? geolocatorService})
    : _geolocatorService = geolocatorService ?? GeolocatorService(),
      super(const HomeState()) {
    on<TabSelected>((event, emit) {
      emit(state.copyWith(selectedIndex: event.index));
    });

    on<LoadCurrentLocationEvent>((event, emit) async {
      try {
        final result = await _geolocatorService.getCurrentLocation();
        if (result.error != null || result.position == null) {
          return;
        }
        final pos = result.position!;
        AppDataManager().currentLocation = LatLng(pos.latitude, pos.longitude);
      } catch (e) {
        print('[HomeBloc] Error getting location: $e');
      }
    });
  }
}
