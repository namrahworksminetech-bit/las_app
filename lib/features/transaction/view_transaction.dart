import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/utils/assets.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/enums.dart';
import 'bloc/bloc_transaction.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  TransactionBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(),
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          bloc = context.read<TransactionBloc>();
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
    return Column(children: []);
  }
}
