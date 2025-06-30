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
    on<FilterMarkersEvent>(_onFilterMarkers);
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
    emit(state.copyWith(isLoading: true, error: null));
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('motels')
          .limit(100)
          .get();
      await _loadMarkers(snapshot, emit);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Lỗi khi tải dữ liệu Firestore: $e',
        ),
      );
    }
  }

  Future<void> _onFilterMarkers(
    FilterMarkersEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      Query query = FirebaseFirestore.instance.collection('motels').limit(100);

      // Lọc theo tỉnh và phường
      // if (event.province != null && event.province!.isNotEmpty) {
      //   query = query.where('address', contains: event.province);
      // }
      // if (event.ward != null && event.ward!.isNotEmpty) {
      //   query = query.where('ward', isEqualTo: event.ward);
      // }

      // Lọc theo giá thuê
      if (event.priceRange != null && event.priceRange!.isNotEmpty) {
        final priceLimits = _parsePriceRange(event.priceRange!);
        if (priceLimits != null) {
          query = query.where(
            'price',
            isGreaterThanOrEqualTo: priceLimits[0] * 1000000,
          );
          if (priceLimits[1] != double.infinity) {
            query = query.where(
              'price',
              isLessThanOrEqualTo: priceLimits[1] * 1000000,
            );
          }
        }
      }

      // Lọc theo tiện ích
      if (event.amenities != null && event.amenities!.isNotEmpty) {
        query = query.where('extensions', arrayContainsAny: event.amenities);
      }

      QuerySnapshot snapshot = await query.get();

      await _loadMarkers(snapshot, emit, clearIfEmpty: true);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Lỗi khi lọc dữ liệu Firestore: $e',
        ),
      );
    }
  }

  List<double>? _parsePriceRange(String range) {
    switch (range) {
      case '0-3':
        return [0, 3];
      case '3-5':
        return [3, 5];
      case '5-8':
        return [5, 8];
      case '>8':
        return [8, double.infinity];
      default:
        return null;
    }
  }

  Future<void> _loadMarkers(
    QuerySnapshot snapshot,
    Emitter<MapState> emit, {
    bool clearIfEmpty = false,
  }) async {
    final markers = <Marker>{};
    final List<LatLng> positions = [];
    final List<Future<void>> imageLoadingTasks = [];

    // Tạo marker mặc định trước
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint geoPoint = data['geo_point'] as GeoPoint;
      final position = LatLng(geoPoint.latitude, geoPoint.longitude);
      positions.add(position);

      // Tạo marker với defaultMarker
      final marker = Marker(
        markerId: MarkerId(doc.id),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(marker);

      // Tạo task tải ảnh và cập nhật marker
      final String imageUrl =
          data['imageUrl'] ??
          'https://firebasestorage.googleapis.com/v0/b/dvpkcinema.appspot.com/o/cinema%2Fbitexco.png?alt=media&token=4b4dcd4e-1043-403d-9f8a-6ae5df20da4e';
      final int? price = data['price'];
      if (imageUrl.isNotEmpty) {
        imageLoadingTasks.add(
          _createCustomMarker(imageUrl, price, 100)
              .then((markerIcon) {
                final updatedMarker = Marker(
                  markerId: MarkerId(doc.id),
                  position: position,
                  icon: markerIcon,
                );
                markers.removeWhere((m) => m.markerId == MarkerId(doc.id));
                markers.add(updatedMarker);
                emit(state.copyWith(markers: {...markers}, isLoading: false));
              })
              .catchError((e) {
                print('Lỗi tải ảnh cho marker ${doc.id}: $e');
              }),
        );
      }
    }

    // Tính vị trí trung tâm
    LatLng? centerPosition;
    LatLngBounds? bounds;
    if (positions.isNotEmpty) {
      double latSum = 0;
      double lngSum = 0;
      final minLat = positions
          .map((p) => p.latitude)
          .reduce((a, b) => a < b ? a : b);
      final maxLat = positions
          .map((p) => p.latitude)
          .reduce((a, b) => a > b ? a : b);
      final minLng = positions
          .map((p) => p.longitude)
          .reduce((a, b) => a < b ? a : b);
      final maxLng = positions
          .map((p) => p.longitude)
          .reduce((a, b) => a > b ? a : b);
      for (var pos in positions) {
        latSum += pos.latitude;
        lngSum += pos.longitude;
      }
      centerPosition = LatLng(
        latSum / positions.length,
        lngSum / positions.length,
      );
      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    } else if (clearIfEmpty) {
      // Nếu không có vị trí và clearIfEmpty = true, xóa tất cả marker
      markers.clear();
    }

    // Emit state với marker mặc định
    emit(
      state.copyWith(
        centerPosition: centerPosition,
        bounds: bounds,
        markers: {...state.markers, ...markers},
        isLoading: false,
      ),
    );

    // Chạy các task tải ảnh đồng thời
    await Future.wait(imageLoadingTasks);
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
          image = img.copyResize(image, width: width, height: width);
          final Uint8List imageData = Uint8List.fromList(img.encodePng(image));

          // Tạo canvas với ảnh và text
          final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          const double padding = 10; // Padding 10px mỗi bên
          final double textHeight = 50;
          final double totalHeight = width + textHeight;
          final double imageSize = width.toDouble(); // Ảnh 50x50
          final double canvasWidth =
              imageSize + 2 * padding; // Width canvas: 50 + 10 + 10
          final double canvasHeight =
              imageSize +
              textHeight +
              2 * padding; // Height canvas: 50 + 20 + 10 + 10

          // Vẽ màu nền cho canvas
          final backgroundPaint = Paint()..color = const Color(0xFFFFC752);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
              Radius.circular(8),
            ),
            backgroundPaint,
          );

          // Vẽ ảnh bo tròn (căn giữa ngang)
          final ui.Image markerImage = await _decodeImageFromList(imageData);
          canvas.save();
          canvas.clipRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                padding,
                padding,
                imageSize.toDouble(),
                imageSize.toDouble(),
              ),
              Radius.circular(8),
            ),
          );
          canvas.drawImageRect(
            markerImage,
            Rect.fromLTWH(
              0,
              0,
              markerImage.width.toDouble(),
              markerImage.height.toDouble(),
            ),
            Rect.fromLTWH(
              padding,
              padding,
              imageSize.toDouble(),
              imageSize.toDouble(),
            ), // Ảnh 40x40, đặt tại (10, 10)
            Paint(),
          );
          canvas.restore();

          // Vẽ text bên dưới
          final textPainter = TextPainter(
            text: TextSpan(
              text: _formatPrice(price),
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                backgroundColor: const Color(0xFFFFC752),
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(maxWidth: width.toDouble());
          final textWidth = textPainter.width;
          final textOffset = Offset(
            (canvasWidth - textWidth) / 2,
            2 * padding + width.toDouble(),
          ); // Căn giữa ngang
          textPainter.paint(canvas, textOffset);

          // Chuyển canvas thành BitmapDescriptor
          final canvasImage = await pictureRecorder.endRecording().toImage(
            canvasWidth.toInt(),
            canvasHeight.toInt(),
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
