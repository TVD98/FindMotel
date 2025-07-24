import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/widgets/edit_images_screen.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/services/reload_service.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_bloc.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_event.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_state.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EditMotelScreen extends StatefulWidget {
  final Motel motel;
  const EditMotelScreen({super.key, required this.motel});

  @override
  State<EditMotelScreen> createState() => _EditMotelScreenState();
}

class _EditMotelScreenState extends State<EditMotelScreen> {
  // Thay thế TextEditingController bằng Bloc
  late TextEditingController nameController;
  late TextEditingController roomCodeController;
  late TextEditingController typeController;
  late TextEditingController textureController;
  late TextEditingController commissionController;
  late TextEditingController priceController;
  late TextEditingController addressController;
  late TextEditingController electricityController;
  late TextEditingController waterController;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller và lắng nghe thay đổi để dispatch events
    nameController = TextEditingController();
    roomCodeController = TextEditingController();
    typeController = TextEditingController();
    textureController = TextEditingController();
    commissionController = TextEditingController();
    priceController = TextEditingController();
    addressController = TextEditingController();
    electricityController = TextEditingController();
    waterController = TextEditingController();
    noteController = TextEditingController();

    // Lắng nghe thay đổi trên controller và dispatch event
    nameController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelNameChanged(nameController.text),
      );
    });
    roomCodeController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelRoomCodeChanged(roomCodeController.text),
      );
    });
    typeController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelTypeChanged(typeController.text),
      );
    });
    textureController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelTextureChanged(textureController.text),
      );
    });
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
    electricityController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelElectricityChanged(electricityController.text),
      );
    });
    waterController.addListener(() {
      context.read<EditMotelBloc>().add(
        EditMotelWaterChanged(waterController.text),
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
    nameController.dispose();
    roomCodeController.dispose();
    typeController.dispose();
    textureController.dispose();
    commissionController.dispose();
    priceController.dispose();
    addressController.dispose();
    electricityController.dispose();
    waterController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Loại bỏ _setMainImage vì logic này sẽ được xử lý trong BLoC qua event
  // void _setMainImage(String img) {
  //   setState(() {
  //     mainImage = img;
  //   });
  // }

  Future<void> _showSelectExtensionsDialog(
    List<String> currentExtensions,
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
                            selectedColor: AppColors.primaryContainer,
                            backgroundColor: AppColors.surface,
                            labelStyle: AppTextStyle.body.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary
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
                    context.read<EditMotelBloc>().add(
                      EditMotelExtensionsUpdated(tempSelected),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Thêm',
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

  Future<void> _showAddFeeDialog() async {
    final nameControllerDialog = TextEditingController();
    final priceControllerDialog = TextEditingController();
    String selectedUnit = 'người';
    final units = ['người', 'phòng', 'tháng', 'lần'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Thêm Phí Dịch Vụ',
                style: AppTextStyle.heading5.copyWith(color: AppColors.primary),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 326, maxWidth: 326),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameControllerDialog,
                      style: GoogleFonts.quicksand(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Tên phí',
                        labelStyle: AppTextStyle.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppFontWeight.medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceControllerDialog,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.quicksand(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Số tiền',
                        labelStyle: AppTextStyle.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppFontWeight.medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      elevation: 32,
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.elementPrimary,
                      ),
                      dropdownColor: AppColors.onSurface1,
                      decoration: InputDecoration(
                        labelText: 'Đơn vị',
                        labelStyle: AppTextStyle.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppFontWeight.medium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      items: units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                          enabled: unit != selectedUnit,
                          alignment: Alignment.topLeft,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedUnit = value!;
                        });
                      },
                      icon: SvgPicture.asset(
                        'assets/images/ic_arrow_down.svg',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
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
                    final name = nameControllerDialog.text.trim();
                    final price = priceControllerDialog.text.trim();

                    if (name.isNotEmpty && price.isNotEmpty) {
                      context.read<EditMotelBloc>().add(
                        EditMotelCustomFeeAdded(
                          name: name,
                          price: price,
                          unit: selectedUnit,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Thêm',
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

  void _showSuccessDialog(BuildContext dialogContext, String message) {
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
              Navigator.popUntil(context, (route) => route.isFirst);
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
          _showSuccessDialog(context, 'Cập nhật thông tin căn hộ thành công!');
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
        child: Scaffold(
          appBar: const CommonAppBar(title: 'Chỉnh sửa căn hộ'),
          backgroundColor: AppColors.surface,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<EditMotelBloc, EditMotelState>(
              builder: (context, state) {
                // Cập nhật giá trị cho các controller khi trạng thái thay đổi
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  nameController.text = state.name;
                  roomCodeController.text = state.roomCode;
                  typeController.text = state.type;
                  textureController.text = state.texture;
                  commissionController.text = state.commission;
                  priceController.text = state.price;
                  addressController.text = state.address;
                  electricityController.text = state.electricity;
                  waterController.text = state.water;
                  noteController.text = state.note;
                });

                final _isLoading = state.status == EditMotelStatus.loading;
                final _isDeleting = state.status == EditMotelStatus.deleting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(context, state.mainImage, state.images),
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
                    _buildBasicInfoSection(),
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
                    const SizedBox(height: 8),
                    Text(
                      'Phí dịch vụ:',
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeesSection(context, state.customFees),
                    const SizedBox(height: 16),
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: (_isLoading || _isDeleting)
                                  ? Colors.grey
                                  : AppColors.onPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (_isLoading || _isDeleting)
                                ? null
                                : () async {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.warning_amber_outlined,
                                              color: AppColors.error,
                                              size: 32,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Xác nhận xóa !',
                                              style: AppTextStyle.heading5
                                                  .copyWith(
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
                                          'Bạn có chắc chắn muốn xóa căn hộ "${state.name}"?',
                                          style: AppTextStyle.body,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
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
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor:
                                                  AppColors.onPrimary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            child: Text(
                                              'Xóa',
                                              style: AppTextStyle.smallLabel
                                                  .copyWith(
                                                    color: AppColors.onPrimary,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldDelete == true) {
                                      context.read<EditMotelBloc>().add(
                                        const EditMotelDeleted(),
                                      );
                                    }
                                  },
                            child: _isDeleting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Đang xóa...'),
                                    ],
                                  )
                                : Text(
                                    'Xóa',
                                    style: AppTextStyle.label.copyWith(
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: (_isLoading || _isDeleting)
                                  ? Colors.grey
                                  : AppColors.primary,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: (_isLoading || _isDeleting)
                                ? null
                                : () {
                                    context.read<EditMotelBloc>().add(
                                      const EditMotelSubmitted(),
                                    );
                                  },
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Đang lưu...'),
                                    ],
                                  )
                                : Text(
                                    'Lưu',
                                    style: AppTextStyle.label.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Chuyển các hàm xây dựng Widget thành phương thức của class
  Widget _buildImageSection(
    BuildContext context,
    String mainImage,
    List<String> images,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ảnh lớn
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: mainImage.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: mainImage,
                  height: 140,
                  width: 246,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
        ),
        const SizedBox(height: 12),
        // Gallery ảnh nhỏ
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...images.map((img) {
                final isSelected = img == mainImage;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.read<EditMotelBloc>().add(
                        EditMotelMainImageChanged(img),
                      ),
                      child: Container(
                        width: 60,
                        height: 48,
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 1)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: img,
                            width: 60,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              // Nút thêm ảnh
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ImageDisplayScreen(initialImages: images),
                      ),
                    );
                    if (result is List<String> && result.isNotEmpty) {
                      context.read<EditMotelBloc>().add(
                        EditMotelImagesUpdated(result),
                      );
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Tên căn hộ', nameController)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Mã phòng', roomCodeController)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Kiểu phòng', typeController)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Kết cấu', textureController)),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField('Địa chỉ', addressController, maxLines: 2),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTextStyle.body.copyWith(color: AppColors.elementSecondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyle.label.copyWith(color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.strokeLight,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
      ),
    );
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Creates a divider widget with a light stroke color, thickness of 1, and height of 17.

  /*******  d9b4fabf-c17d-4dbd-8c86-73b958f7f6db  *******/
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 6.0),
              label: Text(e),
              labelStyle: AppTextStyle.body.copyWith(
                color: AppColors.elementHighlight,
              ),
              side: const BorderSide(color: AppColors.strokeLight, width: 1.0),
              deleteIcon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.error,
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
            onPressed: () => _showSelectExtensionsDialog(selectedExtensions),
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

  Widget _buildFeesSection(
    BuildContext context,
    List<Map<String, dynamic>> customFees,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phí điện
        _buildFeeItem(
          'Điện',
          electricityController,
          'số',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        // Phí nước
        _buildFeeItem(
          'Nước',
          waterController,
          'người',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 12),
        // Các phí tùy chỉnh
        ...customFees.asMap().entries.map((entry) {
          final index = entry.key;
          final fee = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildCustomFeeItem(
              fee['name'],
              fee['price'].toString(),
              fee['unit'],
              () {
                context.read<EditMotelBloc>().add(
                  EditMotelCustomFeeRemoved(index),
                );
              },
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _showAddFeeDialog,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.onSecondary,
            ),
            label: Text(
              'Thêm phí khác',
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

  Widget _buildFeeItem(
    String name,
    TextEditingController controller,
    String unit, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField(
            name,
            controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Text(
              '/$unit',
              style: AppTextStyle.body.copyWith(
                color: AppColors.elementSecondary,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFeeItem(
    String name,
    String price,
    String unit,
    VoidCallback onDelete,
  ) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    final formattedPrice = formatter.format(int.tryParse(price) ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$name: $formattedPrice đ/$unit',
              style: AppTextStyle.body.copyWith(color: AppColors.elementSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 24,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildTextField(
      ' mỗi dòng một ghi chú ',
      noteController,
      maxLines: 5,
    );
  }
}
