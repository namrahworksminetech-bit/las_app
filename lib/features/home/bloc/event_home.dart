part of 'bloc_home.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class OnClickBack extends DashboardEvent {
  final EmPage? page;

  const OnClickBack({this.page});

  @override
  List<Object?> get props => [page];
}

class OnClickTab extends DashboardEvent {
  final EmPage page;
  const OnClickTab({required this.page});

  @override
  List<Object?> get props => [page];
}
