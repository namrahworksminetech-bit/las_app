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
import 'package:las_app/features/dashboard/model_dashboard.dart';
import 'package:las_app/features/dashboard/repository_dashboard.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/repository/pledge_status_repo.dart';
import 'package:las_app/features/new_user/view/eligibility_form.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';

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
String? _extractStatusFromPayload(Map<String, dynamic> p) {
  try {
    // 1) Try nested data.status
    final dataNode = p['data'];
    if (dataNode is Map && dataNode.containsKey('status')) {
      final inner = dataNode['status'];

      if (inner is List) {
        for (var item in inner) {
          if (item == null) continue;
          final s = item.toString().trim();
          if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
        }
        // list exists but has no useful values → return null (normal flow)
        return null;
      }

      if (inner is String) {
        final s = inner.trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
        return null; // treat empty string or "null" same as null → normal flow
      }

      if (inner is Map) {
        if (inner['code'] != null) return inner['code'].toString();
        if (inner['value'] != null) return inner['value'].toString();
        return null;
      }
    }

    // 2) Derive from message
    final msg = p['message']?.toString();
    if (msg != null && msg.isNotEmpty) {
      final lower = msg.toLowerCase();
      if (lower.contains('kyc')) return 'kyc_in_progress';
      if (lower.contains('pending')) return 'pending';
      if (lower.contains('success')) return 'success';
    }

    // 3) We DO NOT want to fall back to top-level status for workflow
    // because it is always "success" in your payload — useless for business logic.
    return null; // null means: treat as normal flow
  } catch (e, st) {
    debugPrint('extractStatus error: $e\n$st');
    return null;
  }
}
Future<void> _onContinueApplicationPressed(BuildContext context) async {
  final appState = GetIt.I<AppStateProvider>();
  final reqId = appState.reqId ?? '';
  final authToken = appState.token ?? '';

  // Show a blocking loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final repo = PledgeStatusRepository();
    final Result<Map<String, dynamic>> result = await repo.checkPledgeMfStatus(
      reqId: reqId,
      authToken: authToken,
      type: 'status',
    );

    // Close loader
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    // Local helper: extract status according to rules
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
            return null; // list existed but no useful values -> normal flow
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

        // Message heuristics
        final msg = p['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          final lower = msg.toLowerCase();
          if (lower.contains('kyc')) return 'kyc_in_progress';
          if (lower.contains('pending')) return 'pending';
          if (lower.contains('success')) return 'success';
        }

        return null; // treat as normal flow
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

      final normalStatuses = {'not_started'}; // treat as normal flow when derivedStatus == null or in this set

      // NORMAL FLOW (derivedStatus == null OR normalStatuses)
      if (status == null || normalStatuses.contains(status)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EligibilityScreen()),
        );
        return;
      }

      // MF fetched -> start MF fetch flow (note: removed 'pending' from here)
      if (status == 'mf_fetched') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EligibilityScreen(startWithMfFetch: true)),
        );
        return;
      }

      // Pledge completed -> success screen
      if (status == 'pledge_completed') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoanSuccessScreen()),
        );
        return;
      }

      // Direct-to-KYC statuses -> NO overlay, direct navigate
      // NOTE: include 'pending' here so payload with data.status == ['pending'] goes to KYC
      if (<String>[
        'kfs_agreement_done',
        'penny_drop_done',
        'kyc_done',
        'pending',               // ✅ moved here
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

      // Mandate / OTP flows
      if (status == 'mandate_done' || status == 'completed' ) {
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

      // Unexpected but valid
      CSnackBar.show(context, 'Unexpected status: ${status ?? 'null'}', isError: true);
    } else if (result is Failure) {
      CSnackBar.show(context, 'Failed to continue application', isError: true);
    } else {
      CSnackBar.show(context, 'Unknown response from pledge API', isError: true);
    }
  } catch (e, st) {
    // Ensure loader closed
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();

    debugPrint('Error in _onContinueApplicationPressed: $e\n$st');
    CSnackBar.show(context, 'Failed to continue application. Please try again.', isError: true);
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
    future: DashboardRepository().getDashboard(
      GetIt.I<AppStateProvider>().reqId ?? '',
    ),
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

                
                Row(
  children: [
    Expanded(
      child: CButton(
        text: "Continue Application",
        type: ButtonType.primary,
        onPressed: () => _onContinueApplicationPressed(context),
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: CButton(
        text: "Cancel Application",
        type: ButtonType.secondaryBlack,
        onPressed: () {
          // existing cancel flow
        },
      ),
    ),
  ],
),

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
