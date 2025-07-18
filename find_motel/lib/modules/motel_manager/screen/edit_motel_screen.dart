import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/widgets/edit_images_screen.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/reload_service.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';

class EditMotelScreen extends StatefulWidget {
  final Motel motel;
  const EditMotelScreen({super.key, required this.motel});

  @override
  State<EditMotelScreen> createState() => _EditMotelScreenState();
}

class _EditMotelScreenState extends State<EditMotelScreen> {
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

  List<String> selectedExtensions = [];
  List<Map<String, dynamic>> fees = [];
  List<String> notes = [];
  List<Map<String, dynamic>> customFees = []; // Danh sách phí tùy chỉnh

  late String mainImage;
  late List<String> images; // url hoặc path local

  bool _isLoading = false;
  bool _isDeleting = false;

  final IMotelsService motelsService = FirestoreService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.motel.name);
    roomCodeController = TextEditingController(text: widget.motel.roomCode);
    typeController = TextEditingController(text: widget.motel.type);
    textureController = TextEditingController(text: widget.motel.texture);
    commissionController = TextEditingController(text: widget.motel.commission);
    priceController = TextEditingController(
      text: widget.motel.price.toStringAsFixed(0),
    );
    addressController = TextEditingController(text: widget.motel.address);
    electricityController = TextEditingController(text: _getFeeValue('Điện'));
    waterController = TextEditingController(text: _getFeeValue('Nước'));
    noteController = TextEditingController(text: widget.motel.note.join('\n'));
    selectedExtensions = List<String>.from(widget.motel.extensions);
    fees = List<Map<String, dynamic>>.from(widget.motel.fees);
    notes = List<String>.from(widget.motel.note);

    // Khởi tạo custom fees (loại bỏ điện, nước)
    customFees = widget.motel.fees
        .where((fee) => !['Điện', 'Nước'].contains(fee['name']))
        .map((fee) => Map<String, dynamic>.from(fee))
        .toList();

    mainImage = widget.motel.thumbnail;
    images = List<String>.from(widget.motel.images);
  }

  String _getFeeValue(String name) {
    final fee = widget.motel.fees.firstWhere(
      (f) => f['name'] == name,
      orElse: () => {},
    );
    if (fee.isEmpty) return '';
    // Lấy đúng số tiền, bỏ phần đơn vị và ký tự không phải số
    final priceRaw = fee['price']?.toString() ?? '';
    final priceNumber = priceRaw.replaceAll(RegExp(r'[^\d]'), '');
    return priceNumber;
  }

  void _setMainImage(String img) {
    setState(() {
      mainImage = img;
    });
  }

  Future<void> _showSelectExtensionsDialog() async {
    final allExtensions = AppDataManager().allAmenities;
    // Tạo bản sao để chọn tạm thời
    List<String> tempSelected = List<String>.from(selectedExtensions);

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
                'Danh Sách Tiện Ích',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allExtensions.map((e) {
                    final isSelected = tempSelected.contains(e);
                    return ChoiceChip(
                      label: Text(e),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.quicksand(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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
                              color: AppColors.primary,
                              width: 1,
                            ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
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
                    setState(() {
                      selectedExtensions = List<String>.from(tempSelected);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddFeeDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
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
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.quicksand(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Tên phí',
                      labelStyle: GoogleFonts.quicksand(
                        color: AppColors.primary,
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
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.quicksand(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Số tiền',
                      labelStyle: GoogleFonts.quicksand(
                        color: AppColors.primary,
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
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Đơn vị',
                      labelStyle: GoogleFonts.quicksand(
                        color: AppColors.primary,
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
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedUnit = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.quicksand(color: Colors.grey),
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
                    final name = nameController.text.trim();
                    final price = priceController.text.trim();

                    if (name.isNotEmpty && price.isNotEmpty) {
                      setState(() {
                        customFees.add({
                          'name': name,
                          'price': int.parse(price),
                          'unit': selectedUnit,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Thêm',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeFee(int index) {
    setState(() {
      customFees.removeAt(index);
    });
  }

  Future<void> _saveMotel() async {
    if (_isLoading) return; // Prevent double tap

    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy tất cả dữ liệu từ các controller
      final name = nameController.text.trim();
      final roomCode = roomCodeController.text.trim();
      final type = typeController.text.trim();
      final texture = textureController.text.trim();
      final commission = commissionController.text.trim();
      final price = priceController.text.trim();
      final address = addressController.text.trim();
      final electricity = electricityController.text.trim();
      final water = waterController.text.trim();
      final note = noteController.text.trim();

      // Validation cơ bản
      if (name.isEmpty || address.isEmpty) {
        _showErrorDialog('Vui lòng nhập đầy đủ tên căn hộ và địa chỉ!');
        return;
      }

      // Chuẩn bị fees list với custom fees
      final updatedFees = [
        {'name': 'Điện', 'price': int.tryParse(electricity) ?? 0, 'unit': 'số'},
        {'name': 'Nước', 'price': int.tryParse(water) ?? 0, 'unit': 'người'},
        ...customFees, // Thêm các phí tùy chỉnh
      ];

      // Tạo object Motel mới với dữ liệu đã update
      final updatedMotel = Motel(
        id: widget.motel.id,
        name: name,
        roomCode: roomCode,
        type: type,
        texture: texture,
        commission: commission,
        price: double.tryParse(price) ?? 0,
        address: address,
        note: note.split('\n'),
        extensions: selectedExtensions,
        fees: updatedFees,
        images: images,
        thumbnail: images.first,
        geoPoint: widget.motel.geoPoint,
        status: widget.motel.status,
        marker: images.first
      );

      final error = await motelsService.updateMotelWithImages(updatedMotel);

      if (error == null) {
        // Thành công - trở về màn home và reload data
        _showSuccessDialog();
      } else {
        // Có lỗi
        _showErrorDialog('Lỗi khi cập nhật: $error');
      }
    } catch (e) {
      // Xử lý exception
      _showErrorDialog('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteMotel() async {
    if (_isDeleting) return; // Prevent double tap

    // Hiển thị dialog xác nhận xóa
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'Xác nhận xóa',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa căn hộ "${nameController.text.trim()}"?\nHành động này không thể hoàn tác.',
          style: GoogleFonts.quicksand(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Xóa',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // Tạo instance của FirestoreService và xóa
      final firestoreService = FirestoreService();
      final error = await firestoreService.deleteMotel(widget.motel.id);

      if (error == null) {
        // Thành công - hiển thị dialog thành công
        _showDeleteSuccessDialog();
      } else {
        // Có lỗi
        _showErrorDialog('Lỗi khi xóa: $error');
      }
    } catch (e) {
      // Xử lý exception
      _showErrorDialog('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
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
        content: Text(
          'Cập nhật thông tin căn hộ thành công!',
          style: GoogleFonts.quicksand(),
        ),
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
              // Set flag để reload home
              ReloadService.setHomeNeedsReload();
              // Pop về home trực tiếp
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

  void _showDeleteSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'Đã xóa',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Text(
          'Đã xóa căn hộ thành công!',
          style: GoogleFonts.quicksand(),
        ),
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
              // Set flag để reload home
              ReloadService.setHomeNeedsReload();
              // Pop về home trực tiếp
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
    return Scaffold(
      appBar: const CommonAppBar(title: 'Chỉnh sửa căn hộ'),
      backgroundColor: const Color(0xFFF5F5F5),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh chính và gallery
              _buildImageSection(),
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 8),
              Text(
                'Thông tin cơ bản:',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 8),
              Text(
                'Tiện ích:',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildExtensionsSection(),
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 8),
              Text(
                'Phí dịch vụ:',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeesSection(),
              const SizedBox(height: 16),
              _divider(),
              const SizedBox(height: 8),
              Text(
                'Ghi chú:',
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _buildNotesSection(),
              const SizedBox(height: 24),
              // Row chứa nút xóa và nút lưu
              Row(
                children: [
                  // Nút xóa
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: (_isLoading || _isDeleting)
                            ? Colors.grey
                            : Colors.red,
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
                          : _deleteMotel,
                      child: _isDeleting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Đang xóa...'),
                              ],
                            )
                          : const Text('Xóa'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nút lưu
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
                          : _saveMotel,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Đang lưu...'),
                              ],
                            )
                          : const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
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
                  width: double.infinity,
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
                      onTap: () => _setMainImage(img),
                      child: Container(
                        width: 60,
                        height: 48,
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: AppColors.primary, width: 2)
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
              }),
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
                      setState(() {
                        images = result;
                        mainImage = result.first;
                      });
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
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Mã phòng', roomCodeController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Kiểu phòng', typeController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Kết cấu', textureController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Hoa hồng', commissionController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Giá thuê', priceController)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField('Địa chỉ', addressController, maxLines: 2),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.strokeLight),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildExtensionsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedExtensions.map((e) {
                return Chip(
                  label: Text(e),
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  labelStyle: GoogleFonts.quicksand(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 32,
            ),
            onPressed: _showSelectExtensionsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildFeesSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeeInput(
                label: 'Điện',
                controller: electricityController,
                unit: 'kWh',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeInput(
                label: 'Nước',
                controller: waterController,
                unit: 'người',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Hiển thị các phí tùy chỉnh
        ...customFees.asMap().entries.map((entry) {
          final index = entry.key;
          final fee = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.strokeLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee['name'],
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${NumberFormat("#,##0", "vi_VN").format(fee['price'])} VND/${fee['unit']}',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFee(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Nút thêm phí
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
          onPressed: _showAddFeeDialog,
          icon: const Icon(Icons.add),
          label: Text(
            'Thêm phí dịch vụ',
            style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeInput({
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // Bỏ onChanged format VND
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.strokeLight),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unit,
                style: GoogleFonts.quicksand(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return TextField(
      controller: noteController,
      maxLines: 4,
      style: GoogleFonts.quicksand(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.strokeLight),
        ),
        isDense: true,
        hintText: 'Nhập ghi chú...',
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 30, thickness: 1, color: AppColors.strokeLight);
}
