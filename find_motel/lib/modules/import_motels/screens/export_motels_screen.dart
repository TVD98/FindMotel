import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/theme/app_textStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/export_motels_bloc.dart';
import '../bloc/export_motels_event.dart';
import '../bloc/export_motels_state.dart';

class ExportMotelsScreen extends StatelessWidget {
  const ExportMotelsScreen({super.key});

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    // Lấy tên file từ đường dẫn
    final fileName = filePath.split('/').last;
    // Lấy thư mục (bỏ tên file)
    final folderPath = filePath.replaceAll('/$fileName', '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 8),
            const Expanded(child: Text('Xuất file thành công!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File đã được lưu tại:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📁 $folderPath',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📄 $fileName',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportMotelsBloc()..add(FetchMotelsEvent()),
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'Xuất danh sách Motel',
          actions: [
            BlocBuilder<ExportMotelsBloc, ExportMotelsState>(
              builder: (context, state) {
                if (state is ExportMotelsLoaded) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        '${state.motels.length} trọ',
                        style: const TextStyle(
                          color: AppColors.headerLineOnPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<ExportMotelsBloc, ExportMotelsState>(
          builder: (context, state) {
            if (state is ExportMotelsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExportMotelsLoaded) {
              if (state.motels.isEmpty) {
                return const Center(child: Text('Không có motel nào.'));
              }
              return ListView.builder(
                itemCount: state.motels.length,
                itemBuilder: (context, index) {
                  final motel = state.motels[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              'Mã: ',
                              style: AppTextStyle.title.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              motel.displayName,
                              style: AppTextStyle.title.copyWith(
                                color: AppColors.elementPrimary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          motel.address,
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.elementSecondary,
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.strokeLight),
                    ],
                  );
                },
              );
            }
            if (state is ExportMotelsError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }
            if (state is ExportMotelsExporting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExportMotelsExported) {
              Future.delayed(Duration.zero, () {
                if (context.mounted) {
                  _showExportSuccessDialog(context, state.filePath);
                }
              });
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: BlocBuilder<ExportMotelsBloc, ExportMotelsState>(
          builder: (context, state) {
            return FloatingActionButton.extended(
              icon: const Icon(Icons.file_download),
              label: const Text('Xuất Excel'),
              onPressed: state is ExportMotelsLoaded
                  ? () {
                      context.read<ExportMotelsBloc>().add(
                        ExportMotelsToExcelEvent(state.motels),
                      );
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
