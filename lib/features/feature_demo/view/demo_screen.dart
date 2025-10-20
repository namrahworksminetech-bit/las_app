import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../core/extensions/context_ext.dart';
import '../../common_widgets/c_loader.dart';
import '../../common_widgets/c_text.dart';
import '../bloc/demo_bloc.dart';
import '../bloc/demo_event.dart';
import '../bloc/demo_state.dart';
import '../repository/demo_repository.dart';

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoBloc(DemoRepository())..add(FetchPosts()),
      child: Scaffold(
        appBar: AppBar(title: Text('title'.tr)),
        body: BlocBuilder<DemoBloc, DemoState>(
          builder: (context, state) {
            if (state is DemoLoading) return const CLoader();
            if (state is DemoError)   return Center(child: CText(state.message));
            if (state is DemoLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.posts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final p = state.posts[i];
                  return ListTile(
                    title: Text(p['title'] ?? '', style: context.textTheme.titleMedium),
                    subtitle: Text(p['body'] ?? ''),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
