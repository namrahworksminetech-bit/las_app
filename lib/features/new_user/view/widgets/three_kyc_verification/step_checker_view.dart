import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/features/dashboard/view_dashboard.dart';
import 'package:las_app/features/home/view_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../core/app_state_provider.dart';
import '../../../kyc_service.dart';
import '../../../../../core/network/api_client.dart';
import '../../../repository/pledge_status_repo.dart';
import '../../../repository/digio_repo.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen>
    with WidgetsBindingObserver {
  Timer? _statusTimer;
  late final PledgeStatusRepository _pledgeRepo;
  late final DigioRepository _digioRepo;
  String? _lastStatus;
  bool _hasStartedKyc = false;
  int? _loadingStepIndex;
  bool _isPolling = false;

  // track whether a KYC WebView is currently open and which step opened it
  bool _isWebViewOpen = false;
  int? _currentOpenStep; // 0-based index of the step whose webview is open

  // ensure we call startKyc for a step only once
  final Set<int> _startedKycSteps = {};

  // guard to ensure penny-drop is not invoked repeatedly in-session
  bool _pennyDropCalled = false;

  // guard to prevent duplicate calls to _callDigioAPI
  bool _digioApiCalled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pledgeRepo = PledgeStatusRepository(GetIt.instance<ApiClient>());
    _digioRepo = DigioRepository(GetIt.instance<ApiClient>());
    _connectWebSocket();
    _checkFirstPledgeStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshStatusOnResume();
    }
  }

  Future<void> _refreshStatusOnResume() async {
    // Reset test mode when resuming from WebView
    // _isTestMode = false;
    await Future.delayed(const Duration(milliseconds: 500));
    _callPledgeMfApi();
    if (!_isPolling) {
      _connectWebSocket();
    }
    _forceUpdateUI();
  }

  // Safely pop the current route by deferring until next frame.
  void _safePop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (Navigator.canPop(context)) Navigator.pop(context);
      } catch (e, st) {
        debugPrint('SafePop failed: $e\n$st');
      }
    });
  }

  /// Safely push the LenderSelectionScreen and update bloc state (defers to next frame).
  void _safePushToLenderSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<EligibilityBloc>();
      try {
        bloc.add(
          const SetLenderSelectionView(LenderSelectionView.fundSelection),
        );
        bloc.add(const JumpToPage(2));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: bloc,
              child: const LenderSelectionScreen(),
            ),
          ),
        );
      } catch (e, st) {
        debugPrint('SafePushToLenderSelection failed: $e\n$st');
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });
  }

  // ---------------------------------------------------------

  void _autoStartKyc() {
    // auto-start step 0 if needed (existing behavior)
    setState(() {
      _loadingStepIndex = 0;
    });
    _startKycForStep(0);
  }

  /// Start KYC flow for a given step index (0..4). Ensures it's only called once per step.
  void _startKycForStep(int stepIndex) {
    if (_startedKycSteps.contains(stepIndex)) {
      debugPrint('startKycForStep($stepIndex) already called — skipping');
      return;
    }

    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    if (reqId == null) {
      debugPrint('Cannot start KYC for step $stepIndex — missing reqId');
      return;
    }

    final List<String> stepNames = [
      "fillBasicInfo".tr,
      "aadharPanVerification".tr,
      "linkAccountMandate".tr,
      "loanAgreementSigning".tr,
      "SetMandate".tr,
    ];

    // mark as started to avoid duplicates
    _startedKycSteps.add(stepIndex);

    // mark webview open state
    setState(() {
      _isWebViewOpen = true;
      _currentOpenStep = stepIndex;
    });

    debugPrint('▶️ Starting KYC for step $stepIndex (${stepNames[stepIndex]})');

    KycRepository.startKyc(
      context,
      lenderCode: "BFL",
      reqId: reqId,
      stepName: stepNames[stepIndex],
      onSuccess: () {
        debugPrint('✅ startKyc onSuccess for step $stepIndex');
        setState(() {
          _loadingStepIndex = null;
        });
      },
      onKycComplete: () {
        debugPrint(
          '📦 onKycComplete for step $stepIndex - clearing state and calling Digio',
        );
        // Reset test mode for real flow
        // _isTestMode = false;
        // clear webview state first
        setState(() {
          _isWebViewOpen = false;
          _currentOpenStep = null;
        });
        // safe pop
        _safePop();
        // refresh status after webview closes
        Future.delayed(const Duration(milliseconds: 1000), () {
          _refreshStatusOnResume();
        });
        // call digio API only if not already called
        if (!_digioApiCalled) {
          _digioApiCalled = true;
          _callDigioAPI();
        }
      },
    );
  }

  void _connectWebSocket() {
    if (!_isPolling) {
      setState(() {
        _isPolling = true;
      });
      _checkWekSocketStatus();
    }
  }

  void _onWebSocketDisconnected() {
    if (mounted && _isPolling) {
      // Reconnect after 3 seconds if disconnected
      Timer(const Duration(seconds: 3), () {
        if (mounted && _isPolling) {
          _checkWekSocketStatus();
        }
      });
    }
  }

  /// centralised logic to decide whether a currently open webview should be closed
  /// and whether to auto-start subsequent KYC steps.
  void _maybeCloseWebViewForStatus(String status) {
    // terminal statuses on which we want to automatically close an open webview
    final closeStatuses = {
      'kyc_done',
      'penny_drop_done',
      'kfs_agreement_done',
      'mandate_done',
      'final_step_done',
      'completed',
    };

    if (!_isWebViewOpen) {
      // even if webview isn't open, we still may need to auto-start next KYC step based on status
      if (status == 'penny_drop_done') {
        // after penny-drop done, start KYC for step index 3 (kfs agreement) once
        _startKycForStep(3);
      } else if (status == 'kfs_agreement_done') {
        // start the final step (index 4) once
        _startKycForStep(4);
      }
      return;
    }

    if (closeStatuses.contains(status)) {
      // clear state now to avoid multiple nav attempts
      setState(() {
        _isWebViewOpen = false;
        _currentOpenStep = null;
      });

      debugPrint('🔔 Scheduling automatic WebView close for status: $status');

      // close open webview safely and navigate back to app
      _safePop();

      // After certain statuses we also want to auto-start the next step:
      if (status == 'penny_drop_done') {
        _startKycForStep(3);
      } else if (status == 'kfs_agreement_done') {
        _startKycForStep(4);
      }
    }
  }

  Future<void> _checkWekSocketStatus() async {
    if (!mounted || !_isPolling) return;

    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) return;

    final result = await _pledgeRepo.checkSocketStatus(
      reqId: reqId,
      authToken: token,
    );

    result.when(
      success: (data) {
        if (mounted) {
          final String? status;

          if (data['status'] != null) {
            status = data['status'] as String?;
          } else {
            final statusData = data['data']?['status'];
            if (statusData is String) {
              status = statusData;
            } else if (statusData is List && statusData.isNotEmpty) {
              status = statusData.first as String?;
            } else {
              status = null;
            }
          }

          if (status != null && status != _lastStatus) {
            _lastStatus = status;

            // Call pledge-mf API when socket value updates
            _callPledgeMfApi();

            _updateStepsBasedOnStatus(status);

            // This will close webview when needed AND auto-start subsequent steps where appropriate
            _maybeCloseWebViewForStatus(status);

            // Only call Digio API when KYC is actually completed (status == kyc_done)
            if (status == 'kyc_done') {
              _statusTimer?.cancel();
              setState(() {
                _isPolling = false;
              });
              if (_isWebViewOpen) {
                setState(() {
                  _isWebViewOpen = false;
                  _currentOpenStep = null;
                });
                _safePop();
              }
              // Force UI update for kyc_done status

              // call digio API only if not already called
              if (!_digioApiCalled) {
                _digioApiCalled = true;
                _callDigioAPI();
              }
            }

            // For the final 'completed' status: ensure webview closed and stop polling
            if (status == 'completed') {
              // mark steps completed & stop polling
              _statusTimer?.cancel();
              setState(() {
                _isPolling = false;
                _loadingStepIndex = null; // Clear loader
              });

              if (_isWebViewOpen) {
                setState(() {
                  _isWebViewOpen = false;
                  _currentOpenStep = null;
                });
                _safePop();
              }
            }
          }
        }
      },
      failure: (error) {
        print('❌ WebSocket connection failed: $error');
        _onWebSocketDisconnected();
      },
    );
  }

  Future<void> _checkFirstPledgeStatus() async {
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) return;

    final result = await _pledgeRepo.checkPledgeMfStatus(
      reqId: reqId,
      authToken: token,
    );

    result.when(
      success: (data) {
        if (mounted) {
          final statusData = data['data']?['status'];
          final String? status;

          if (statusData is String) {
            status = statusData;
          } else if (statusData is List && statusData.isNotEmpty) {
            status = statusData.first as String?;
          } else {
            status = null;
          }

          if (status != null && status != _lastStatus) {
            print('📊 Status changed: $_lastStatus → $status');
            _lastStatus = status;

            _updateStepsBasedOnStatus(status);
            // _updateStepsBasedOnStatus('kyc_done');

            final completedStatuses = [
              'kyc_done',
              'mandate_done',
              'penny_drop_done',
              'kfs_agreement_done',
              'final_step_done',
            ];
            if (!completedStatuses.contains(status)) {
              _autoStartKyc();
            }

            // If status is already penny_drop_done when screen opens, auto start step 3
            if (status == 'penny_drop_done') {
              setState(() {
                _loadingStepIndex = 3;
              });
              _startKycForStep(3);
            }

            // Ensure we close any webview if first fetched status is already past a step
            // _maybeCloseWebViewForStatus(status);
          }
        }
      },
      failure: (error) {
        print('❌ Error checking pledge status: $error');
      },
    );
  }

  /// Call Digio config and then trigger penny-drop once (if not already called).
  Future<void> _callDigioAPI() async {
    print('🔴 _callDigioAPI method called');
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;

    if (reqId == null) {
      print('❌ Missing reqId for Digio API');
      return;
    }

    // Set callback to hide loader
    DigioRepository.hideLoaderCallback = () {
      setState(() {
        _loadingStepIndex = null;
      });
    };

    print('🚀 Calling get-digio-config API...');
    final result = await _digioRepo.getDigioConfig(
      reqId: reqId,
      context: context,
    );

    result.when(
      success: (data) async {
        print('✅ Digio API called successfully: $data');
        // After Digio config succeeds, attempt penny-drop once.
        await _callPennyDropOnce(reqId);
      },
      failure: (error) {
        print('❌ Digio API error: $error');
      },
    );
  }

  /// Call pledge-mf API when socket value updates
  Future<void> _callPledgeMfApi() async {
    final appState = GetIt.instance<AppStateProvider>();
    final reqId = appState.reqId;
    final token = appState.token;

    if (reqId == null || token == null) {
      print('❌ Missing reqId or token for pledge-mf API');
      return;
    }

    print('🚀 Calling /customer/pledge-mf API...');
    final result = await _pledgeRepo.checkPledgeMfStatus(
      reqId: reqId,
      authToken: token,
    );

    result.when(
      success: (data) {
        print('✅ Pledge-mf API success: $data');
        // Extract status from response and update steps
        final statusData = data['data']?['status'];
        String? status;

        if (statusData is String) {
          status = statusData;
        } else if (statusData is List && statusData.isNotEmpty) {
          status = statusData.first as String?;
        }

        if (status != null) {
          _updateStepsBasedOnStatus(status);
        }
      },
      failure: (error) {
        print('❌ Pledge-mf API error: $error');
      },
    );
  }

  /// Ensure penny-drop update is invoked only once for this reqId.
  Future<void> _callPennyDropOnce(String reqId) async {
    if (_pennyDropCalled) {
      print(
        '🔁 Penny-drop already called in this session for reqId=$reqId -> skipping',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool('pennydrop_called_$reqId') ?? false;
    if (already) {
      print(
        '🔁 Penny-drop already marked in prefs for reqId=$reqId -> skipping',
      );
      _pennyDropCalled = true;
      return;
    }

    final docId = prefs.getString('docId$reqId');
    if (docId == null || docId.isEmpty) {
      print(
        '⚠️ docId not found for reqId=$reqId. Penny-drop cannot be called now.',
      );
      return;
    }

    // mark in-memory to prevent concurrent calls
    _pennyDropCalled = true;

    // Show loader during penny-drop API call
    setState(() {
      _loadingStepIndex = 2; // penny-drop is step 2
    });

    print('▶️ Calling penny-drop update for docId=$docId reqId=$reqId');

    try {
      final result = await _digioRepo.updateKycStatus(
        context,
        docId,
        onWebViewOpen: () {
          setState(() {
            _loadingStepIndex = null;
          });
        },
      );
      result.when(
        success: (link) async {
          print(
            '✅ Penny-drop API success for docId=$docId, response link: $link',
          );
          // Hide loader on success
          setState(() {
            _loadingStepIndex = null;
          });
          // persist success flag so future sessions skip
          await prefs.setBool('pennydrop_called_$reqId', true);
          // After successful penny-drop, auto-start the next KYC step (kfs agreement -> index 3)
          _startKycForStep(3);
        },
        failure: (error) {
          print('❌ Penny-drop API failure: $error');
          // Don't hide loader here - let repository handle it during polling
          // reset in-memory flag to allow retry later
          _pennyDropCalled = false;
        },
      );
    } catch (e, st) {
      print('❌ Exception while calling penny-drop: $e\n$st');
      // Don't hide loader here - let repository handle it
      _pennyDropCalled = false;
    }
  }

  void _updateStepsBasedOnStatus(String? status) {
    if (status == null) return;

    print('📊 Current status: $status');

    List<bool> steps = [false, false, false, false, false];

    switch (status) {
      case 'not_started':
      case 'pan_verified':
      case 'pending':
        // All steps remain false
        break;
      case 'kyc_done':
        steps[0] = true;
        steps[1] = true;
        break;
      case 'penny_drop_done':
        steps[0] = true;
        steps[1] = true;
        steps[2] = true;
        break;
      case 'kfs_agreement_done':
        steps[0] = true;
        steps[1] = true;
        steps[2] = true;
        steps[3] = true;
        break;
      case 'final_step_done':
      case 'completed':
      case 'mandate_done':
        steps = [true, true, true, true, true];
        break;
      default:
        // If backend returns an index or different string, you can parse it here
        break;
    }

    context.read<EligibilityBloc>().add(UpdateKycStepsAll(steps));

    // Force UI update for every status change
    _forceUpdateUI();

    // Clear loading state when all steps are completed
    if (steps.every((step) => step)) {
      _statusTimer?.cancel();
      setState(() {
        _isPolling = false;
        _loadingStepIndex = null; // Clear loader
      });
    }
  }

  void _navigateToNextScreen() {
    _statusTimer?.cancel();
    final bloc = context.read<EligibilityBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: const PledgeFundsOtpScreen(),
            ),
          ),
        );
      } catch (e, st) {
        debugPrint('Safe navigateToNextScreen failed: $e\n$st');
      }
    });
  }

  bool _isStepClickable(int index, List<bool> checks) {
    if (index == 0) return !checks[0];
    return index > 0 && checks[index - 1] && !checks[index];
  }

  bool _isStepVisible(int index, List<bool> checks) {
    if (index == 0) return true;
    return index > 0 && checks[index - 1];
  }

  void _forceUpdateUI() {
    if (mounted) {
      setState(() {
        // Force UI rebuild
      });
    }
  }

  void _handleStepClick(
    BuildContext context,
    EligibilityState state,
    int stepIndex,
  ) async {
    print('💆 Step $stepIndex clicked');

    final checks = state.kycStepChecks;
    final isCompleted = checks.length > stepIndex ? checks[stepIndex] : false;

    // Only clear restriction if step is not completed
    if (!isCompleted) {
      _startedKycSteps.remove(stepIndex);
    }

    setState(() {
      _loadingStepIndex = stepIndex;
    });

    final allowedStatuses = [
      'penny_drop_done',
      'kyc_done',
      'mandate_done',
      'kfs_agreement_done',
      'final_step_done',
    ];

    if (stepIndex == 3) {
      print('🎯 Step 3 clicked - calling _startKycForStep(3)');
      _startKycForStep(3);

      setState(() {
        _loadingStepIndex = 3;
      });
      return;
    }

    // If step 2 logic remains same
    if (stepIndex == 2 && allowedStatuses.contains(_lastStatus)) {
      print(
        '🎯 Step $stepIndex clicked with allowed status - calling Digio API',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      _callDigioAPI();
      if (!_hasStartedKyc) {
        _hasStartedKyc = true;
        _connectWebSocket();
      }
      setState(() {
        _loadingStepIndex = 2;
      });
      return;
    }

    // If final step clicked -> start KYC flow API that returns URL and open it
    if (stepIndex == 4) {
      // Start KYC for final step (index 4)
      _startKycForStep(4);
      setState(() {
        _loadingStepIndex = null;
      });
      return;
    }

    // For step 1 open KYC URL (real flow)
    if (stepIndex == 0 || stepIndex == 1) {
      // _isTestMode = false; // Ensure real flow
      _startKycForStep(stepIndex);
      return;
    }

    setState(() {
      _loadingStepIndex = null;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    setState(() {
      _isPolling = false;
    });
    try {
      _digioRepo.stopPollingWithLoader(context);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // keep your header as-is (3/4)
    final List<String> steps = [
      "fillBasicInfo".tr,
      "aadharPanVerification".tr,
      "linkAccountMandate".tr,
      "loanAgreementSigning".tr,
      "SetMandate".tr,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _statusTimer?.cancel();
        try {
          _digioRepo.stopPollingWithLoader(context);
        } catch (_) {}
        setState(() {
          _isPolling = false;
          _isWebViewOpen = false;
          _currentOpenStep = null;
        });
        _safePushToLenderSelection();
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gaps.hXl,

                    // ===== Progress Indicator ===== (KEPT EXACTLY AS REQUESTED)
                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 35.0,
                          lineWidth: 8.0,
                          percent: 3 / 4.0,
                          center: CText(
                            "3/4",
                            style: AppTypography.bodyWhite.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          progressColor: AppColors.bPrimaryColor,
                          backgroundColor: AppColors.bSecondaryColor,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        Gaps.wMd,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CText(
                              'kycVerification'.tr,
                              style: AppTypography.h2,
                            ),
                            Gaps.hXxs,
                            CText(
                              'nextPledgeFunds'.tr,
                              style: AppTypography.bodySecondary,
                            ),
                          ],
                        ),
                      ],
                    ),

                    Gaps.hXl,
                    const Divider(
                      thickness: 1.5,
                      color: AppColors.bSecondaryColor,
                    ),
                    Gaps.hMd,

                    // ===== Back Button =====
                   GestureDetector(
  onTap: () {
    // stop timers / polling and clear UI flags
    _statusTimer?.cancel();
    try {
      _digioRepo.stopPolling();
    } catch (_) {}
    setState(() {
      _isPolling = false;
      _isWebViewOpen = false;
      _currentOpenStep = null;
      _loadingStepIndex = null;
    });
                    GestureDetector(
                      onTap: () {
                        _statusTimer?.cancel();
                        try {
                          _digioRepo.stopPollingWithLoader(context);
                        } catch (_) {}
                        setState(() {
                          _isPolling = false;
                          _isWebViewOpen = false;
                          _currentOpenStep = null;
                        });

                        // schedule safe push to lender selection
                        _safePushToLenderSelection();
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: AppColors.white,
                            size: 20,
                          ),
                          Gaps.wSm,
                          CText('goBack'.tr, style: AppTypography.bodyWhite),
                        ],
                      ),
                    );

    // navigate to Dashboard and remove previous routes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    });
  },
  child: Row(
    children: [
      const Icon(
        Icons.arrow_back,
        color: AppColors.white,
        size: 20,
      ),
      Gaps.wSm,
      CText('goBack'.tr, style: AppTypography.bodyWhite),
    ],
  ),
),
                    Gaps.hXl,

                    // ===== Header Text =====
                    CText(
                      'verifyDetails'.tr,
                      style: AppTypography.bodyWhite.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Gaps.hXxs,
                    CText('safeSecure'.tr, style: AppTypography.caption),

                    Gaps.hXl,

                    Expanded(
                      child: Stack(
                        children: [
                          BlocBuilder<EligibilityBloc, EligibilityState>(
                            builder: (context, state) {
                              final checks = state.kycStepChecks;
                              print('📝 Current KYC step checks: $checks');

                              return ListView.separated(
                                itemCount: steps.length,
                                separatorBuilder: (_, __) => Gaps.hSm,
                                itemBuilder: (context, index) {
                                  final isChecked = checks.length > index
                                      ? checks[index]
                                      : false;
                                  final isClickable = _isStepClickable(
                                    index,
                                    checks,
                                  );
                                  final isVisible = _isStepVisible(
                                    index,
                                    checks,
                                  );
                                  final isLoading = _loadingStepIndex == index;
                                  // ensure proceed requires exactly 5 true checks (and we guard length)
                                  final allStepsCompleted =
                                      checks.length >= 5 &&
                                      checks.take(5).every((step) => step);
                                  return GestureDetector(
                                    onTap: (!allStepsCompleted && isClickable)
                                        ? () => _handleStepClick(
                                            context,
                                            state,
                                            index,
                                          )
                                        : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isVisible
                                            ? const Color(0xFF1C1C1C)
                                            : const Color(0xFF0F0F0F),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isVisible
                                              ? AppColors.bSecondaryColor
                                                    .withOpacity(0.3)
                                              : AppColors.bSecondaryColor
                                                    .withOpacity(0.1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                height: 22,
                                                width: 22,
                                                decoration: BoxDecoration(
                                                  color: isChecked
                                                      ? AppColors.bPrimaryColor
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  border: Border.all(
                                                    color: isVisible
                                                        ? AppColors
                                                              .bPrimaryColor
                                                        : AppColors
                                                              .bSecondaryColor
                                                              .withOpacity(0.3),
                                                    width: 1.8,
                                                  ),
                                                ),
                                                child: isChecked
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Colors.black,
                                                      )
                                                    : null,
                                              ),
                                              Gaps.wMd,
                                              CText(
                                                steps[index],
                                                style: AppTypography.bodyWhite
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isVisible
                                                          ? AppColors.white
                                                          : AppColors
                                                                .bSecondaryColor
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                          isLoading
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          AppColors
                                                              .bPrimaryColor,
                                                        ),
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: isVisible
                                                      ? AppColors
                                                            .bSecondaryColor
                                                      : AppColors
                                                            .bSecondaryColor
                                                            .withOpacity(0.3),
                                                  size: 14,
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          if (_loadingStepIndex != null)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.bPrimaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ===== Bottom Section =====
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BlocBuilder<EligibilityBloc, EligibilityState>(
                            builder: (context, state) {
                              // require at least 5 checks and all true for proceed
                              final checks = state.kycStepChecks;
                              final allStepsCompleted =
                                  checks.length >= 5 &&
                                  checks.take(5).every((s) => s);

                              return CButton(
                                text: 'proceedToFinalStep'.tr,
                                onPressed: allStepsCompleted
                                    ? () async {
                                        await Future.delayed(
                                          const Duration(milliseconds: 500),
                                        );
                                        _navigateToNextScreen();
                                      }
                                    : null,
                                type: allStepsCompleted
                                    ? ButtonType.primaryWhite
                                    : ButtonType.secondaryGrey,
                                suffixIcon: allStepsCompleted
                                    ? const Icon(
                                        Icons.arrow_forward,
                                        color: AppColors.black,
                                        size: 18,
                                      )
                                    : null,
                              );
                            },
                          ),
                          Gaps.hSm,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CText('Powered by', style: AppTypography.caption),
                              Gaps.wSm,
                              Image.asset(
                                'assets/images/value_enable_logo.png',
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
