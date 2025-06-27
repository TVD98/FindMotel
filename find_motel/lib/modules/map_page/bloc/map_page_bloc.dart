// ignore_for_file: deprecated_member_use, unused_import

import 'dart:typed_data' show ByteData;
import 'package:image/image.dart' as img;
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Uint8List;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc()
    : super(
        MapState(
          const LatLng(21.0285, 105.8542), // Hà Nội
          {
            const Marker(
              markerId: MarkerId('hanoi'),
              position: LatLng(21.0285, 105.8542),
              infoWindow: InfoWindow(title: 'Hà Nội', snippet: 'Hoàn Kiếm'),
            ),
          },
        ),
      ) {
    on<MapEvent>((event, emit) async {
      if (event == MapEvent.moveToHCM) {
        final String imageUrl =
            'https://firebasestorage.googleapis.com/v0/b/dvpkcinema.appspot.com/o/cinema%2Fbitexco.png?alt=media&token=4b4dcd4e-1043-403d-9f8a-6ae5df20da4e'; // Thay bằng URL ảnh của bạn
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) {
          return;
        }
        final Uint8List imageBytes = response.bodyBytes;

        // Decode và resize ảnh
        final img.Image? image = img.decodeImage(imageBytes);
        if (image == null) {
          return;
        }
        final img.Image resizedImage = img.copyResize(
          image,
          width: 100,
          height: 100,
        );

        // Chuyển ảnh thành Uint8List
        final Uint8List resizedBytes = Uint8List.fromList(
          img.encodePng(resizedImage),
        );

        // Tạo BitmapDescriptor từ ảnh đã resize
        final BitmapDescriptor markerIcon = BitmapDescriptor.fromBytes(
          resizedBytes,
        );

        emit(
          MapState(
            const LatLng(10.7769, 106.7009), // TP.HCM
            {
              Marker(
                markerId: MarkerId('hcm'),
                position: LatLng(10.7769, 106.7009),
                icon: markerIcon,
                infoWindow: const InfoWindow(
                  title: 'TP.HCM',
                  snippet: 'Quận 1',
                ),
              ),
            },
          ),
        );
      }
    });
  }
}
