part of 'bloc_dashboard.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class OnClickTab extends DashboardEvent {
  final EmPage? page;
  const OnClickTab({this.page});

  @override
  List<Object?> get props => [page];
}
