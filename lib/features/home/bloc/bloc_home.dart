import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/utils/enums.dart';

part 'event_home.dart';
part 'state_home.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState(routeList: [EmPage.dashboard])) {
    on<OnClickBack>(_onBackEvent);
    on<OnClickTab>(_onTabEvent);
  }

  _onBackEvent(OnClickBack event, Emitter<HomeState> emit) {
    if (state.page != EmPage.dashboard) {
      state.routeList.removeWhere((e) => e == state.page);
    }
    emit(state.copyWith(page: state.routeList.last));
  }

  _onTabEvent(OnClickTab event, Emitter<HomeState> emit) {
    if (event.page != EmPage.dashboard && state.page != event.page) {
      state.routeList.add(event.page);
    }
    emit(state.copyWith(page: event.page));
  }
}
