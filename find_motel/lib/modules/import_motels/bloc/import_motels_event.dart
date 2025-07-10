import 'package:equatable/equatable.dart';

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
  const SaveMotelsEvent();

  @override
  List<Object?> get props => [];
}

  