import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/deal.dart';

abstract class DealManagerEvent extends Equatable {
  const DealManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadDealsEvent extends DealManagerEvent {}

class DealUpdatedEvent extends DealManagerEvent {
  final Deal deal;

  const DealUpdatedEvent(this.deal);

  @override
  List<Object?> get props => [deal];
}