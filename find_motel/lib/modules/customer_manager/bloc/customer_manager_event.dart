import 'package:equatable/equatable.dart';

abstract class CustomerManagerEvent extends Equatable {
  const CustomerManagerEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomersEvent extends CustomerManagerEvent {
  const LoadCustomersEvent();
}
