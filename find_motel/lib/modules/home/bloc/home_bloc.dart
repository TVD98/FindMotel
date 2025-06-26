import 'package:find_motel/modules/home/bloc/home_event.dart';
import 'package:find_motel/modules/home/bloc/home_state.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  TabBloc() : super(TabState(0)) {
    on<TabEvent>((event, emit) {
      switch (event) {
        case TabEvent.selectHome:
          emit(TabState(0));
          break;
        case TabEvent.selectMap:
          emit(TabState(1));
          break;
        case TabEvent.selectProfile:
          emit(TabState(2));
          break;
      }
    });
  }
}
