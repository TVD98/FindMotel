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
        mapController.animateCamera(
          CameraUpdate.newLatLng(state.centerPosition ?? _defaultCenter),
        );
      },
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: state.centerPosition ?? _defaultCenter,
                zoom: 12.0,
              ),
              markers: state.markers,
              myLocationEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
              myLocationButtonEnabled: true,
            ),
            if (state.isLoading) Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
