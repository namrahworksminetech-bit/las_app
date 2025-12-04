import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/features/de_pledge/bloc/bloc_de_pledge.dart';
import 'package:provider/provider.dart';

import '../home/view_home.dart';

part 'model_de_pledge.dart';
part 'widget_item_pledge.dart';

class DePledge extends StatefulWidget {
  const DePledge({super.key});

  @override
  State<DePledge> createState() => _DePledgeState();
}

class _DePledgeState extends State<DePledge> {
  DePledgeBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DePledgeBloc(),
      child: BlocBuilder<DePledgeBloc, DePledgeState>(
        builder: (context, state) {
          bloc = context.read<DePledgeBloc>();
          return bodyLayout();
        },
      ),
    );
  }

  Widget bodyLayout() {
    return Column(
      children: [
      ],
    );
  }
}
