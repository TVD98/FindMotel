// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _loadMarkerIcon() async {
    // // Tải ảnh asset và chuyển thành BitmapDescriptor
    // final BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
    //   ImageConfiguration(size: Size(32, 32), devicePixelRatio: 2.0),
    //   'assets/images/image_sana.jpg',
    // );

    // Cập nhật markers với ảnh asset
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('marker_1'),
          position: LatLng(21.028511, 105.804817), // Tọa độ Hà Nội
          //icon: markerIcon, // Sử dụng ảnh asset
          infoWindow: InfoWindow(title: 'Hà Nội', snippet: 'Thủ đô Việt Nam'),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        // Cập nhật vị trí camera khi trạng thái thay đổi
        mapController.animateCamera(CameraUpdate.newLatLng(state.center));
      },
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: state.center,
                zoom: 14.0,
              ),
              markers: state.markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  context.read<MapBloc>().add(MapEvent.moveToHCM);
                },
                child: const Icon(Icons.location_city),
              ),
            ),
          ],
        );
      },
    );
  }
}
