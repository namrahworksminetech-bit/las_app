import 'package:equatable/equatable.dart';
abstract class DemoEvent extends Equatable { @override List<Object?> get props => []; }
class FetchPosts extends DemoEvent {}
