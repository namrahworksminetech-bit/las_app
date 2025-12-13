import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/extensions/string_ext.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/core/results/result.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/utils/assets.dart';
import 'package:las_app/core/utils/enums.dart';
import 'package:las_app/features/dashboard/model_dashboard.dart';
import 'package:las_app/features/dashboard/repository_dashboard.dart';
import 'package:las_app/features/login/repository/cancel_application_repo.dart';
import 'package:las_app/features/login/view/login_screen.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/repository/pledge_status_repo.dart';
import 'package:las_app/features/new_user/view/eligibility_form.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/helper_widgets/auth_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../home/bloc/bloc_home.dart';
import 'bloc/bloc_dashboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardBloc? bloc;
  String? savedName;

  @override
  void initState() {
    super.initState();
    _loadStoredName();
  }

  Future<void> _loadStoredName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedName = prefs.getString("name") ?? prefs.getString("pan_full_name");
    });
  }

  Future<void> _onCancelApplicationPressed(BuildContext context) async {
    // show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final appState = GetIt.I<AppStateProvider>();

      // ensure auth restored if needed
      bool hasTokenInMemory =
          appState.token != null && appState.token!.isNotEmpty;
      bool hasReqIdInMemory =
          appState.reqId != null && appState.reqId!.isNotEmpty;
      if (!hasTokenInMemory || !hasReqIdInMemory) {
        final restored = await AuthService.instance.restoreToAppState();
        if (!restored) {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          CSnackBar.show(
            context,
            'Login required to cancel application.',
            isError: true,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
      }

      final token = appState.token;
      final reqId = appState.reqId;

      if (token == null || token.isEmpty || reqId == null || reqId.isEmpty) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        CSnackBar.show(
          context,
          'Missing application info. Please login and try again.',
          isError: true,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      debugPrint('Calling cancel-application with reqId="$reqId"');

      // Use the repository
      final repo = ApplicationRepository(ApiClient());
      final result = await repo.cancelApplication(
        reqId: reqId,
        authToken: token,
      );

      // close loader
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (result is Success<Map<String, dynamic>>) {
        final Map<String, dynamic> json = result.value;
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('docId$reqId');
        final status = json['status']?.toString().toLowerCase();
        final message =
            json['message']?.toString() ?? 'Application cancelled successfully';

        if (status == 'success') {
          CSnackBar.show(context, message);

          // cleanup local auth
          try {
            await AuthService.instance.clearAuth();
          } catch (e) {
            debugPrint('Warning: failed to clear auth: $e');
          }

          // clear app state
          appState.setToken('');
          appState.setReqId('');
          appState.setMobileNumber('');
          appState.setName('');

          // navigate to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        } else {
          CSnackBar.show(context, message, isError: true);
          return;
        }
      } else if (result is Failure) {
        CSnackBar.show(context, 'Failed to cancel application', isError: true);
        return;
      } else {
        CSnackBar.show(context, 'Unknown response from server', isError: true);
        return;
      }
    } catch (e, st) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      debugPrint('Error in _onCancelApplicationPressed: $e\n$st');
      CSnackBar.show(
        context,
        'Failed to cancel application. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _onContinueApplicationPressed(BuildContext context) async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1) Ensure appState has token + reqId. Try restore from AuthService if needed.
      final appState = GetIt.I<AppStateProvider>();
      bool hasTokenInMemory =
          appState.token != null && appState.token!.isNotEmpty;
      bool hasReqIdInMemory =
          appState.reqId != null && appState.reqId!.isNotEmpty;

      if (!hasTokenInMemory || !hasReqIdInMemory) {
        final restored = await AuthService.instance.restoreToAppState();
        if (!restored) {
          // Close loader & route to login
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          CSnackBar.show(
            context,
            'Login required to continue. Please sign in.',
            isError: true,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
      }

      // At this point appState should have token & reqId
      final token = appState.token!;
      final reqId = appState.reqId!;

      debugPrint(
        'Calling checkPledgeMfStatus with reqId="$reqId" tokenPresent=${token.isNotEmpty}',
      );

      // 2) Call the pledge-status flow (same logic as before)
      final repo = PledgeStatusRepository();
      final Result<Map<String, dynamic>> result = await repo
          .checkPledgeMfStatus(reqId: reqId, authToken: token, type: 'status');

      // Close loader
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      // Local helper: same as your existing extractStatus
      String? extractStatus(Map<String, dynamic> p) {
        try {
          final dataNode = p['data'];
          if (dataNode is Map && dataNode.containsKey('status')) {
            final inner = dataNode['status'];

            if (inner is List) {
              for (var item in inner) {
                if (item == null) continue;
                final s = item.toString().trim();
                if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
              }
              return null;
            }

            if (inner is String) {
              final s = inner.trim();
              if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
              return null;
            }

            if (inner is Map) {
              if (inner['code'] != null) return inner['code'].toString();
              if (inner['value'] != null) return inner['value'].toString();
              return null;
            }
          }

          final msg = p['message']?.toString();
          if (msg != null && msg.isNotEmpty) {
            final lower = msg.toLowerCase();
            if (lower.contains('kyc')) return 'kyc_in_progress';
            if (lower.contains('pending')) return 'pending';
            if (lower.contains('success')) return 'success';
          }

          return null;
        } catch (e, st) {
          debugPrint('extractStatus error: $e\n$st');
          return null;
        }
      }

      if (result is Success<Map<String, dynamic>>) {
        final Map<String, dynamic> payload = result.value;
        final String? status = extractStatus(payload);

        debugPrint('Pledge MF response payload: $payload');
        debugPrint('Derived status: $status (message: ${payload['message']})');

        final normalStatuses = {'not_started'};

        if (status == null || normalStatuses.contains(status)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const EligibilityScreen()),
          );
          return;
        }

        if (status == 'mf_fetched' || status == 'pan_verified') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const EligibilityScreen(startWithMfFetch: true),
            ),
          );
          return;
        }

        if (status == 'pledge_completed') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoanSuccessScreen()),
          );
          return;
        }

        if (<String>[
          'kfs_agreement_done',
          'penny_drop_done',
          'kyc_done',
          'pending',
          'mandate_flow_fail',
          'kyc_in_progress',
        ].contains(status?.trim())) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider(
                  create: (_) => EligibilityBloc(
                    repository: PanRepository(ApiClient()),
                    lenderRepository: LenderRepository(ApiClient()),
                    apiClient: ApiClient(),
                  ),
                  child: KycVerificationScreen(),
                ),
              ),
            );
          });
          return;
        }

        if (status == 'mandate_done' || status == 'completed') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.isCurrent ?? true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (ctx) => BlocProvider(
                    create: (_) => EligibilityBloc(
                      repository: PanRepository(ApiClient()),
                      lenderRepository: LenderRepository(ApiClient()),
                      apiClient: ApiClient(),
                    ),
                    child: PledgeFundsOtpScreen(mobileNumber: ''),
                  ),
                ),
              );
            }
          });
          return;
        }

        CSnackBar.show(
          context,
          'Unexpected status: ${status ?? 'null'}',
          isError: true,
        );
      } else if (result is Failure) {
        CSnackBar.show(
          context,
          'Failed to continue application',
          isError: true,
        );
      } else {
        CSnackBar.show(
          context,
          'Unknown response from pledge API',
          isError: true,
        );
      }
    } catch (e, st) {
      // Ensure loader closed
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      debugPrint('Error in _onContinueApplicationPressed: $e\n$st');
      CSnackBar.show(
        context,
        'Failed to continue application. Please try again.',
        isError: true,
      );
    }
  }

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
      padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
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
              CText(
                "Welcome ${GetIt.instance<AppStateProvider>().name ?? savedName ?? "Guest"}",
              ),
            ],
          ),
          Ast.svg.feedback.load(),
        ],
      ),
    );
  }

  Widget bodyLayout() {
    return FutureBuilder(
      future: DashboardRepository().getDashboard(),
      builder: (context, snapData) {
        var v = snapData.data?.data;
        if (snapData.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
          );
        }
        return Column(
          children: [
            appBarLayout(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  cardLayout(snapData),
                  Gaps.hMd,
                  Row(
                    children: [
                      if ((v?.isContinued != null && v?.isContinued != ''))
                        Expanded(
                          child: CButton(
                            text: "Continue Application",
                            type: ButtonType.primary,
                            onPressed: () =>
                                _onContinueApplicationPressed(context),
                          ),
                        ),
                      SizedBox(width: 12),
                      if (v?.isCancelled != null && v?.isCancelled != '')
                        Expanded(
                          child: CButton(
                            text: "Cancel Application",
                            type: ButtonType.primaryWhite,
                            onPressed: () =>
                                _onCancelApplicationPressed(context),
                          ),
                        ),
                    ],
                  ),

                  Gaps.hMd,

                  // alertLayout(),
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
    debugPrint('Data ::: ${v?.availableCreditLimit}');
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
                '₹${v?.availableCreditLimit?.toIndianFormat() ?? 0}',
                style: AppTypography.semiTxt.copyWith(fontSize: 40),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Color(0x1CFFFFFF)),
                onPressed: () => context.read<HomeBloc>().add(
                  OnClickTab(page: EmPage.portfolio),
                ),
                icon: Icon(Icons.navigate_next_sharp),
              ),
            ],
          ),
          Gaps.hXxl,
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utilized Amt',
                      style: AppTypography.regularTxt.copyWith(
                        fontSize: 12,
                        color: Color(0x80EFEFEF),
                      ),
                    ),
                    Text(
                      '₹${v?.withdrawn.toString().toIndianFormat() ?? 0}',
                      style: AppTypography.semiTxt.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: AppTypography.regularTxt.copyWith(
                        fontSize: 12,
                        color: Color(0x80EFEFEF),
                      ),
                    ),
                    Text(
                      '₹${v?.availableAmount?.toIndianFormat() ?? 0}',
                      style: AppTypography.semiTxt.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget alertLayout() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: AppColors.kPrimaryColor,
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     // child: Row(
  //     //   children: [
  //     //     Icon(Icons.notifications_none_sharp),
  //     //     Gaps.wMd,
  //     //     Expanded(child: Text('Next EMI due in 5 days.')),
  //     //     ElevatedButton(
  //     //       style: ElevatedButton.styleFrom(
  //     //         minimumSize: Size.zero,
  //     //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //     //         shape: RoundedRectangleBorder(
  //     //           borderRadius: BorderRadiusGeometry.circular(4),
  //     //         ),
  //     //       ),
  //     //       onPressed: () {},
  //     //       child: Text('Pay Now'),
  //     //     ),
  //     //   ],
  //     // ),
  //   );
  // }

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
