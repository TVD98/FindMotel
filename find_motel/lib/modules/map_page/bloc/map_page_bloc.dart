// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:find_motel/services/geolocator/geolocator_service.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'map_page_event.dart';
import 'map_page_state.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:find_motel/theme/app_colors.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final IGeolocatorService _geolocatorService;
  final int maxSize = 100;
  final IMotelsService _firestoreService;
  final _markerCache = <String, Marker>{};

  MapBloc({
    IGeolocatorService? geolocatorService,
    IMotelsService? firestoreService,
  }) : _geolocatorService = geolocatorService ?? GeolocatorService(),
       _firestoreService = firestoreService ?? FirestoreService(),
       super(MapState()) {
    on<LoadCurrentLocationEvent>(_onLoadCurrentLocation);
    on<FirstLoadMotelsEvent>(_onFirstLoadMotels);
    on<FilterMotelsEvent>(_onFilterMotels);
    on<MarkerTapped>(_onMarkerTapped);
  }

  Future<void> _onLoadCurrentLocation(
    LoadCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _geolocatorService.getCurrentLocation();

      if (result.error != null) {
        emit(state.copyWith(isLoading: false, error: result.error));
        return;
      }

      final pos = result.position!;
      final LatLng currentPosition = LatLng(pos.latitude, pos.longitude);
      AppDataManager().currentLocation = currentPosition;

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
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onFirstLoadMotels(
    FirstLoadMotelsEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _firestoreService.getMotels(limit: maxSize);
      if (result.error != null) {
        emit(state.copyWith(isLoading: false, error: result.error));
        return;
      }

      await _loadMarkers(result.motels!, emit);
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Lỗi khi tải dữ liệu Firestore: $e',
        ),
      );
    }
  }

  Future<void> _onFilterMotels(
    FilterMotelsEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _firestoreService.getMotels(
        filter: event.filter,
        limit: maxSize,
      );
      if (result.error != null) {
        emit(state.copyWith(isLoading: false, error: result.error));
        return;
      }
      await _loadMarkers(result.motels!, emit);
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

  Future<void> _loadMarkers(List<Motel> motels, Emitter<MapState> emit) async {
    final markers = <Marker>{};
    final List<LatLng> positions = [];
    final List<Future<void>> imageLoadingTasks = [];

    // Tạo marker mặc định trước
    for (var motel in motels) {
      final position = motel.geoPoint;
      positions.add(position);

      if (_markerCache.containsKey(motel.id)) {
        markers.add(_markerCache[motel.id]!);
        continue;
      }

      final marker = Marker(
        markerId: MarkerId(motel.id),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
        onTap: () {
          add(MarkerTapped(motel));
        },
      );
      markers.add(marker);
      _markerCache[motel.id] = marker;

      // Tạo task tải ảnh và cập nhật marker
      final String imageUrl = motel.marker;
      final int price = motel.price.toInt();

      if (imageUrl.isNotEmpty) {
        imageLoadingTasks.add(
          _createCustomMarker(imageUrl, price, 100)
              .then((markerIcon) {
                final updatedMarker = Marker(
                  markerId: MarkerId(motel.id),
                  position: position,
                  icon: markerIcon,
                  onTap: () {
                    add(MarkerTapped(motel));
                  },
                );
                markers.removeWhere((m) => m.markerId == MarkerId(motel.id));
                markers.add(updatedMarker);
                _markerCache[motel.id] = updatedMarker;
                emit(state.copyWith(markers: {...markers}, isLoading: false));
              })
              .catchError((e) {
                print('Lỗi tải ảnh cho marker ${motel.id}: $e');
              }),
        );
      }
    }

    // Tính vị trí trung tâm và bounds bằng service
    LatLng? centerPosition;
    LatLngBounds? bounds;
    final centerBounds = _geolocatorService.calculateCenterAndBounds(positions);
    centerPosition = centerBounds.center;
    bounds = centerBounds.bounds;

    emit(
      state.copyWith(
        centerPosition: centerPosition,
        bounds: bounds,
        markers: {...markers},
        cards: motels.map((motel) {
          // Định dạng giá (nếu cần)
          String formattedPrice = motel.price.toVND();

          // Chọn ảnh chính cho MotelCard, ưu tiên thumbnail, nếu không có thì ảnh đầu tiên trong images
          String imageUrl = '';
          if (motel.thumbnail.isNotEmpty) {
            imageUrl = motel.thumbnail;
          } else if (motel.images.isNotEmpty) {
            imageUrl = motel.images.first;
          }
          // Bạn có thể đặt một ảnh placeholder nếu cả hai đều trống
          if (imageUrl.isEmpty) {
            imageUrl =
                'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=No+Image';
          }

          return MotelCard(
            motel.id,
            motel.name,
            motel.address,
            imageUrl, // Sử dụng thumbnail hoặc ảnh đầu tiên
            motel.commission,
            formattedPrice, // Sử dụng giá đã định dạng
          );
        }).toList(),
        isLoading: false,
      ),
    );

    // Chạy các task tải ảnh đồng thời
    await Future.wait(imageLoadingTasks);
  }

  String _formatPrice(int? price) {
    if (price == null) return 'N/A';
    final double priceInMillions = price / 1000000;
    return '${priceInMillions.toStringAsFixed(1)}tr';
  }

  Future<BitmapDescriptor> _createCustomMarker(
    String imageUrl,
    int? price,
    int width,
  ) async {
    if (imageUrl.isEmpty) return BitmapDescriptor.defaultMarker;

    try {
      final Uint8List? imageBytes = await _downloadAndResizeImage(
        imageUrl,
        width,
      );
      if (imageBytes == null) return BitmapDescriptor.defaultMarker;

      return await _buildMarkerDescriptor(imageBytes, price, width);
    } catch (e) {
      // Ignore errors and fall back to the default marker
      print('Create custom marker error: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// Downloads an image from [url] and resizes it to [width]×[width].
  Future<Uint8List?> _downloadAndResizeImage(String url, int width) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return null;

    final img.Image? original = img.decodeImage(response.bodyBytes);
    if (original == null) return null;

    final img.Image resized = img.copyResize(
      original,
      width: width,
      height: width,
    );
    return Uint8List.fromList(img.encodePng(resized));
  }

  /// Builds a [BitmapDescriptor] with the motel thumbnail and price.
  Future<BitmapDescriptor> _buildMarkerDescriptor(
    Uint8List imageData,
    int? price,
    int width,
  ) async {
    const double padding = 10;
    const double textHeight = 50;
    final double imageSize = width.toDouble();
    final double canvasWidth = imageSize + 2 * padding;
    final double canvasHeight = imageSize + textHeight + 2 * padding;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Draw background
    final ui.Paint bgPaint = ui.Paint()..color = AppColors.secondaryContainer;
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
        const ui.Radius.circular(8),
      ),
      bgPaint,
    );

    // Draw motel image
    final ui.Image motelImage = await _decodeImageFromList(imageData);
    canvas.save();
    canvas.clipRRect(
      ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(padding, padding, imageSize, imageSize),
        const ui.Radius.circular(8),
      ),
    );
    canvas.drawImageRect(
      motelImage,
      ui.Rect.fromLTWH(
        0,
        0,
        motelImage.width.toDouble(),
        motelImage.height.toDouble(),
      ),
      ui.Rect.fromLTWH(padding, padding, imageSize, imageSize),
      ui.Paint(),
    );
    canvas.restore();

    // Draw price text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _formatPrice(price),
        style: const TextStyle(
          color: AppColors.elementPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w600,
          backgroundColor: AppColors.secondaryContainer,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width.toDouble());

    final double textX = (canvasWidth - textPainter.width) / 2;
    final double textY = padding * 2 + imageSize;
    textPainter.paint(canvas, Offset(textX, textY));

    // Convert canvas to image
    final ui.Image canvasImage = await recorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final byteData = await canvasImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<ui.Image> _decodeImageFromList(Uint8List list) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }
}
