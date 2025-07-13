import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/deal.dart';

abstract class DealDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DealDetailStarted extends DealDetailEvent {}

class DealDetailMotelLoaded extends DealDetailEvent {
  final String motelId;

  DealDetailMotelLoaded({required this.motelId});

  @override
  List<Object?> get props => [motelId];
}

class DealDetailEditToggled extends DealDetailEvent {}

class DealDetailCountinueEditing extends DealDetailEvent {}

class DealDetailSaved extends DealDetailEvent {
  final Deal deal;

  DealDetailSaved({required this.deal});

  @override
  List<Object?> get props => [deal];
}
