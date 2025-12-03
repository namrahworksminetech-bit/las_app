import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/extensions/string_ext.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/utils/assets.dart';
import 'package:las_app/features/dashboard/model_dashboard.dart';
import 'package:las_app/features/portfolio/model_portfolio.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../dashboard/repository_dashboard.dart';
import 'bloc/bloc_portfolio.dart';
import 'repository_portfolio.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key});

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  PortfolioState? state;
  TextEditingController amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PortfolioBloc(),
      child: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          this.state = state;
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
        children: [
          IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_sharp)),
          Gaps.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CText(
                  'Loan Dashboard',
                  style: AppTypography.regularTxt.copyWith(fontSize: 20),
                ),
                CText(
                  'All your active loans in one place',
                  style: AppTypography.regularTxt.copyWith(
                    fontSize: 12,
                    color: AppColors.white50,
                  ),
                ),
              ],
            ),
          ),
          Ast.svg.ic_add.load(),
        ],
      ),
    );
  }

  Widget bodyLayout() {
    final reqId = GetIt.I<AppStateProvider>().reqId ?? '';
    return SafeArea(
      child: SingleChildScrollView(
        child: FutureBuilder(
          future: DashboardRepository().getDashboard(reqId),
          builder: (context, snapData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBarLayout(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: state?.tabList.length ?? 0,
                          itemBuilder: (context, index) {
                            var v = state?.tabList[index];
                            var isSelected = state?.selectedTab == v?.type;
                            return InkWell(
                              onTap: () {},
                              // onTap: () => context.read<PortfolioBloc>().add(
                              //   OnClickTab(type: v?.type),
                              // ),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: isSelected
                                        ? BorderSide(
                                            color: AppColors.kPrimaryColor,
                                          )
                                        : BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                child: Text(
                                  v?.name ?? '',
                                  style: AppTypography.regularTxt.copyWith(
                                    color: isSelected
                                        ? AppColors.kPrimaryColor
                                        : AppColors.white50,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(width: 12);
                          },
                        ),
                      ),
                      Gaps.hXxl,
                      cardLayout(snapData),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0x75666666)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Increase Limit',
                                  style: AppTypography.regularTxt.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Ast.svg.ic_next.load(),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0x75666666)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'De-Pledge Funds',
                                  style: AppTypography.regularTxt.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Ast.svg.ic_next.load(),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0x75666666)),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Portfolio Overview',
                                  style: AppTypography.regularTxt.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                Ast.svg.ic_next.load(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget cardLayout(AsyncSnapshot<DashboardResult> snapData) {
    var v = snapData.data?.data;
    var progress =
        (double.parse(v?.availableAmount ?? '0') /
        double.parse(v?.availableCreditLimit ?? '0'));
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: AppColors.white),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, // 0deg (bottom → top)
          end: Alignment.topCenter,
          colors: [Colors.black, Colors.black],
        ),
        backgroundBlendMode: BlendMode.overlay,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available to Withdraw',
            style: AppTypography.bodySecondary.copyWith(
              color: Color(0x80EFEFEF),
            ),
          ),
          Gaps.hXs,
          Text(
            '₹${v?.availableAmount?.toIndianFormat() ?? 0}',
            style: AppTypography.semiTxt.copyWith(fontSize: 40),
          ),
          Gaps.hMd,
          Row(
            children: [
              if (progress > 0)
                Expanded(
                  child: LinearProgressIndicator(
                    value: (1 - progress),
                    minHeight: 4,
                    backgroundColor: Color(0x1FFFFFFF),
                    color: AppColors.kPrimaryColor,
                  ),
                ),
              Gaps.wMd,
              Text('₹${v?.availableCreditLimit?.toIndianFormat() ?? 0}'),
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
                    'Lender',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    'Bajaj Finance',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interest Rate',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    '${v?.interestRate ?? 0}%',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Utilised',
                    style: AppTypography.regularTxt.copyWith(
                      fontSize: 12,
                      color: Color(0x80EFEFEF),
                    ),
                  ),
                  Text(
                    '₹${v?.withdrawn ?? 0}',
                    style: AppTypography.semiTxt.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          Gaps.hXxl,
          IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0.0098),
                    Color.fromRGBO(255, 255, 255, 0.14),
                  ],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            return BlocProvider(
                              create: (context) => PortfolioBloc(),
                              child: BlocBuilder<PortfolioBloc, PortfolioState>(
                                builder: (context, state) {
                                  return (state.isTutorial ?? false)
                                      ? paymentLayout(context)
                                      : repayLayout(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Repay Loan', style: AppTypography.regularTxt),
                          SizedBox(width: 8),
                          Ast.svg.ic_repay.load(),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 12, color: Colors.white),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            return withdrawLayout();
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Withdraw', style: AppTypography.regularTxt),
                          SizedBox(width: 8),
                          RotatedBox(
                            quarterTurns: 2,
                            child: Ast.svg.ic_repay.load(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget repayLayout(BuildContext ctx) {
    final reqId = GetIt.I<AppStateProvider>().reqId ?? '';
    return FutureBuilder(
      future: PortfolioRepository().repayment({'reqId': reqId}),
      builder: (context, snapData) {
        var v = (snapData.data?.data?.isNotEmpty ?? false)
            ? (snapData.data?.data?.first ?? RepayModel())
            : RepayModel();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Repay Funds',
                style: AppTypography.semiTxt.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                'Complete your repayment securely through your bank.',
                style: AppTypography.regularTxt.copyWith(
                  color: Color(0xFF666666),
                  fontSize: 14,
                ),
              ),
              Gaps.hMd,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.kPrimaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Container(
                    height: 40,
                    child: Text('Principle Amount'),
                  )
                ]),
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadiusGeometry.circular(4),
              //   ),
              // ),
              Text(
                'Lender Bank Details (Transfer To)',
                style: AppTypography.regularTxt.copyWith(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
              ),
              Gaps.hXs,
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFF2F2F2)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bank Name',
                              style: AppTypography.semiTxt.copyWith(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${v.bankName}',
                              style: AppTypography.regularTxt.copyWith(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(height: 1, color: Color(0xFFE5E5E5)),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Account Number',
                              style: AppTypography.semiTxt.copyWith(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${v.accountNumber}',
                                  style: AppTypography.regularTxt.copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Ast.svg.ic_copy.load(),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(height: 1, color: Color(0xFFE5E5E5)),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'IFSC Code',
                              style: AppTypography.semiTxt.copyWith(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${v.ifscCode}',
                                  style: AppTypography.regularTxt.copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Ast.svg.ic_copy.load(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gaps.hXs,
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () => ctx.read<PortfolioBloc>().add(
                    OnClickPaymentTutorial(isTutorial: true),
                  ),
                  child: Text(
                    'How to Complete Payment?',
                    style: AppTypography.regularTxt.copyWith(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(0, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Back to Portfolio',
                      style: AppTypography.semiTxt.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    Ast.svg.ic_down.load(),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Powered by',
                    style: AppTypography.regularTxt.copyWith(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Ast.svg.ve_logo.load(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget paymentLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.read<PortfolioBloc>().add(
                  OnClickPaymentTutorial(isTutorial: false),
                ),
                child: Ast.svg.ic_back.load(),
              ),
              SizedBox(width: 8),
              Text(
                'How to Complete Payment?',
                style: AppTypography.semiTxt.copyWith(
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            '''1. Log in to your NetBanking or UPI app\n2. Add the given account as a beneficiary\n3. Transfer the pending amount (₹10,19,600)\n4. Your payment will be verified and reflected in your SLiQ account within 2 hours''',
            style: AppTypography.regularTxt.copyWith(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget withdrawLayout() {
    final reqId = GetIt.I<AppStateProvider>().reqId ?? '';
    return BlocProvider(
      create: (context) => PortfolioBloc(),
      child: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          return FutureBuilder(
            future: DashboardRepository().getDashboard(reqId),
            builder: (context, snapData) {
              var v = snapData.data?.data;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw Funds',
                      style: AppTypography.semiTxt.copyWith(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Transfer funds from your available credit limit directly to your registered bank.',
                      style: AppTypography.regularTxt.copyWith(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                    Gaps.hMd,
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFFF9F9F9)),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x20020202),
                            offset: const Offset(0, 4),
                            blurRadius: 48,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Available Balance',
                                    style: AppTypography.semiTxt.copyWith(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${v?.availableAmount?.toIndianFormat() ?? 0}',
                                    style: AppTypography.regularTxt.copyWith(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 52),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Interest Rate',
                                    style: AppTypography.semiTxt.copyWith(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${v?.interestRate}% p.a.',
                                    style: AppTypography.regularTxt.copyWith(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Linked Bank',
                                style: AppTypography.semiTxt.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${v?.clientBankName} (${v?.accountNumber?.maskNumber()})',
                                style: AppTypography.regularTxt.copyWith(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Enter Amount',
                      style: AppTypography.regularTxt.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      onChanged: (value) => context.read<PortfolioBloc>().add(
                        OnChangeAmount(value, v?.availableAmount),
                      ),
                      decoration: InputDecoration(),
                      style: TextStyle(color: Colors.black),
                      // validator: (value) {
                      //   if (double.parse(state.amountCtrl?.text ?? '0') >
                      //       double.parse(v?.availableAmount ?? '0')) {
                      //     return 'Amount is greater than available amount';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 8),
                    Text(
                      'New Available Balance: ₹${(double.parse(v?.availableAmount ?? '0') - double.parse(state.amountCtrl?.text ?? '0')).toString().toIndianFormat()}',
                      style: AppTypography.regularTxt.copyWith(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(0, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () =>
                          context.read<PortfolioBloc>().add(OnClickWithdraw()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Withdraw ₹${state.amountCtrl?.text.toIndianFormat() ?? 0}',
                              style: AppTypography.semiTxt.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Ast.svg.ic_down.load(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by',
                          style: AppTypography.regularTxt.copyWith(
                            color: Color(0xFF666666),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Ast.svg.ve_logo.load(),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
