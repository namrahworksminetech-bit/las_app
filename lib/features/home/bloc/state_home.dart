part of 'bloc_home.dart';

class HomeState extends Equatable {
  EmPage page;

  List<EmPage> routeList;

  HomeState({this.page = EmPage.dashboard, required this.routeList});

  HomeState copyWith({EmPage? page, List<EmPage>? routeList}) {
    return HomeState(
      page: page ?? this.page,
      routeList: routeList ?? this.routeList,
    );
  }

  @override
  List<Object> get props => [page, routeList];
}
