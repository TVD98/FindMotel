import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_motel/constants/firestore_paths.dart';
import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
import 'package:find_motel/services/catalog/catalog_service.dart';
import 'package:find_motel/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/authentication/authentication_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/authentication/firebase_auth_service.dart';
import 'package:find_motel/services/user_data/user_data_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IGeolocatorService _geolocatorService;
  final ICatalogService _catalogService;
  final IAuthentication _authService;
  final IUserDataService _userDataService;
  HomeBloc({
    IGeolocatorService? geolocatorService,
    IAuthentication? authService,
    IUserDataService? userDataService,
    ICatalogService? catalogService,
  }) : _geolocatorService = geolocatorService ?? GeolocatorService(),
       _authService = authService ?? FirebaseAuthService(),
       _userDataService = userDataService ?? FirestoreService(),
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

    on<LoadUserDataEvent>((event, emit) async {
      try {
        final results = await Future.wait([
          _authService.getCurrentUser(),
          _userDataService.getMotelIndex(),
        ]);
        final userResult = results[0] as ({fm.User? user, String? error});
        final motelIndexResult = results[1] as ({MotelIndex? motelIndex, String? error});
        AppDataManager().motelIndex = motelIndexResult.motelIndex;
        if (userResult.user == null) {
          return;
        }
        final userProfile = await _userDataService.getUserProfileByEmail(
          userResult.user!.email,
        );
        AppDataManager().currentUserProfile = userProfile.userProfile;
      } catch (e) {
        print('[HomeBloc] Error getting user data: $e');
      }
    });
  }
}
