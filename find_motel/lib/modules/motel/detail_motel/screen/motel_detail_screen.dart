import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/deal_manager/screens/deal_detail_screen.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/modules/motel/edit_motel/edit_motel_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_bloc.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_event.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_state.dart';

class AppConstants {
  static const padding = 16.0;
  static const borderRadius = 10.0;
  static const spacing = 12.0;
  static const chipBorderRadius = 4.0;
  static const bottomNavBarHeight = 56.0;
}

String formatVND(dynamic price) {
  final formatter = NumberFormat("#,##0", "vi_VN");
  return formatter.format(price);
}

class MotelDetailScreen extends StatefulWidget {
  final Motel detail;
  final bool isBottomSheet;

  const MotelDetailScreen({
    super.key,
    required this.detail,
    this.isBottomSheet = true,
  });

  @override
  _MotelDetailScreenState createState() => _MotelDetailScreenState();
}

class _MotelDetailScreenState extends State<MotelDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MotelDetailBloc(
        initialMotelDetail: widget.detail,
        motelsService: FirestoreService(),
      ),
      child: Builder(
        builder: (blocContext) {
          return BlocConsumer<MotelDetailBloc, MotelDetailState>(
            listener: (context, state) {
              if (state is MotelDetailLoaded && state.needsReloadHome) {
                blocContext.read<HomePageBloc>().add(
                  LoadMotels(isRefresh: true),
                );
                Navigator.pop(blocContext, true);
              } else if (state is MotelDetailError) {
                ScaffoldMessenger.of(blocContext).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.message}')),
                );
              }
            },
            builder: (blocContext, state) {
              if (state is MotelDetailLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is MotelDetailError) {
                return Scaffold(
                  appBar: CommonAppBar(
                    title: 'Lỗi',
                    leadingAsset: 'assets/images/ic_back.svg',
                    onLeadingPressed: () => Navigator.pop(blocContext, false),
                  ),
                  body: Center(child: Text(state.message)),
                );
              } else if (state is MotelDetailLoaded) {
                final Motel currentMotelDetail = state.motelDetail;
                final String currentMainImage = state.currentMainImage;
                final bool isCanEdit = state.isCanEdit;

                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentMotelDetail.name,
                      style: AppTextStyle.heading4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacing),
                    _buildRoomInfo(
                      currentMotelDetail.roomCode,
                      currentMotelDetail.type,
                    ),
                    const SizedBox(height: 16),
                    _buildMainImage(currentMainImage),
                    const SizedBox(height: AppConstants.spacing),
                    _buildImageGallery(
                      currentMotelDetail.images,
                      currentMainImage,
                      (newImage) {
                        blocContext.read<MotelDetailBloc>().add(
                          MotelDetailUpdateMainImage(newImage),
                        );
                      },
                    ),

                    //   ],
                    // ),
                    const SizedBox(height: AppConstants.spacing),
                    _buildTags(
                      currentMotelDetail.commission,
                      currentMotelDetail.price,
                    ),
                    _divider(),
                    _buildAddress(
                      blocContext,
                      currentMotelDetail.address,
                      currentMotelDetail.geoPoint,
                    ),
                    _divider(),
                    _buildExtensions(currentMotelDetail.extensions),
                    _divider(),
                    _buildFees(currentMotelDetail.fees),
                    _divider(),
                    _buildNotes(currentMotelDetail.note),
                  ],
                );

                return Scaffold(
                  appBar: CommonAppBar(
                    title: "Chi Tiết Phòng Trọ",
                    leadingAsset: 'assets/images/ic_back.svg',
                    leadingIconColor: Colors.white,
                    onLeadingPressed: () =>
                        Navigator.pop(blocContext, state.needsReloadHome),
                    actions: widget.isBottomSheet
                        ? null
                        : [
                            IconButton(
                              onPressed: () {
                                final Deal deal = Deal(
                                  id: '',
                                  name: '',
                                  phone: '',
                                  price: currentMotelDetail.price,
                                  schedule: DateTime.now(),
                                  saleId:
                                      AppDataManager()
                                          .currentUserProfile
                                          ?.email ??
                                      '',
                                  motelId: currentMotelDetail.id,
                                  motelName: currentMotelDetail.name,
                                );
                                Navigator.push(
                                  blocContext,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DealDetailScreen(deal: deal),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.calendar_month,
                                color: AppColors.headerLineOnPrimary,
                              ),
                            ),
                            if (isCanEdit)
                              IconButton(
                                onPressed: () async {
                                  final bool? result = await Navigator.push(
                                    blocContext,
                                    MaterialPageRoute(
                                      builder: (_) => EditMotelScreen(
                                        motel: currentMotelDetail,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    blocContext.read<MotelDetailBloc>().add(
                                      MotelDetailMotelUpdated(),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                  ),
                  body: SafeArea(
                    bottom: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                      child: content,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  _divider() =>
      const Divider(height: 25.0, thickness: 1.0, color: AppColors.strokeLight);

  // Widget hiển thị ảnh chính
  Widget _buildMainImage(String currentMainImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: _getImageWidget(currentMainImage, 246, 144),
    );
  }

  Widget _getImageWidget(String url, double width, double height) {
    if (url.isEmpty) {
      return _buildImageDefault();
    } else if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) {
          return SizedBox(
            height: height,
            width: width,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      );
    } else {
      return Image.file(
        File(url),
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
            height: height,
            width: width,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      );
    }
  }

  Widget _buildImageDefault() {
    return Image.asset(
      'assets/images/image_default.png',
      width: 246,
      height: 144,
    );
  }

  // Widget hiển thị danh sách ảnh thu nhỏ

  Widget _buildImageGallery(
    List<String> images,
    String currentMainImage,
    ValueChanged<String> onImageSelected,
  ) {
    return images.isEmpty
        ? const Text('Không có hình ảnh', style: TextStyle(fontSize: 14))
        : SizedBox(
            height: 28,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (_, index) {
                final imageUrl = images[index];
                return GestureDetector(
                  onTap: () => onImageSelected(imageUrl), // Gọi callback
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: currentMainImage == imageUrl
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: _getImageWidget(imageUrl, 42, 28),
                    ),
                  ),
                );
              },
            ),
          );
  }

  // Widget hiển thị hoa hồng và giá thuê
  Widget _buildTags(String commission, double price) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _tagChip(
            Row(
              children: [
                Text(
                  "HH",
                  style: AppTextStyle.smallLabel.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing / 2),
                Text(
                  commission,
                  style: AppTextStyle.smallLabel.copyWith(
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            AppColors.primaryContainer,
            textColor: AppColors.onPrimaryContainer,
          ),
        ),
        _tagChip(
          _buildSubAndBodyText("Giá thuê:", "${formatVND(price)}đ"),
          AppColors.onSurface2,
          textColor: AppColors.elementSecondary,
        ),
      ],
    );
  }

  Widget _buildRoomInfo(String roomCode, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSubAndBodyText("Mã phòng:", roomCode),
        _buildSubAndBodyText("Kiểu phòng:", type),
      ],
    );
  }

  Widget _buildSubAndBodyText(String subtitle, String body) {
    return Row(
      children: [
        Text(
          subtitle,
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(width: AppConstants.spacing / 2),
        Text(
          body,
          style: AppTextStyle.body.copyWith(color: AppColors.elementSecondary),
        ),
      ],
    );
  }

  Widget _buildAddress(BuildContext context, String address, dynamic geoPoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
            const SizedBox(width: AppConstants.spacing),
            Text(
              address,
              style: AppTextStyle.smallBody.copyWith(
                color: AppColors.elementSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.directions, size: 18, color: AppColors.primary),
            const SizedBox(width: AppConstants.spacing),
            GestureDetector(
              onTap: () async {
                String appUrl;
                String webUrl;
                final lat = geoPoint.latitude;
                final lng = geoPoint.longitude;
                appUrl = 'comgooglemaps://?q=$lat,$lng';
                webUrl =
                    'http://maps.google.com/?q=$lat,$lng'; // Đã sửa URL web map

                if (Platform.isIOS) {
                  // Kiểm tra nền tảng để sử dụng scheme phù hợp
                  appUrl = 'comgooglemaps://?q=$lat,$lng';
                  webUrl =
                      'http://maps.apple.com/?q=$lat,$lng'; // Dùng Apple Maps trên iOS
                } else {
                  appUrl =
                      'geo:$lat,$lng?q=$lat,$lng'; // Dùng Geo URI trên Android
                  webUrl = 'http://maps.google.com/?q=$lat,$lng';
                }

                if (await canLaunchUrl(Uri.parse(appUrl))) {
                  await launchUrl(Uri.parse(appUrl));
                } else {
                  if (await canLaunchUrl(Uri.parse(webUrl))) {
                    await launchUrl(Uri.parse(webUrl));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể mở bản đồ')),
                    );
                  }
                }
              },
              child: Text(
                'Chỉ đường',
                style: AppTextStyle.smallBody.copyWith(
                  color: AppColors.elementHighlight,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.elementHighlight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExtensions(List<String> extensions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tiện ích:",
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppConstants.spacing),
        extensions.isEmpty
            ? const Text('Không có tiện ích', style: TextStyle(fontSize: 14))
            : Wrap(
                spacing: AppConstants.spacing,
                runSpacing: AppConstants.spacing,
                children: AppDataManager().allAmenities
                    .where((extension) => extensions.contains(extension))
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.onSurface1,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: AppColors.strokeLight,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          e,
                          style: AppTextStyle.smallBody.copyWith(
                            color: AppColors.elementSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildFees(List<Map<String, dynamic>> fees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chi phí khác:",
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppConstants.spacing - 4.0),
        fees.isEmpty
            ? Text(
                "Không có chi phí khác",
                style: AppTextStyle.body.copyWith(
                  color: AppColors.elementSecondary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fees.map((fee) {
                  return _costRow(
                    fee['name'] ?? 'Không xác định',
                    '${formatVND(fee['price'] ?? 0)}đ/${fee['unit'] ?? ''}',
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildNotes(List<String> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ghi chú:",
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppConstants.spacing - 4.0),
        notes.isEmpty
            ? Text(
                "Không có ghi chú",
                style: AppTextStyle.body.copyWith(
                  color: AppColors.elementSecondary,
                ),
              )
            : Column(
                children: notes
                    .map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(
                          top: AppConstants.spacing / 6,
                          bottom: AppConstants.spacing / 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              "• ",
                              style: AppTextStyle.body.copyWith(
                                color: AppColors.elementSecondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                note,
                                style: AppTextStyle.body.copyWith(
                                  color: AppColors.elementSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  // Widget tạo chip cho tiện ích và hoa hồng (giữ nguyên)
  Widget _tagChip(
    Widget label,
    Color bgColor, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.chipBorderRadius),
      ),
      child: label,
    );
  }

  // Widget tạo hàng cho chi phí (giữ nguyên)
  Widget _costRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.smallLabel.copyWith(
              color: AppColors.elementPrimary,
            ),
          ),

          Text(
            value,
            style: AppTextStyle.body.copyWith(
              color: AppColors.elementSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class GeoPoint {
  /* ... */
}

class MotelResult {
  /* ... */
}

abstract class IMotelDataService {
  /* ... */
}
