import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
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
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.snackbarMessage != null) {
              CSnackBar.show(
                context,
                state.snackbarMessage!,
                isError:
                    state.otpError != null ||
                    state.emailError != null ||
                    state.mobileError != null ||
                    state.snackbarMessage!.contains('Failed'),
              );
              context.read<LoginBloc>().add(LoginSnackbarCleared());
            }
            if (state.snackbarMessage == 'Login Successful!') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const EligibilityScreen(),
                ),
              );
            }
          },

          builder: (context, state) {
            final bool isOtpView = state.viewStatus == LoginViewStatus.otpSent;

            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Image.asset('assets/images/sliQ.png', height: 50),
                  ),

                  const SizedBox(height: 24),

                  const Divider(
                    thickness: 1.5,
                    color: AppColors.bSecondaryColor,
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Details Below',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          CInput(
                            labelText: 'Email Address',
                            controller: _emailController,
                            errorText: state.emailError,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CInput(
                            labelText: 'Mobile Number',
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
                          const SizedBox(height: 24),
                          if (isOtpView)
                            CInput(
                              labelText: 'Enter 6-digit OTP',
                              controller: _otpController,
                              errorText: state.otpError,
                              hintText: '******',
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        if (!isOtpView) ...[
                          CButton(
                            text: 'Send OTP',
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
                          const SizedBox(height: 16),
                          CButton(
                            text: 'Login',
                            onPressed: () {},
                            type: ButtonType.secondary,
                          ),
                        ] else ...[
                          CButton(
                            text: 'Continue',
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
                          const SizedBox(height: 24),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Didn't get the code? ",
                                style: const TextStyle(
                                  color: AppColors.bSecondaryColor,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Resend OTP',
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
