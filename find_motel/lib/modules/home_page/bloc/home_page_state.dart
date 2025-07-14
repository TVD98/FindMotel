import 'package:find_motel/common/models/motel.dart';

abstract class HomePageState {
  const HomePageState();
}

class HomePageInitial extends HomePageState {}

class HomePageLoading extends HomePageState {}

class HomePageLoaded extends HomePageState {
  final List<Motel> motels;
  const HomePageLoaded(this.motels);
}

class HomePageError extends HomePageState {
  final String message;
  const HomePageError(this.message);
}
