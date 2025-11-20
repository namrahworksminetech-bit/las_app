import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/utils/enums.dart';

part 'event_dashboard.dart';
part 'state_dashboard.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<OnClickTab>(onTabEvent);
  }

  onTabEvent(OnClickTab event, Emitter<DashboardState> emit) {}
}
