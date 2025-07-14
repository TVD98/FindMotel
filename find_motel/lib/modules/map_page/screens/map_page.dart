// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_state.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/screens/filter_page.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _defaultCenter = LatLng(
    21.0285,
    105.8542,
  ); // Tọa độ mặc định (Hà Nội)
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        // Cập nhật vị trí camera khi trạng thái thay đổi
        if (state.bounds != null) {
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(state.bounds!, 50),
          );
        } else if (state.centerPosition != null) {
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: state.centerPosition!, zoom: 12.0),
            ),
          );
        }

        if (state.selectedMotel != null) {
          showRoomDetailBottomSheet(context, state.selectedMotel!);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: state.centerPosition ?? _defaultCenter,
                zoom: 13.0,
              ),
              markers: state.markers,
              myLocationEnabled: true,
              buildingsEnabled: false,
            ),
            Positioned(
              top: 50,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context
                            .read<MapBloc>(), // dùng lại MapBloc hiện có
                        child: const FilterPage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Bo tròn nút
                    color: Colors.white, // Nền trắng
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/ic_filter.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ),
            if (state.isLoading) Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }

  void showRoomDetailBottomSheet(BuildContext context, Motel motel) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet chiếm gần hết màn hình
      backgroundColor: Colors.transparent, // Nền trong suốt để bo góc
      builder: (context) => RoomDetailScreen(detail: motel),
    );

    // Nếu có kết quả trả về (true = đã save thành công), reload data cho map
    if (result == true && context.mounted) {
      context.read<MapBloc>().add(FirstLoadMotelsEvent());
      // Cũng reload HomePageBloc nếu có thể
      try {
        context.read<HomePageBloc>().add(LoadMotels());
      } catch (e) {
        print('HomePageBloc not found in MapPage: $e');
      }
    }
  }
}
