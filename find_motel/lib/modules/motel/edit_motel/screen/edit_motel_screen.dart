import 'package:find_motel/common/models/filter_option.dart';
import 'package:find_motel/common/widgets/common_selection_view.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/common/widgets/motel_images_view.dart';
import 'package:find_motel/common/widgets/selection_bottom_sheet.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/motel/edit_motel/screen/motel_fees_form.dart';
import 'package:find_motel/modules/motel/edit_motel/screen/motel_phone_numbers_form.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/services/reload_service.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_bloc.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_event.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditMotelScreen extends StatefulWidget {
  final Motel motel;
  const EditMotelScreen({super.key, required this.motel});

  @override
  State<EditMotelScreen> createState() => _EditMotelScreenState();
}

class _EditMotelScreenState extends State<EditMotelScreen> {
  // Thay thế TextEditingController bằng Bloc
  late TextEditingController commissionController;
  late TextEditingController priceController;
  late TextEditingController addressController;
  late TextEditingController noteController;
  late TextEditingController carController; // Thêm controller cho thông tin xe

  @override
  void initState() {
    super.initState();
    commissionController = TextEditingController(text: widget.motel.commission);
    priceController = TextEditingController(text: widget.motel.price.toVND());
    addressController = TextEditingController(text: widget.motel.address);
    noteController = TextEditingController(text: widget.motel.note.join('\n'));
    carController = TextEditingController(text: widget.motel.car);

    carController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelCarChanged(carController.text),
      );
    });

    // Lắng nghe thay đổi trên controller và dispatch event
    commissionController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelCommissionChanged(commissionController.text),
      );
    });
    priceController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelPriceChanged(priceController.text),
      );
    });
    addressController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelAddressChanged(addressController.text),
      );
    });
    noteController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelNoteChanged(noteController.text),
      );
    });

    // Dispatch sự kiện khởi tạo BLoC với dữ liệu motel ban đầu
    context.read<EditMotelBloc>().add(EditMotelInitialized(widget.motel));
  }

  @override
  void dispose() {
    // Đảm bảo dispose các controller
    commissionController.dispose();
    priceController.dispose();
    addressController.dispose();
    noteController.dispose();
    carController.dispose(); // Dispose controller thông tin xe
    super.dispose();
  }

  Future<void> _showSelectExtensionsDialog(
    List<String> currentExtensions,
    Function(List<String>) onDone,
  ) async {
    final allExtensions = AppDataManager().allAmenities;
    List<String> tempSelected = List<String>.from(currentExtensions);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
              title: Text(
                'Danh Sách Tiện Ích',
                style: AppTextStyle.heading5.copyWith(color: AppColors.primary),
              ),

              contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 120,
                    minWidth: 326,
                    maxWidth: 326,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        color: AppColors.strokeLight,
                        thickness: 1,
                        height: 17,
                      ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        children: allExtensions.map((e) {
                          final isSelected = tempSelected.contains(e);
                          return ChoiceChip(
                            label: Text(e),
                            selected: isSelected,
                            selectedColor: AppColors.secondaryContainer,
                            backgroundColor: AppColors.surface,
                            showCheckmark: false,
                            labelStyle: AppTextStyle.body.copyWith(
                              color: isSelected
                                  ? AppColors.onSecondaryContainer
                                  : AppColors.elementSecondary,
                            ),
                            onSelected: (selected) {
                              setStateDialog(() {
                                if (selected) {
                                  tempSelected.add(e);
                                } else {
                                  tempSelected.remove(e);
                                }
                              });
                            },
                            side: isSelected
                                ? BorderSide.none
                                : const BorderSide(
                                    color: AppColors.strokeLight,
                                    width: 1,
                                  ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    onDone(tempSelected);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Lưu',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(BuildContext dialogContext, String message) {
    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Lỗi',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.quicksand()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.quicksand(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext dialogContext, Motel? motel) {
    final message = motel != null
        ? 'Cập nhật thông tin căn hộ thành công!'
        : 'Xóa thông tin căn hộ thành công!';
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'Thành công',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.quicksand()),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              ReloadService.setHomeNeedsReload();
              if (motel != null) {
                Navigator.pop(context, motel);
              } else {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: Text(
              'OK',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditMotelBloc, EditMotelState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditMotelStatus.success) {
          _showSuccessDialog(context, state.updatedMotel);
        } else if (state.status == EditMotelStatus.failure) {
          _showErrorDialog(
            context,
            state.errorMessage ?? 'Có lỗi không xác định.',
          );
        } else if (state.status == EditMotelStatus.deleting) {
          // Có thể hiển thị một loading indicator toàn màn hình tại đây nếu cần
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<EditMotelBloc, EditMotelState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CommonAppBar(
                title: state.mode == EditMotelMode.edit
                    ? 'Chỉnh Sửa Phòng Trọ'
                    : 'Thêm Phòng Trọ',
              ),
              backgroundColor: AppColors.surface,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(state.images),
                    const SizedBox(height: 16),
                    _divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Thông tin cơ bản:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(state),
                    const SizedBox(height: 16),
                    _divider(),
                    _buildPhoneNumberSection(state.phoneNumbers),
                    const SizedBox(height: 16),
                    _divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Tiện ích:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildExtensionsSection(context, state.extensions),
                    const SizedBox(height: 16),
                    _divider(),
                    _buildCarSection(),
                    const SizedBox(height: 16),
                    _divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Phí dịch vụ:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeesSection(state.customFees),
                    const SizedBox(height: 16),
                    Text(
                      'Toạ độ:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLocationSection(state.location),
                    const SizedBox(height: 8),
                    _divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Ghi chú:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNotesSection(),
                    const SizedBox(height: 24),
                    _buildBottomActionButtons(
                      context: context,
                      isLoading: state.status == EditMotelStatus.loading,
                      isDeleting: state.status == EditMotelStatus.deleting,
                      state: state,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection(List<String> images) {
    return MotelImagesView(
      imageUrls: images,
      isCanEdit: true,
      onImagesChanged: (images) {
        context.read<EditMotelBloc>().add(EditMotelImagesUpdated(images));
      },
    );
  }

  Widget _buildBasicInfoSection(EditMotelState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSelectionView(
                'Kiểu phòng',
                state.type,
                AppDataManager().allRoomTypies,
                (options) {
                  context.read<EditMotelBloc>().add(
                    EditMotelTypeChanged(options.first.name),
                  );
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildSelectionView(
                'Kết cấu',
                state.texture,
                AppDataManager().allTexturies,
                (options) {
                  context.read<EditMotelBloc>().add(
                    EditMotelTextureChanged(options.first.name),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Hoa hồng', commissionController)),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                'Giá thuê',
                priceController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField('Địa chỉ', addressController, maxLines: 2),
      ],
    );
  }

  Widget _buildPhoneNumberSection(List<String> phoneNumbers) {
    return MotelPhoneNumbersForm(
      phoneNumbers: phoneNumbers,
      onAdd: (newPhone) {
        final updated = List<String>.from(phoneNumbers)..add(newPhone);
        context.read<EditMotelBloc>().add(
          EditMotelPhoneNumbersChanged(updated),
        );
      },
      onDelete: (phone) {
        final updated = List<String>.from(phoneNumbers)..remove(phone);
        context.read<EditMotelBloc>().add(
          EditMotelPhoneNumbersChanged(updated),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return CommonTextfield(
      controller: controller,
      label: label,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget _buildSelectionView(
    String label,
    String value,
    List<String> items,
    ValueChanged<List<FilterOption>> onApply,
  ) {
    final allOptions = items.map((e) => FilterOption(id: e, name: e)).toList();
    final selectedOptions = [FilterOption(id: value, name: value)];

    return CommonSelectionView(
      title: label,
      value: value,
      titleBackground: Theme.of(context).scaffoldBackgroundColor,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return CommonBottomSheet(
              title: label,
              options: allOptions,
              initialSelectedOptions: selectedOptions,
              onApply: onApply,
            );
          },
        );
      },
    );
  }

  Widget _divider() {
    return const Divider(
      color: AppColors.strokeLight,
      thickness: 1,
      height: 17,
    );
  }

  Widget _buildExtensionsSection(
    BuildContext context,
    List<String> selectedExtensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedExtensions.map((e) {
            return Chip(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              label: Text(e),
              labelStyle: AppTextStyle.body.copyWith(
                color: AppColors.elementHighlight,
              ),
              side: const BorderSide(color: AppColors.strokeLight, width: 1.0),
              deleteIcon: SvgPicture.asset(
                'assets/images/ic_trash.svg',
                width: 16,
                height: 16,
              ),
              onDeleted: () {
                final updatedExtensions = List<String>.from(selectedExtensions)
                  ..remove(e);
                context.read<EditMotelBloc>().add(
                  EditMotelExtensionsUpdated(updatedExtensions),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () =>
                _showSelectExtensionsDialog(selectedExtensions, (extensions) {
                  context.read<EditMotelBloc>().add(
                    EditMotelExtensionsUpdated(extensions),
                  );
                }),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.onSecondary,
            ),
            label: Text(
              'Thêm tiện ích',
              style: AppTextStyle.smallLabel.copyWith(
                color: AppColors.onPrimary,
                fontSize: 13,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.tertiary,
              side: const BorderSide(color: AppColors.strokeLight, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xe:',
          style: AppTextStyle.subtitle.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        _buildTextField('', carController),
      ],
    );
  }

  Widget _buildFeesSection(List<Fee> customFees) {
    return MotelFeesForm(
      fees: customFees,
      onFeeAdded: (fee) {
        context.read<EditMotelBloc>().add(
          EditMotelFeeAdded(
            Fee(name: fee.name, price: fee.price, unit: fee.unit),
          ),
        );
      },
      onFeeDeleted: (fee) {
        context.read<EditMotelBloc>().add(
          EditMotelFeeDeleted(
            Fee(name: fee.name, price: fee.price, unit: fee.unit),
          ),
        );
      },
      onFeeUpdated: (fee) {
        context.read<EditMotelBloc>().add(
          EditMotelFeeUpdated(
            Fee(name: fee.name, price: fee.price, unit: fee.unit),
          ),
        );
      },
    );
  }

  Widget _buildLocationSection(LatLng? location) {
    return CommonSelectionView(
      title: '',
      value:
          '${location?.latitude.toStringAsFixed(6)} - ${location?.longitude.toStringAsFixed(6)}',
      titleBackground: Theme.of(context).scaffoldBackgroundColor,
      suffixIcon: const Icon(Icons.map, color: AppColors.primary),
      onTap: () async {
        final result = await _showEditLocationDialog(location);
        if (result != null && mounted) {
          context.read<EditMotelBloc>().add(EditMotelLocationUpdated(result));
        }
      },
    );
  }

  Future<LatLng?> _showEditLocationDialog(LatLng? location) async {
    final latitudeControllerDialog = TextEditingController(
      text: location?.latitude.toString(),
    );
    final longitudeControllerDialog = TextEditingController(
      text: location?.longitude.toString(),
    );
    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Chỉnh sửa tọa độ',
                style: AppTextStyle.heading5.copyWith(color: AppColors.primary),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 326, maxWidth: 326),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonTextfield(
                      controller: latitudeControllerDialog,
                      label: 'Latitude',
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                    ),
                    const SizedBox(height: 16),
                    CommonTextfield(
                      controller: longitudeControllerDialog,
                      label: 'Longitude',
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final latitude = latitudeControllerDialog.text.trim();
                    final longitude = longitudeControllerDialog.text.trim();

                    if (latitude.isNotEmpty && longitude.isNotEmpty) {
                      Navigator.pop(
                        context,
                        LatLng(double.parse(latitude), double.parse(longitude)),
                      );
                    }
                  },
                  child: Text(
                    'Cập nhật',
                    style: AppTextStyle.smallLabel.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (result is LatLng) return result;
    return null;
  }

  Widget _buildNotesSection() {
    return _buildTextField(
      '',
      noteController,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
    );
  }

  Widget _buildDeleteButton({
    required BuildContext context,
    required bool isDeleting,
    required bool isLoading,
    required EditMotelState state,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: (isLoading || isDeleting)
            ? Colors.grey
            : AppColors.onPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: (isLoading || isDeleting)
          ? null
          : () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.error,
                        size: 32,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Xác nhận xóa !',
                        style: AppTextStyle.heading5.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const Divider(
                        color: AppColors.strokeLight,
                        thickness: 1,
                        height: 4,
                      ),
                    ],
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn xóa căn hộ ${state.initialMotel?.displayName}?',
                    style: AppTextStyle.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(
                        'Hủy',
                        style: GoogleFonts.quicksand(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(
                        'Xóa',
                        style: AppTextStyle.smallLabel.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true && context.mounted) {
                context.read<EditMotelBloc>().add(const EditMotelDeleted());
              }
            },
      child: isDeleting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Đang xóa...'),
              ],
            )
          : Text(
              'Xóa',
              style: AppTextStyle.label.copyWith(color: AppColors.tertiary),
            ),
    );
  }

  // Xây dựng nút "Lưu"
  Widget _buildSaveButton({
    required BuildContext context,
    required bool isLoading,
    required bool isDeleting,
    required EditMotelMode mode,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: (isLoading || isDeleting)
            ? Colors.grey
            : AppColors.primary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: (isLoading || isDeleting)
          ? null
          : () {
              context.read<EditMotelBloc>().add(const EditMotelSubmitted());
            },
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  mode == EditMotelMode.edit ? 'Đang lưu...' : 'Đang thêm...',
                ),
              ],
            )
          : Text(
              mode == EditMotelMode.edit ? 'Lưu' : 'Thêm',
              style: AppTextStyle.label.copyWith(color: AppColors.onPrimary),
            ),
    );
  }

  // Xây dựng phần nút hành động ở cuối trang
  Widget _buildBottomActionButtons({
    required BuildContext context,
    required bool isLoading,
    required bool isDeleting,
    required EditMotelState state,
  }) {
    return Row(
      children: state.mode == EditMotelMode.edit
          ? [
              Expanded(
                child: _buildDeleteButton(
                  context: context,
                  isDeleting: isDeleting,
                  isLoading: isLoading,
                  state: state,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSaveButton(
                  context: context,
                  isLoading: isLoading,
                  isDeleting: isDeleting,
                  mode: EditMotelMode.edit,
                ),
              ),
            ]
          : [
              Expanded(
                child: _buildSaveButton(
                  context: context,
                  isLoading: isLoading,
                  isDeleting: isDeleting,
                  mode: EditMotelMode.create,
                ),
              ),
            ],
    );
  }
}
