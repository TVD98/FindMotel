import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

class ImportMotelsEvent extends Equatable {
  const ImportMotelsEvent();

  @override
  List<Object?> get props => [];
}

class HandleFileEvent extends ImportMotelsEvent {
  final List<List<String>> data;

  const HandleFileEvent({required this.data});

  @override
  List<Object?> get props => [data];
}

class SaveMotelsEvent extends ImportMotelsEvent {
  final List<Motel> motels;
  const SaveMotelsEvent({required this.motels});

  @override
  List<Object?> get props => [motels];
}

  