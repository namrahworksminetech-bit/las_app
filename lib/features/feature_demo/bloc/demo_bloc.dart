import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/demo_repository.dart';
import 'demo_event.dart';
import 'demo_state.dart';

class DemoBloc extends Bloc<DemoEvent, DemoState> {
  final DemoRepository repo;
  DemoBloc(this.repo) : super(DemoInitial()) {
    on<FetchPosts>((event, emit) async {
      emit(DemoLoading());
      final result = await repo.getPosts();
      result.when(
        success: (data) => emit(DemoLoaded(data)),
        failure: (msg)  => emit(DemoError(msg)),
      );
    });
  }
}
