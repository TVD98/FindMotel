import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';

abstract class MotelDetailEvent extends Equatable {
  const MotelDetailEvent();

  @override
  List<Object> get props => [];
}

class MotelDetailMotelUpdated extends MotelDetailEvent {
  final Motel motel;
  const MotelDetailMotelUpdated({required this.motel});

  @override
  List<Object> get props => [motel];
}