import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

abstract class ExportMotelsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExportMotelsInitial extends ExportMotelsState {}

class ExportMotelsLoading extends ExportMotelsState {}

class ExportMotelsLoaded extends ExportMotelsState {
  final List<Motel> motels;
  ExportMotelsLoaded(this.motels);

  @override
  List<Object?> get props => [motels];
}

class ExportMotelsError extends ExportMotelsState {
  final String message;
  ExportMotelsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExportMotelsExporting extends ExportMotelsState {}

class ExportMotelsExported extends ExportMotelsState {
  final String filePath;
  ExportMotelsExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
