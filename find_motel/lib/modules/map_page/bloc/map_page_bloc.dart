// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_page_event.dart';
import 'map_page_state.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapState()) {
    on<LoadCurrentLocationEvent>(_onLoadCurrentLocation);
    on<LoadFirestoreMarkersEvent>(_onLoadFirestoreMarkers);
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Dịch vụ vị trí bị tắt');
        emit(state.copyWith(isLoading: false));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Quyền vị trí bị từ chối');
          emit(state.copyWith(isLoading: false));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Quyền vị trí bị từ chối vĩnh viễn');
        emit(state.copyWith(isLoading: false));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng currentPosition = LatLng(
        position.latitude,
        position.longitude,
      );

      final marker = Marker(
        markerId: MarkerId('current_location'),
        position: currentPosition,
        infoWindow: InfoWindow(title: 'Vị trí hiện tại'),
      );

      emit(
        state.copyWith(
          currentPosition: currentPosition,
          centerPosition: currentPosition,
          markers: {...state.markers, marker},
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Lỗi khi lấy vị trí: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLoadFirestoreMarkers(
    LoadFirestoreMarkersEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('motels')
          .get();
      final markers = <Marker>{};
      final List<LatLng> positions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint geoPoint = data['geo_point'] as GeoPoint;
        final position = LatLng(geoPoint.latitude, geoPoint.longitude);
        positions.add(position);
        final BitmapDescriptor customMarker = await _createCustomMarker(
          'https://firebasestorage.googleapis.com/v0/b/dvpkcinema.appspot.com/o/cinema%2Fbitexco.png?alt=media&token=4b4dcd4e-1043-403d-9f8a-6ae5df20da4e',
          data['price'] as int,
          100,
        );
        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: position,
            icon: customMarker,
            infoWindow: InfoWindow(
              title: data['name'] ?? 'Địa điểm',
              snippet: data['description'] ?? '',
            ),
          ),
        );
      }

      // Tính vị trí trung tâm
      LatLng? centerPosition;
      if (positions.isNotEmpty) {
        double latSum = 0;
        double lngSum = 0;
        for (var pos in positions) {
          latSum += pos.latitude;
          lngSum += pos.longitude;
        }
        centerPosition = LatLng(
          latSum / positions.length,
          lngSum / positions.length,
        );
      }

      emit(
        state.copyWith(
          centerPosition: centerPosition,
          markers: {...state.markers, ...markers},
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Lỗi khi tải dữ liệu Firestore: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  String _formatPrice(int? price) {
    if (price == null) return 'N/A';
    final double priceInMillions = price / 1000000;
    return '${priceInMillions.toStringAsFixed(1)} tr';
  }

  Future<BitmapDescriptor> _createCustomMarker(
    String imageUrl,
    int? price,
    int width,
  ) async {
    if (imageUrl.isEmpty) {
      // Sử dụng marker mặc định của Google Maps nếu không có URL
      return BitmapDescriptor.defaultMarker;
    }

    // Tải và resize ảnh từ URL
    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        img.Image? image = img.decodeImage(response.bodyBytes);
        if (image != null) {
          image = img.copyResize(image, width: width);
          final Uint8List imageData = Uint8List.fromList(img.encodePng(image));

          // Tạo canvas với ảnh và text
          final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          final double textHeight = 50;
          final double totalHeight = width + textHeight;

          // Vẽ ảnh
          final ui.Image markerImage = await _decodeImageFromList(imageData);
          canvas.drawImageRect(
            markerImage,
            Rect.fromLTWH(
              0,
              0,
              markerImage.width.toDouble(),
              markerImage.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, width.toDouble(), width.toDouble()),
            Paint(),
          );

          // Vẽ text bên dưới
          final textPainter = TextPainter(
            text: TextSpan(
              text: _formatPrice(price),
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white.withOpacity(0.8),
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: width.toDouble());
          final textWidth = textPainter.width;
          final textOffset = Offset(
            (width - textWidth) / 2,
            width.toDouble(),
          ); // Căn giữa ngang
          textPainter.paint(canvas, textOffset);

          // Chuyển canvas thành BitmapDescriptor
          final canvasImage = await pictureRecorder.endRecording().toImage(
            width,
            totalHeight.toInt(),
          );
          final byteData = await canvasImage.toByteData(
            format: ui.ImageByteFormat.png,
          );
          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        }
      }
    } catch (e) {
      print('Lỗi tải ảnh từ URL: $e');
    }

    // Trả về marker mặc định nếu tải thất bại
    return BitmapDescriptor.defaultMarker;
  }

  Future<ui.Image> _decodeImageFromList(Uint8List list) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }
}
