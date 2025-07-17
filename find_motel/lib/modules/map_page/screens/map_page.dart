import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_state.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:find_motel/modules/map_page/screens/filter_page.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
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
  static const LatLng _defaultCenter = LatLng(
    21.0285,
    105.8542,
  ); // Tọa độ mặc định (Hà Nội)
  late GoogleMapController mapController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _cardKeys = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  bool get wantKeepAlive => true;

  void _scrollToCard(String? motelId) {
    if (motelId == null || !_cardKeys.containsKey(motelId)) return;

    final RenderBox renderBox =
        _cardKeys[motelId]!.currentContext!.findRenderObject() as RenderBox;
    final double offset =
        renderBox.localToGlobal(Offset.zero).dx + _scrollController.offset;

    // Tính toán vị trí cuộn để đưa thẻ vào giữa (hoặc gần giữa) màn hình
    // Chiều rộng của thẻ cố định là 250 + 2*5 (margin) = 260
    final double cardWidth =
        260.0; // Đây là chiều rộng của mỗi card (width + horizontal margin)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetOffset = offset - (screenWidth / 2) + (cardWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ), // Giới hạn offset trong phạm vi cuộn
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MotelsFilterCubit, MotelsFilter>(
      listener: (context, filter) {
        context.read<MapBloc>().add(FilterMotelsEvent(filter: filter));
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

          if (state.selectedMotel != null) {
            // for (var motelCard in state.cards) {
            //   _cardKeys[motelCard.id] = GlobalKey();
            // }
            // _scrollToCard(state.selectedMotel!.id);
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
                          value: context.read<MotelsFilterCubit>(),
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
                                builder: (context) => RoomDetailScreen(
                                  detail: motelCard,
                                  isBottomSheet: false,
                                ),
                              ),
                            );
                          },
                        ); // Gọi hàm xây dựng từng thẻ
                      },
                    ),
                  ),
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
                      motelCard.name,
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

  void showRoomDetailBottomSheet(BuildContext context, Motel motel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet chiếm gần hết màn hình
      backgroundColor: Colors.transparent, // Nền trong suốt để bo góc
      builder: (context) => RoomDetailScreen(detail: motel),
    );
  }
}
