import 'package:equatable/equatable.dart';

abstract class DealManagerEvent extends Equatable {
  const DealManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadDealsEvent extends DealManagerEvent {}