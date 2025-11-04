import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

// Common widgets & themes
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';

// Bloc & repository imports
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

  @override
  void initState() {
    super.initState();
    // Prefilled for testing
    _emailController.text = 'namrah@gmail.com';
    _mobileController.text = '9876543210';
    _otpController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        repository: LoginRepository(ApiClient()),
      ),
      child: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.snackbarMessage != current.snackbarMessage ||
            previous.token != current.token ||
            previous.viewStatus != current.viewStatus,
        listener: (context, state) {
          // ✅ Snackbar
          if (state.snackbarMessage != null &&
              state.snackbarMessage!.isNotEmpty) {
            CSnackBar.show(
              context,
              state.snackbarMessage!,
              isError: state.otpError != null ||
                  state.mobileError != null ||
                  state.snackbarMessage!.contains('Failed') ||
                  state.snackbarMessage!.contains('Invalid') ||
                  state.snackbarMessage!.contains('Forbidden'),
            );
            context.read<LoginBloc>().add(LoginSnackbarCleared());
          }

          // ✅ Navigate after OTP verification success
          if (state.token != null && state.token!.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const EligibilityScreen(),
                ),
              );
            });
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>();
          final bool isOtpView = state.viewStatus == LoginViewStatus.otpSent;

          return Scaffold(
            backgroundColor: AppColors.black,
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CText(
                                'EnterDetailsBelow'.tr,
                                style: AppTypography.h1
                                    .copyWith(color: AppColors.white),
                              ),
                              Gaps.hXxl,

                              /// Email field
                              CInput(
                                labelText: 'EmailAddress'.tr,
                                controller: _emailController,
                            
                                keyboardType: TextInputType.emailAddress,
                                suffixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              Gaps.hXl,

                              /// Mobile field
                              CInput(
                                labelText: 'MobileNumber'.tr,
                                controller: _mobileController,
                                errorText: state.mobileError,
                                keyboardType: TextInputType.phone,
                                prefixText: '+91 ',
                                suffixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              Gaps.hXl,

                              /// OTP field (shown below existing)
                              if (isOtpView)
                                CInput(
                                  labelText: 'EnterOTP'.tr,
                                  controller: _otpController,
                                  errorText: state.otpError,
                                  hintText: '******',
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                ),
                              if (isOtpView) Gaps.hXl,
                            ],
                          ),
                        ),
                      ),

                      /// ---------- Buttons ----------
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
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
                                                const LoginResendOtpPressed());
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
                    ],
                  ),

                  /// ---------- Loader ----------
                  if (state.isLoading)
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
}
