import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/extensions/string_ext.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/utils/assets.dart';
import 'package:las_app/features/dashboard/model_dashboard.dart';
import 'package:las_app/features/dashboard/repository_dashboard.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'bloc/bloc_dashboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          bloc = context.read<DashboardBloc>();
          return bodyLayout();
        },
      ),
    );
  }

  Widget appBarLayout() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -5.73), // x, y
            blurRadius: 27.52,
            spreadRadius: 0,
          ),
        ],
        border: Border(bottom: BorderSide(color: Color(0x59FFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ast.svg.logo.load(),
              Gaps.wMd,
              CText('Welcome Himanshu'),
            ],
          ),
          Ast.svg.feedback.load(),
        ],
      ),
    );
  }

  Widget bodyLayout() {
    return FutureBuilder(
      future: DashboardRepository().getDashboard('31e05649-154f-11f0-9951-0275dbaa620b'),
      builder: (context, snapData) {
        return Column(
          children: [
            appBarLayout(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  cardLayout(snapData),
                  Gaps.hMd,
                  alertLayout(),
                  // transactionLayout(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget cardLayout(AsyncSnapshot<DashboardResult> snapData) {
    var v = snapData.data?.data;
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.kPrimaryColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(343.76 * math.pi / 180),
          colors: [
            const Color.fromRGBO(255, 102, 0, 0.22),
            const Color.fromRGBO(255, 102, 0, 0.5),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Loan Amount',
            style: AppTypography.bodySecondary.copyWith(
              color: Color(0x80EFEFEF),
            ),
          ),
          Gaps.hXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${v?.availableCreditLimit?.toIndianFormat()}',
                style: AppTypography.semiTxt.copyWith(fontSize: 40),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.navigate_next_sharp),
              ),
            ],
          ),
          Gaps.hXxl,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilized Amount',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    '₹${v?.withdrawn?.toIndianFormat()}',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    '₹${v?.availableAmount?.toIndianFormat()}',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Active Loans',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    '1',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget alertLayout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_sharp),
          Gaps.wMd,
          Expanded(child: Text('Next EMI due in 5 days.')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(4),
              ),
            ),
            onPressed: () {},
            child: Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget transactionLayout() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions'),
            IconButton(onPressed: () {}, icon: SizedBox()),
          ],
        ),
        Gaps.hXs,
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Row(children: [Icon(Icons.arrow_downward_sharp)]),
                    Divider(),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text('Withdrawn to ICICI Bank'),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Gaps.hMd,
          ),
        ),
      ],
    );
  }
}
