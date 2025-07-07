import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_motel/constants/firestore_paths.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:find_motel/services/catalog/catalog_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IGeolocatorService _geolocatorService;
  final ICatalogService _catalogService;
  HomeBloc({IGeolocatorService? geolocatorService, ICatalogService? catalogService})
    : _geolocatorService = geolocatorService ?? GeolocatorService(),
      _catalogService = catalogService ?? FirestoreService(),
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

    on<LoadCatalogEvent>((event, emit) async {
      try {
        final result = await _catalogService.fetchProvinces();
        if (result.error != null) {
          return;
        }
        final provinces = result.provinces!;
        AppDataManager().allProvinces = provinces;
      } catch (e) {
        print('[HomeBloc] Error getting catalog: $e');
      }
    });
  }
}
