part of 'bloc_home.dart';

class DashboardState extends Equatable {
  EmPage page;

  List<EmPage> routeList;

  DashboardState({this.page = EmPage.dashboard, required this.routeList});

  DashboardState copyWith({EmPage? page, List<EmPage>? routeList}) {
    return DashboardState(
      page: page ?? this.page,
      routeList: routeList ?? this.routeList,
    );
  }

  @override
  List<Object> get props => [page, routeList];
}
