import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class TabSelected extends HomeEvent {
  final int index;
  const TabSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadCurrentLocationEvent extends HomeEvent {
  const LoadCurrentLocationEvent();
}

class LoadCatalogEvent extends HomeEvent {
  const LoadCatalogEvent();
}

class LoadUserDataEvent extends HomeEvent {
  const LoadUserDataEvent();
}