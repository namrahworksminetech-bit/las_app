part of 'bloc_dashboard.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class OnClickTab2 extends DashboardEvent {
  final EmPage? page;
  const OnClickTab2({this.page});

  @override
  List<Object?> get props => [page];
}
