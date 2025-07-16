import 'package:equatable/equatable.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';

abstract class HomePageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMotels extends HomePageEvent {
  final MotelsFilter? filter;

  LoadMotels({this.filter});

  @override
  List<Object?> get props => [filter];
}
