import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/common/widgets/common_textfield.dart';
import 'package:find_motel/modules/import_motels/bloc/import_motels_bloc.dart';
import 'package:find_motel/modules/import_motels/screens/import_motels_screen.dart';
import 'package:find_motel/modules/motel/edit_motel/bloc/edit_motel_bloc.dart';
import 'package:find_motel/modules/motel/edit_motel/screen/edit_motel_screen.dart';
import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:find_motel/services/motel/motels_service.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:find_motel/utilities/excel_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MotelsDataScreen extends StatefulWidget {
  const MotelsDataScreen({super.key});

  @override
  State<MotelsDataScreen> createState() => _MotelsDataScreenState();
}

class _MotelsDataScreenState extends State<MotelsDataScreen> {
  final ExcelReader excelReader = ExcelReader();
  final IMotelsService motelsService = FirestoreService();
  bool isLoading = false;

  void _checkMotelId(String id) {
    setState(() {
      isLoading = true;
    });
    motelsService.doesMotelExist(id).then((exists) {
      setState(() {
        isLoading = false;
      });
      if (exists) {
        _addMotel(id, error: 'ID đã tồn tại');
      } else {
        _pushEditMotelScreen(Motel.empty(id));
      }
    });
  }

  void _addMotel(String id, {String? error}) async {
    final motelId = await _showChooseMotelIdDialog(id, error: error);
    if (motelId.isNotEmpty) {
      _checkMotelId(motelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Dữ liệu nhà trọ'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _importCard(),
                const Divider(height: 32, color: AppColors.strokeLight),
                _exportCard(),
              ],
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addMotel('');
        },
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _importCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: AppColors.strokeLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Tải file:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final result = await excelReader.readExcelFile();
                if (result.isNotEmpty && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => ImportMotelsBloc(),
                        child: ImportMotelsScreen(data: result),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                'File excel .xlsx',
                style: AppTextStyle.label.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: AppColors.strokeLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                'Xuất file:',
                style: TextStyle(
                  fontSize: 16.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text(
                'File excel .xlsx',
                style: AppTextStyle.label.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _showChooseMotelIdDialog(
    String motelId, {
    String? error,
  }) async {
    final motelIdControllerDialog = TextEditingController(text: motelId);
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
                'Chọn ID nhà trọ',
                style: AppTextStyle.heading5.copyWith(color: AppColors.primary),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 326, maxWidth: 326),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonTextfield(
                      controller: motelIdControllerDialog,
                      title: 'ID',
                      titleBackground: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          error,
                          style: AppTextStyle.smallLabel.copyWith(
                            color: AppColors.error,
                          ),
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
                    final motelId = motelIdControllerDialog.text.trim();
                    if (motelId.isNotEmpty) {
                      Navigator.pop(context, motelId);
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
    if (result is String) return result;
    return '';
  }

  void _pushEditMotelScreen(Motel motel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditMotelBloc(),
          child: EditMotelScreen(motel: motel),
        ),
      ),
    );
  }
}
