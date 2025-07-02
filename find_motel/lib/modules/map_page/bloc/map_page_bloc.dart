// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/detail/detail_motel_model.dart';
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
    on<MarkerTapped>(_onMarkerTapped);
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

      // Lọc theo mã phòng
      if (event.roomCode != null) {
        query = query.where('room_code', isEqualTo: event.roomCode!);
      }

      // Lọc theo tỉnh và phường
      List<String> address = [];
      if (event.province != null && event.ward != null) {
        address = [event.province!, event.ward!];
        query = query.where('keywords', arrayContainsAny: address);
      }

      // Lọc theo giá thuê
      if (event.priceRange != null) {
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

  void _onMarkerTapped(MarkerTapped event, Emitter<MapState> emit) async {
    emit(state.copyWith(selectedMotel: event.motel));

    await Future.delayed(Duration(milliseconds: 100), () {
      emit(state.copyWith(selectedMotel: null));
    });
  }

  List<double>? _parsePriceRange(RangeValues range) {
    final int startValue = range.start.round();
    final int endValue = range.end.round();
    if (endValue > 10) {
      return [startValue.toDouble(), double.infinity];
    } else {
      return [startValue.toDouble(), endValue.toDouble()];
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

      // last filter
      if (!_isValidMotel(data)) {
        break;
      }

      final GeoPoint geoPoint = data['geo_point'] as GeoPoint;
      final position = LatLng(geoPoint.latitude, geoPoint.longitude);
      positions.add(position);

      final RoomDetail motelDetail = RoomDetail(
        address: data['address'] as String,
        commission: data['commission'] as String,
        extensions: (data['extensions'] as List<dynamic>).cast<String>(),
        fees: (data['fees'] as List<dynamic>).cast<Map<String, dynamic>>(),
        geoPoint: position,
        name: data['name'] as String,
        note: (data['note'] as List<dynamic>).cast<String>(),
        price: data['price'] as int,
        id: data['room_code'] as String,
        typeRoom: data['type'] as String,
        images: (data['images'] as List<dynamic>).cast<String>(),
        mainImage: data['thumbnail'] as String,
      );

      // Tạo marker với defaultMarker
      final marker = Marker(
        markerId: MarkerId(doc.id),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
          add(MarkerTapped(motelDetail));
        },
      );
      markers.add(marker);

      // Tạo task tải ảnh và cập nhật marker
      final String imageUrl =
          data['marker'] ??
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
                  onTap: () {
                    add(MarkerTapped(motelDetail));
                  },
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
        markers: {...markers},
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

  bool _isValidMotel(Map<String, dynamic> data) {
    if (AppDataManager().filterMotels.amenities?.isEmpty ?? true) {
      return true;
    } else {
      List<String> extensions = (data['extensions'] as List<dynamic>)
          .cast<String>();
      for (String amenitie in AppDataManager().filterMotels.amenities!) {
        if (extensions.contains(amenitie)) {
          return true;
        }
      }
      return false;
    }
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
