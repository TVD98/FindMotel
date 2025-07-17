import 'package:find_motel/common/models/motel.dart';
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
            for (var motelCard in state.cards) {
              _cardKeys[motelCard.id] = GlobalKey();
            }
            _scrollToCard(state.selectedMotel!.id);
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
                    height: 150, // Chiều cao cố định cho slider
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: state.cards.length,
                      itemBuilder: (context, index) {
                        final motelCard = state.cards[index];
                        return _buildMotelCard(
                          motelCard,
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

  Widget _buildMotelCard(MotelCard motelCard) {
    // Cập nhật tham số
    return Container(
      width: 250,
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
            ),
            child: Image.network(
              // Sử dụng Image.network cho URL ảnh
              motelCard.image, // Cập nhật: motelCard.image
              width: 100,
              height: 150,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    motelCard.name, // Cập nhật: motelCard.name
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    motelCard.address, // Cập nhật: motelCard.address
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    motelCard.price, // Cập nhật: motelCard.price (đã là String)
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    motelCard.commission, // Cập nhật: motelCard.commission
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
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
