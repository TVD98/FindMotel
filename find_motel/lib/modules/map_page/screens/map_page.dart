import 'dart:async';

import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/motel/detail_motel/screen/motel_detail_screen.dart';
import 'package:find_motel/modules/filter/quickly_filter.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_state.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/services/reload_service.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  late GoogleMapController mapController;
  late final StreamSubscription<bool> _reloadSubscription;
  final ScrollController _scrollController = ScrollController();
  final LatLng _defaultCenter = const LatLng(
    10.762622,
    106.660172,
  ); // Vĩ độ TP.HCM

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _reloadSubscription = ReloadService.reloadStream.listen((needsReload) {
      if (needsReload) {
        _fetchMotels();
      }
    });
  }

  Future<void> _fetchMotels() async {
    context.read<MapBloc>().add(FilterMotelsEvent(filter: AppDataManager().filterMotels, isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _reloadSubscription.cancel();
    super.dispose();
  }

  void _scrollToItem(int index) {
    final double cardTotalWidth = (MediaQuery.of(context).size.width - 40) + 10;
    final double offset = index * cardTotalWidth;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MotelsFilterCubit, MotelsFilter>(
      listener: (context, filter) {
        context.read<MapBloc>().add(FilterMotelsEvent(filter: filter, isRefresh: false));
      },
      child: BlocConsumer<MapBloc, MapState>(
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

          if (state.selectedMotel != null && state.cards.isNotEmpty) {
            final motelIndex = state.cards.indexWhere(
              (motel) => motel.id == state.selectedMotel!.id,
            );
            _scrollToItem(motelIndex);
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
              if (state.cards.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 254, // Chiều cao cố định cho slider
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: state.cards.length,
                      itemBuilder: (context, index) {
                        final motelCard = state.cards[index];
                        return GestureDetector(
                          child: _buildMotelCard(motelCard),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MotelDetailScreen(
                                  detail: motelCard,
                                ),
                              ),
                            );
                          },
                        ); // Gọi hàm xây dựng từng thẻ
                      },
                    ),
                  ),
                ),
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: const QuicklyFilter(),
              ),
              if (state.isLoading) Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMotelCard(Motel motelCard) {
    // Cập nhật tham số
    return Container(
      width: MediaQuery.of(context).size.width - 2 * 20,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      motelCard.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/ic_arrow_right.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_marker.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      motelCard.address,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Image.network(
                motelCard.images.first,
                width: double.infinity,
                height: 108,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ), // Khoảng đệm bên trong Container
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer, // Màu nền của Container
                    borderRadius: BorderRadius.circular(
                      2,
                    ), // Bo tròn 10px cho tất cả các góc
                  ),
                  child: Text(
                    'HH ${motelCard.commission}%',
                    style: TextStyle(
                      color: AppColors.onPrimaryContainer, // Màu chữ
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ), // Khoảng đệm bên trong Container
                  decoration: BoxDecoration(
                    color: AppColors.onSurface2, // Màu nền của Container
                    borderRadius: BorderRadius.circular(
                      2,
                    ), // Bo tròn 10px cho tất cả các góc
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Giá thuê: ',
                        style: TextStyle(
                          color: AppColors.primary, // Màu chữ
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        motelCard.price.toVND(),
                        style: TextStyle(
                          color: AppColors.elementSecondary, // Màu chữ
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
