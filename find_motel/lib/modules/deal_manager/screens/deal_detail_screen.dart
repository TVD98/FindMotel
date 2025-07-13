import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/common/widgets/common_alert_dialog.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/extensions/datetime_extensions.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/utilities/mask_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../bloc/deal_detail_bloc.dart';
import '../bloc/deal_detail_event.dart';
import '../bloc/deal_detail_state.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;

  const DealDetailScreen({super.key, required this.deal});

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController priceController;
  late TextEditingController scheduleController;

  Deal get _deal => widget.deal.copyWith(
    name: nameController.text,
    phone: phoneController.text,
    price:
        double.tryParse(
          priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0,
    schedule: scheduleController.text.parseDate('dd/MM/yyyy'),
  );

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.deal.name);
    phoneController = TextEditingController(text: widget.deal.phone);
    priceController = TextEditingController(text: widget.deal.price.toVND());
    scheduleController = TextEditingController(
      text: widget.deal.schedule.toFormattedString('dd/MM/yyyy'),
    );
    priceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    final text = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      priceController.value = TextEditingValue(text: '');
      return;
    }
    final formatted = NumberFormat('#,###', 'vi_VN').format(int.parse(text));
    if (priceController.text != formatted) {
      priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    priceController.dispose();
    scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DealDetailBloc()
            ..add(DealDetailMotelLoaded(motelId: widget.deal.motelId)),
      child: BlocListener<DealDetailBloc, DealDetailState>(
        listener: (context, state) {
          if (state.isSaved == true) {
            Navigator.of(context).pop(_deal);
          }

          if (state.error != null) {
            _showErrorDialog(context, state.error!, () {
              context.read<DealDetailBloc>().add(DealDetailCountinueEditing());
            });
          }
        },
        child: BlocBuilder<DealDetailBloc, DealDetailState>(
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.white,
                  appBar: CommonAppBar(
                    title: 'Chi tiết Deal',
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (state.isViewMode) {
                            context.read<DealDetailBloc>().add(
                              DealDetailEditToggled(),
                            );
                          } else {
                            context.read<DealDetailBloc>().add(
                              DealDetailSaved(deal: _deal),
                            );
                          }
                        },
                        icon: SvgPicture.asset(
                          state.isViewMode
                              ? 'assets/images/ic_header_edit.svg'
                              : 'assets/images/ic_header_save.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Text(
                              widget.deal.motelName,
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
                        Text(
                          state.motelAddress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.tertiary,
                          ),
                        ),
                        _divider(),
                        Center(
                          child: Text(
                            'Thông Tin Khách Hàng',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        CommonTextfield(
                          controller: nameController,
                          title: 'Họ và tên',
                          enabled: !state.isViewMode,
                        ),
                        const SizedBox(height: 16),
                        CommonTextfield(
                          controller: phoneController,
                          title: 'Số điện thoại',
                          keyboardType: TextInputType.phone,
                          enabled: !state.isViewMode,
                        ),
                        const SizedBox(height: 16),
                        CommonTextfield(
                          controller: priceController,
                          title: 'Mức giá thỏa thuận',
                          keyboardType: TextInputType.number,
                          enabled: !state.isViewMode,
                        ),
                        const SizedBox(height: 16),
                        CommonTextfield(
                          controller: scheduleController,
                          title: 'Lịch hẹn',
                          enabled: !state.isViewMode,
                          inputFormatters: [dateMaskFormatter],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (state.isSaving)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 50.0, thickness: 1.0, color: AppColors.strokeLight);

  void _showErrorDialog(BuildContext context, String errorMessage, VoidCallback? onRetry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommonAlertDialog(
          title: 'Lỗi',
          content: errorMessage,
          trailingActionTitle: 'OK',
          onTrailingPressed: () {
            if (onRetry != null) {
              onRetry;
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
