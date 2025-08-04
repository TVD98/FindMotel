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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xuất file Excel thành công!'),
                    ),
                  );
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
