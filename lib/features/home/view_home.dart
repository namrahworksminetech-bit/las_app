import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/bottom_navigation.dart';

import '../../core/utils/enums.dart';
import '../dashboard/view_dashboard.dart';
import '../portfolio/view_portfolio.dart';
import '../profile/view_profile.dart';
import '../transaction/view_transaction.dart';
import 'bloc/bloc_home.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          bloc = context.read<HomeBloc>();
          return Scaffold(
            backgroundColor: Colors.black,
            body: bodyLayout(),
            bottomNavigationBar: BottomNavigation(bloc),
          );
        },
      ),
    );
  }

  Widget bodyLayout() {
    return PopScope(
      canPop: bloc?.state.routeList.length == 1,
      onPopInvokedWithResult: (didPop, result) => bloc?.add(OnClickBack()),
      child: switch (bloc?.state.page ?? EmPage.dashboard) {
        EmPage.dashboard => Dashboard(),
        EmPage.transaction => Transaction(),
        EmPage.portfolio => Portfolio(),
        EmPage.profile => Profile(),
      },
    );
  }
}
