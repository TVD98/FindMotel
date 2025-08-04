import 'dart:io';
import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/widgets/motel_images_view.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/deal_manager/screens/deal_detail_screen.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_event.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_bloc.dart';
import 'package:find_motel/modules/motel/edit_motel/screen/edit_motel_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_bloc.dart';
import 'package:find_motel/modules/motel/detail_motel/bloc/motel_detail_state.dart';
import 'package:find_motel/utilities/phone_service.dart';

class AppConstants {
  static const padding = 16.0;
  static const borderRadius = 10.0;
  static const spacing = 12.0;
  static const chipBorderRadius = 4.0;
  static const bottomNavBarHeight = 56.0;
}

class MotelDetailScreen extends StatefulWidget {
  final Motel detail;

  const MotelDetailScreen({super.key, required this.detail});

  @override
  State<MotelDetailScreen> createState() => _MotelDetailScreenState();
}

class _MotelDetailScreenState extends State<MotelDetailScreen> {
  Deal get deal => Deal(
    id: '',
    name: '',
    phone: '',
    price: widget.detail.price,
    schedule: DateTime.now(),
    saleId: AppDataManager().currentUserProfile?.email ?? '',
    motelId: widget.detail.id,
    motelName: widget.detail.displayName,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MotelDetailBloc(initialMotelDetail: widget.detail),
      child: BlocBuilder<MotelDetailBloc, MotelDetailState>(
        builder: (blocContext, state) {
          if (state is MotelDetailLoaded) {
            final Motel currentMotelDetail = state.motelDetail;
            final bool isCanEdit = state.isCanEdit;

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentMotelDetail.displayName,
                  style: AppTextStyle.heading4.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing),
                _buildRoomInfo(
                  currentMotelDetail.type,
                  currentMotelDetail.texture,
                ),
                const SizedBox(height: 16),
                MotelImagesView(
                  imageUrls: currentMotelDetail.images,
                  isCanEdit: false,
                ),
                const SizedBox(height: AppConstants.spacing),
                _buildTags(
                  currentMotelDetail.commission,
                  currentMotelDetail.price,
                ),
                _divider(),
                _buildAddress(
                  currentMotelDetail.address,
                  currentMotelDetail.geoPoint,
                ),
                _divider(),
                _buildExtensions(currentMotelDetail.extensions),
                _divider(),
                _buildCar(currentMotelDetail.car),
                _divider(),
                _buildFees(currentMotelDetail.fees),
                _divider(),
                _buildNotes(currentMotelDetail.note),
              ],
            );

            return Scaffold(
              appBar: CommonAppBar(
                title: "Chi Tiết Phòng Trọ",
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        blocContext,
                        MaterialPageRoute(
                          builder: (context) => DealDetailScreen(deal: deal),
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
                        final motel = await Navigator.push(
                          blocContext,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => EditMotelBloc(),
                              child: EditMotelScreen(motel: state.motelDetail),
                            ),
                          ),
                        );
                        if (motel != null && blocContext.mounted) {
                          blocContext.read<MotelDetailBloc>().add(
                            MotelDetailMotelUpdated(motel: motel),
                          );
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
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
              floatingActionButton: isCanEdit
                  ? FloatingActionButton(
                      onPressed: () => _showHotlineBottomSheet(
                        context,
                        currentMotelDetail.phoneNumbers,
                      ),
                      tooltip: 'Hotline',
                      child: const Icon(Icons.phone),
                    )
                  : null,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showHotlineBottomSheet(
    BuildContext context,
    List<String> phoneNumbers,
  ) {
    final phoneService = PhoneService(
      hotlineNumbers: phoneNumbers
          .map((e) => PhoneContact(name: '', phone: e))
          .toList(),
    );
    phoneService.showHotlineBottomSheet(context);
  }

  _divider() =>
      const Divider(height: 25.0, thickness: 1.0, color: AppColors.strokeLight);

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
          _buildSubAndBodyText("Giá thuê:", price.toVND()),
          AppColors.onSurface2,
          textColor: AppColors.elementSecondary,
        ),
      ],
    );
  }

  Widget _buildRoomInfo(String type, String texture) {
    return Column(
      children: [
        _buildSubAndBodyText("Kết cấu:", texture),
        const SizedBox(height: 8),
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

  Widget _buildAddress(String address, dynamic geoPoint) {
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
                    if (!mounted) return;
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

  Widget _buildCar(String car) {
    return Row(
      children: [
        Text(
          "Xe:",
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(width: AppConstants.spacing),
        Text(car, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildFees(List<Fee> fees) {
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
                  return _costRow(fee.name, '${fee.price.toVND()}/${fee.unit}');
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
