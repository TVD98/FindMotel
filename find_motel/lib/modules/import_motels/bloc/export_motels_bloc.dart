import 'package:find_motel/services/firestore/firestore_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'export_motels_event.dart';
import 'export_motels_state.dart';
import 'package:find_motel/utilities/excel_helper.dart';
import 'package:find_motel/services/motel/motels_service.dart';

class ExportMotelsBloc extends Bloc<ExportMotelsEvent, ExportMotelsState> {
  late IMotelsService _motelsService;

  ExportMotelsBloc({IMotelsService? motelsService}) : super(ExportMotelsInitial()) {
    _motelsService = motelsService ?? FirestoreService();
    on<FetchMotelsEvent>(_onFetchMotels);
    on<ExportMotelsToExcelEvent>(_onExportMotelsToExcel);
  }

  Future<void> _onFetchMotels(FetchMotelsEvent event, Emitter emit) async {
    emit(ExportMotelsLoading());
    try {
      emit(ExportMotelsLoading());
      final result = await _motelsService.getMotels(limit: 500);
      if (result.error != null) {
        emit(ExportMotelsError(result.error!));
        return;
      }
      emit(ExportMotelsLoaded(result.motels!));
    } catch (e) {
      emit(ExportMotelsError(e.toString()));
    }
  }

  Future<void> _onExportMotelsToExcel(ExportMotelsToExcelEvent event, Emitter emit) async {
    emit(ExportMotelsExporting());
    try {
      final excelHelper = ExcelHelper();
      final filePath = await excelHelper.exportMotelsToExcel(event.motels);
      emit(ExportMotelsExported(filePath));
    } catch (e) {
      emit(ExportMotelsError(e.toString()));
    }
  }
}
