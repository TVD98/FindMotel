import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_state.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageState('Welcome to Home Page')) {
    on<HomePageEvent>((event, emit) {
      if (event == HomePageEvent.updateMessage) {
        emit(HomePageState('Hello! You updated the Home Page!'));
      }
    });
  }
}
