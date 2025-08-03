import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/utilities/excel_reader.dart';

class ImportMotelsEvent extends Equatable {
  const ImportMotelsEvent();

  @override
  List<Object?> get props => [];
}

class HandleFileEvent extends ImportMotelsEvent {
  final List<ExcelData> data;

  const HandleFileEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

class FilterDuplicateEvent extends ImportMotelsEvent {
  const FilterDuplicateEvent();

  @override
  List<Object?> get props => [];
}

class SaveMotelsEvent extends ImportMotelsEvent {
  final List<Motel> motels;
  const SaveMotelsEvent({required this.motels});

  @override
  List<Object?> get props => [motels];
}

  