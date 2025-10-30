import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/view/eligibility_form.dart';

import '../../../common_widgets/c_button.dart';
import '../../../common_widgets/c_input.dart';
import '../../../common_widgets/c_snackbar.dart';
import '../bloc/login_bloc.dart';

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
    _emailController.text = 'namrah@gmail.com';
    _otpController.text = '123456';
    _mobileController.text = '1234567789';
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
      create: (context) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.snackbarMessage != null) {
            CSnackBar.show(
              context,
              state.snackbarMessage!,
              isError: state.otpError != null ||
                  state.emailError != null ||
                  state.mobileError != null ||
                  state.snackbarMessage!.contains('Failed'),
            );
            context.read<LoginBloc>().add(LoginSnackbarCleared());
          }

          if (state.snackbarMessage == 'LoginSuccessful!'.tr) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const EligibilityScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isOtpView = state.viewStatus == LoginViewStatus.otpSent;
          return Scaffold(
              resizeToAvoidBottomInset: false,

            backgroundColor: AppColors.black,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.hXl,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Image.asset('assets/images/sliQ.png', height: 50),
                  ),
                  Gaps.hXl,
                  const Divider(
                    thickness: 1.5,
                    color: AppColors.bSecondaryColor,
                  ),
                  Gaps.hXl,
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CText(
                            'EnterDetailsBelow'.tr,
                            style: AppTypography.h1.copyWith(color: AppColors.white),
                          ),
                          Gaps.hXxl,
                          CInput(
                            labelText: 'EmailAddress'.tr,
                            controller: _emailController,
                            errorText: state.emailError,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          Gaps.hXl,
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
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                
                child: Column(
                  
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isOtpView) ...[
                      CButton(
                        text: 'SendOTP'.tr,
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            LoginSendOtpPressed(
                              email: _emailController.text,
                              mobile: _mobileController.text,
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
                      Gaps.hMd,
                      CButton(
                        text: 'login'.tr,
                        onPressed: () {},
                        type: ButtonType.secondary,
                      ),
                    ] else ...[
                      CButton(
                        text: 'Continue'.tr,
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            LoginContinuePressed(otp: _otpController.text),
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
                                    context.read<LoginBloc>().add(
                                      LoginResendOtpPressed(),
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
          );
        },
      ),
    );
  }
}
