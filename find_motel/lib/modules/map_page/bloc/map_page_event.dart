import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadCurrentLocationEvent extends MapEvent {
  const LoadCurrentLocationEvent();
}

class FirstLoadMotelsEvent extends MapEvent {
  const FirstLoadMotelsEvent();
}

class FilterMotelsEvent extends MapEvent {
  final MotelsFilter filter;

  const FilterMotelsEvent({required this.filter});

  @override
  List<Object> get props => [filter];
}

class MarkerTapped extends MapEvent {
  final Motel motel;
  const MarkerTapped(this.motel);

  @override
  List<Object> get props => [motel];
}
