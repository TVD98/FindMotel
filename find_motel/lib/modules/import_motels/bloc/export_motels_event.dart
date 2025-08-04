import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

abstract class ExportMotelsEvent extends Equatable {
  const ExportMotelsEvent();

  @override
  List<Object?> get props => [];
}

class FetchMotelsEvent extends ExportMotelsEvent {
  const FetchMotelsEvent();

  @override
  List<Object?> get props => [];
}

class ExportMotelsToExcelEvent extends ExportMotelsEvent {
  final List<Motel> motels;

  const ExportMotelsToExcelEvent(this.motels);

  @override
  List<Object?> get props => [motels];
}
