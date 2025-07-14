import 'package:find_motel/common/widgets/common_alert_dialog.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_bloc.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_event.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_state.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImportMotelsScreen extends StatefulWidget {
  final List<List<String>> data;
  const ImportMotelsScreen({super.key, required this.data});

  @override
  State<ImportMotelsScreen> createState() => _ImportMotelsScreenState();
}

class _ImportMotelsScreenState extends State<ImportMotelsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ImportMotelsBloc>().add(HandleFileEvent(data: widget.data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImportMotelsBloc, ImportMotelsState>(
      listener: (context, state) {
        if (state.isSaved ?? false) {
          _showSaveMotelsSuccessDialog(context, state.motels?.length ?? 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CommonAppBar(
            title: 'Import Motels',
            onLeadingPressed: () {
              if (state.motels?.isNotEmpty ?? false) {
                _showConfirmDialog(context);
              } else {
                Navigator.pop(context);
              }
            },
            actions: [
              if (state.motels?.isNotEmpty ?? false)
                Text(
                  '${state.motels?.length ?? 0} trọ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.headerLineOnPrimary,
                  ),
                ),
              IconButton(
                onPressed: () {
                  if (state.motels?.isNotEmpty ?? false) {
                    context.read<ImportMotelsBloc>().add(
                      SaveMotelsEvent(motels: state.motels!),
                    );
                  }
                },
                icon: SvgPicture.asset('assets/images/ic_save.svg'),
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView.builder(
                itemCount: state.motels?.length ?? 0,
                itemBuilder: (context, index) {
                  return _buildMotel(state.motels![index]);
                },
              ),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMotel(Motel motel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _build2Field('Mã phòng:', motel.roomCode, 'Kết cấu:', motel.texture),
          const SizedBox(height: 4),
          _buildField('Kiểu phòng:', motel.type),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_marker.png',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 10),
                Text(
                  motel.address,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.elementSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (motel.extensions.isNotEmpty)
            _buildField('Tiện ích:', '[${motel.extensions.join(', ')}]'),
          const SizedBox(height: 4),
          Text(
            'Chi phí khác:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: motel.fees
                  .map(
                    (fee) => _buildField(
                      '${fee['name']}:',
                      '${(fee['price'] as double).toVND()}/${fee['unit']}',
                      isTitle: false,
                      isExpand: true,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String value, {
    bool isTitle = true,
    bool isExpand = false,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: isTitle
              ? const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                )
              : const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.elementSecondary,
                ),
        ),
        if (isExpand) const Spacer() else const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.elementSecondary,
          ),
        ),
      ],
    );
  }

  Widget _build2Field(
    String label,
    String value,
    String label2,
    String value2, {
    bool isTitle = true,
  }) {
    return Row(
      children: [
        _buildField(label, value, isTitle: isTitle),
        const Spacer(),
        _buildField(label2, value2, isTitle: isTitle),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommonAlertDialog(
          title: 'Xác nhận',
          content: 'Bạn chưa lưu thông tin',
          leadingActionTitle: 'Thoát',
          trailingActionTitle: 'Tiếp tục',
          onLeadingPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
          onTrailingPressed: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSaveMotelsSuccessDialog(BuildContext context, int motelsCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommonAlertDialog(
          title: 'Thành công',
          content: 'Lưu $motelsCount trọ thành công',
          leadingActionTitle: 'Đóng',
          onLeadingPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
