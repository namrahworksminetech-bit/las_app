import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/repository/lenders_data_repo.dart';
import 'package:las_app/features/new_user/repository/pan_veirfy_repo.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';
import 'package:las_app/features/new_user/view/widgets/four_pledge_funds/pledge_funds_otp_screen.dart';
import 'package:las_app/features/new_user/view/widgets/three_kyc_verification/step_checker_view.dart';
import 'package:las_app/helper_widgets/fetching_overlay.dart';
import '../../../common_widgets/webview_screen.dart';
import '../../../core/network/api_client.dart';
import '../bloc/login_bloc.dart';
import '../repository/login_repository.dart';
import '../../new_user/view/eligibility_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- loading timeout helpers
  Timer? _loadingTimer;
  bool _forceStopLoading =
      false; // when true, UI won't show the loader even if bloc says isLoading

  @override
  void initState() {
    super.initState();

    _emailController.text = '';
    _mobileController.text = '';
    _otpController.text = '';
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(repository: LoginRepository(ApiClient())),
      child: BlocConsumer<LoginBloc, LoginState>(
        // Listen also to isLoading changes so we can start/cancel the timeout timer
        listenWhen: (previous, current) =>
            previous.snackbarMessage != current.snackbarMessage ||
            previous.token != current.token ||
            previous.viewStatus != current.viewStatus ||
            previous.isLoading != current.isLoading,
        listener: (context, state) {
          // ✅ Snackbar messages from bloc
          if (state.snackbarMessage != null &&
              state.snackbarMessage!.isNotEmpty) {
            CSnackBar.show(
              context,
              state.snackbarMessage!,
              isError:
                  state.otpError != null ||
                  state.mobileError != null ||
                  state.snackbarMessage!.contains('Failed') ||
                  state.snackbarMessage!.contains('Invalid') ||
                  state.snackbarMessage!.contains('Forbidden'),
            );
            context.read<LoginBloc>().add(LoginSnackbarCleared());
          }

          // --- Handle loading timeout lifecycle ---
          // If loading started, start timer. If loading stopped, cancel timer and reset flag.
          final bloc = context.read<LoginBloc>();
          if (state.isLoading) {
            // start a 2 minute timer
            _loadingTimer?.cancel();
            _loadingTimer = Timer(const Duration(minutes: 2), () {
              // if still loading after 2 minutes, hide loader locally and show server down
              if (mounted && bloc.state.isLoading) {
                setState(() {
                  _forceStopLoading = true;
                });

                CSnackBar.show(
                  context,
                  'Server down, please try again later',
                  isError: true,
                );
              }
            });
          } else {
            // loading finished — cancel timer and reset force flag (so loader can show next time)
            _loadingTimer?.cancel();
            if (_forceStopLoading) {
              setState(() {
                _forceStopLoading = false;
              });
            }
          }

          // ✅ Navigate after OTP verification success + pledge status check
          if (state.token != null && state.token!.isNotEmpty) {
            final status = state.pledgeStatus;
            final normalStatuses = {'not_started'};

            if (status == 'mf_fetched' || status == 'pan_verified') {
              // Navigate to Eligibility screen and ask it to start fetching immediately
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const EligibilityScreen(startWithMfFetch: true),
                ),
              );
            } else if (status == null || normalStatuses.contains(status)) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const EligibilityScreen(),
                ),
              );

              ///pledge_completed
            } else if (status == 'pledge_completed') {
              // For other advanced statuses go to KYC
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoanSuccessScreen()),
              );
            } else if (<String>[
              'kfs_agreement_done',
              'penny_drop_done',
              'kyc_done',
              'pending', // ✅ moved here
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
            } else if (status == 'mandate_done' || status == 'completed') {
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
            }
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>();
          final bool isOtpView = state.viewStatus == LoginViewStatus.otpSent;
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          /// OTP FILED AUTO SCROLL
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (MediaQuery.of(context).viewInsets.bottom > 0) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return Scaffold(
            backgroundColor: AppColors.black,

            resizeToAvoidBottomInset:
                false, // Prevent buttons from moving with keyboard
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.hXl,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Image.asset(
                          'assets/images/sliQ.png',
                          height: 50,
                        ),
                      ),
                      Gaps.hXl,
                      const Divider(
                        thickness: 1.5,
                        color: AppColors.bSecondaryColor,
                      ),
                      Gaps.hXl,

                      /// ---------- Form Section ----------
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            bottomInset + 150, // ✅ Push content above keyboard
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CText(
                                'EnterDetailsBelow'.tr,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              Gaps.hXxl,

                              /// Email field
                              CInput(
                                labelText: 'EmailAddress'.tr,
                                controller: _emailController,
                                enabled: !isOtpView,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'enterEmail'.tr,
                                suffixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                              Gaps.hXl,

                              /// Mobile field
                              CInput(
                                labelText: 'MobileNumber'.tr,
                                controller: _mobileController,
                                errorText: state.mobileError,
                                hintText: 'enterMobileNumber'.tr,
                                keyboardType: TextInputType.phone,
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(
                                  color: AppColors
                                      .white, // same as your input text color
                                  fontSize: 16,
                                ),
                                enabled: !isOtpView,
                                suffixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                    10,
                                  ), // ✅ Max 10 digits only
                                  FilteringTextInputFormatter
                                      .digitsOnly, // ✅ Only numbers allowed
                                ],
                              ),
                              Gaps.hXl,

                              /// OTP field (shown below existing)
                              if (isOtpView)
                                CInput(
                                  labelText: 'EnterOTP'.tr,
                                  controller: _otpController,
                                  errorText: state.otpError,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  hintText: '******',
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                ),
                              if (isOtpView) Gaps.hXl,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// ---------- Test Buttons ----------
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isOtpView) ...[
                            CButton(
                              text: 'SendOTP'.tr,
                              onPressed: () {
                                bloc.add(
                                  LoginSendOtpPressed(
                                    mobile: _mobileController.text.trim(),
                                  ),
                                );
                              },
                              type: ButtonType.primaryWhite,
                              suffixIcon: const Icon(
                                Icons.arrow_forward,
                                color: AppColors.black,
                                size: 18,
                              ),
                            ),
                          ] else ...[
                            CButton(
                              text: 'Continue'.tr,
                              onPressed: () {
                                if (state.otpRef == null ||
                                    state.otpRef!.isEmpty) {
                                  CSnackBar.show(
                                    context,
                                    'Missing OTP reference. Please resend OTP.',
                                    isError: true,
                                  );
                                  return;
                                }

                                bloc.add(
                                  LoginVerifyOtpPressed(
                                    mobile: _mobileController.text.trim(),
                                    otpRef: state.otpRef!,
                                    otp: _otpController.text.trim(),
                                      email: _emailController.text.trim(),
                                  ),
                                );
                              },
                              type: ButtonType.primaryWhite,
                              suffixIcon: const Icon(
                                Icons.arrow_forward,
                                color: AppColors.black,
                                size: 18,
                              ),
                            ),
                            Gaps.hXl,
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "NoCode?".tr,
                                  style: const TextStyle(
                                    color: AppColors.bSecondaryColor,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'ResendOTP'.tr,
                                      style: const TextStyle(
                                        color: AppColors.bPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          bloc.add(
                                            const LoginResendOtpPressed(),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  /// ---------- Loader ----------
                  // NOTE: we hide the loader if _forceStopLoading == true (timeout occurred)
                  if (state.isLoading && !_forceStopLoading)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.bPrimaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openWebView(String url, BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
      );
    } catch (e) {
      print('Failed to open WebView: $e');
    }
  }
}
