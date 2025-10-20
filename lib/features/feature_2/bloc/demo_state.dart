import 'package:equatable/equatable.dart';

sealed class DemoState extends Equatable { @override List<Object?> get props => []; }
class DemoInitial extends DemoState {}
class DemoLoading extends DemoState {}
class DemoLoaded extends DemoState {
  final List posts;
  DemoLoaded(this.posts);
  @override List<Object?> get props => [posts];
}
class DemoError extends DemoState {
  final String name;
  final String message;
  DemoError(this.message);
  @override List<Object?> get props => [message];
}
