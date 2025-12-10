part of 'bloc_home.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class OnClickBack extends HomeEvent {
  final EmPage? page;

  const OnClickBack({this.page});

  @override
  List<Object?> get props => [page];
}

class OnClickTab extends HomeEvent {
  final EmPage page;
  const OnClickTab({required this.page});

  @override
  List<Object?> get props => [page];
}
