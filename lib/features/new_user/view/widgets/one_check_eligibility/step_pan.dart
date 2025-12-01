// step1_pan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/home/view_home.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/eligibility_form.dart';


class Step1PanPage extends StatefulWidget {
  const Step1PanPage({super.key});

  @override
  State<Step1PanPage> createState() => _Step1PanPageState();
}

class _Step1PanPageState extends State<Step1PanPage> {
  late TextEditingController _panController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _otpController;
<<<<<<< HEAD

  final FocusNode _panFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
=======
>>>>>>> 9c76ba7 (changes committed)

  @override
  void initState() {
    super.initState();
    final state = context.read<EligibilityBloc>().state;
    _panController = TextEditingController(text: state.formData.panNumber);
    _nameController = TextEditingController(text: state.formData.panFullName);
    _dobController = TextEditingController(text: state.formData.panDob);
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _otpController.dispose();
<<<<<<< HEAD
    _panFocus.dispose();
    _nameFocus.dispose();
    _dobFocus.dispose();
    _otpFocus.dispose();

=======
>>>>>>> 9c76ba7 (changes committed)
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      _dobController.text = formattedDate;
      context.read<EligibilityBloc>().add(PanDobUpdated(formattedDate));
    }
  }

  void _onButtonPressed(EligibilityState state) {
    FocusManager.instance.primaryFocus?.unfocus();
    final bloc = context.read<EligibilityBloc>();

    // 🔹 Step 1: Verify PAN
    if (state.otpStatus == PanOtpStatus.initial ||
        state.otpStatus == PanOtpStatus.failed) {
      bloc.add(
        VerifyPanPressed(
          pan: _panController.text.trim(),
          dob: _dobController.text.trim(),
          name: _nameController.text.trim(),
          email: 'manish@valuenable.in', // Replace dynamically if needed
        ),
      );
      return;
    }

    // 🔹 Step 2: Verify OTP
    if (state.otpStatus == PanOtpStatus.sent) {
<<<<<<< HEAD
      bloc.add(VerifyPanOtpPressed(otp: _otpController.text.trim()));
      return;
    }

    if (state.otpStatus == PanOtpStatus.verified) {
      bloc.add(FetchStep2Data());
      return;
    }
  }

  /// Go back using JumpToPage + ensure EligibilityScreen visible
  void _onGoBackPressed() {
    final bloc = context.read<EligibilityBloc>();

    // 1) tell bloc to jump to page 0 (mutual funds)
    // remove `const` if your JumpToPage constructor isn't const
    bloc.add(JumpToPage(0));

    // 2) ensure EligibilityScreen is on top (reusing same bloc instance)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => BlocProvider.value(
          value: bloc,
          child: const EligibilityScreen(),
        ),
      ),
    );
  }
Future<bool> _showExitConfirmDialog() async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Exit Application?"),
        content: const Text(
            "Are you sure you want to exit this step and go back to the Dashboard?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
  return res ?? false;
=======
      bloc.add(
        VerifyPanOtpPressed(
          otp: _otpController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EligibilityBloc, EligibilityState>(
      listenWhen: (prev, curr) =>
          curr.snackbarMessage != null && curr.snackbarMessage != prev.snackbarMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.snackbarMessage!)),
        );

        // ✅ Move to next step automatically after OTP verified
        if (state.otpStatus == PanOtpStatus.verified) {
          context.read<EligibilityBloc>().add(NextStepPressed());
        }
      },
      child: BlocBuilder<EligibilityBloc, EligibilityState>(
        builder: (context, state) {
          final showOtpField = state.otpStatus == PanOtpStatus.sent ||
              state.otpStatus == PanOtpStatus.sending ||
              state.otpStatus == PanOtpStatus.verified;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Gaps.xxl),

                      // PAN
                      CInput(
                        labelText: 'panCardNumberLabel'.tr,
                        hintText: 'panCardNumberHint'.tr,
                        controller: _panController,
                        onChanged: (value) => context
                            .read<EligibilityBloc>()
                            .add(PanNumberUpdated(value)),
                        errorText: state.panNumberError,
                      ),

                      SizedBox(height: Gaps.md),

                      // Name
                      CInput(
                        labelText: 'nameAsPerPanLabel'.tr,
                        hintText: 'nameAsPerPanHint'.tr,
                        controller: _nameController,
                        onChanged: (value) => context
                            .read<EligibilityBloc>()
                            .add(PanFullNameUpdated(value)),
                        errorText: state.panFullNameError,
                      ),

                      SizedBox(height: Gaps.md),

                      // DOB
                      CInput(
                        labelText: 'dateOfBirthLabel'.tr,
                        hintText: 'dateOfBirthHint'.tr,
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        errorText: state.panDobError,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.bSecondaryColor,
                          size: 20,
                        ),
                      ),

                      if (showOtpField) ...[
                        SizedBox(height: Gaps.lg),
                        CInput(
                          labelText: 'Enter OTP',
                          hintText: 'Enter the 6-digit code',
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: CButton(
                  text: _getButtonText(state),
                  onPressed: () => _onButtonPressed(state),
                  isLoading: state.panStatus == PanVerificationStatus.verifying ||
                      state.otpStatus == PanOtpStatus.sending,
                  type: ButtonType.primaryWhite,
                  suffixIcon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.black,
                    size: 18,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        'Powered by',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.bSecondaryColor,
                        ),
                      ),
                      SizedBox(width: Gaps.xs),
                      Image.asset(
                        'assets/images/value_enable_logo.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getButtonText(EligibilityState state) {
    switch (state.otpStatus) {
      case PanOtpStatus.sent:
        return 'Verify OTP';
      case PanOtpStatus.verified:
        return 'Verified ✓';
      default:
        return 'Check Loan Eligibility';
    }
  }
>>>>>>> 9c76ba7 (changes committed)
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<EligibilityBloc, EligibilityState>(
      listenWhen: (prev, curr) =>
          curr.snackbarMessage != null &&
          curr.snackbarMessage != prev.snackbarMessage,
      listener: (context, state) {
        // ✅ Show custom snackbar
        if (state.snackbarMessage != null) {
          CSnackBar.show(context, state.snackbarMessage!);
        }

        // ✅ Move to next step automatically after OTP verified
        if (state.otpStatus == PanOtpStatus.verified) {
          context.read<EligibilityBloc>().add(NextStepPressed());
        }
      },
    child: WillPopScope(
  onWillPop: () async {
    final confirm = await _showExitConfirmDialog();
    if (confirm) {
      // Navigate to Dashboard and clear stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    }
    // Return false to prevent default pop (we handled navigation)
    return false;
  },
  child: BlocBuilder<EligibilityBloc, EligibilityState>(
    builder: (context, state) {
          final showOtpField =
              state.otpStatus == PanOtpStatus.sent ||
              state.otpStatus == PanOtpStatus.sending ||
              state.otpStatus == PanOtpStatus.verified;

          return Column(
            children: [
             
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 9.0, 5.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _onGoBackPressed,
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, color: AppColors.white, size: 20),
                          Gaps.wXs,
                          CText(
                            'Go Back',
                            style: AppTypography.bodyWhite.copyWith(
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Gaps.xl),

                      // PAN
                      CInput(
                        labelText: 'panCardNumberLabel'.tr,
                        hintText: 'panCardNumberHint'.tr,
                        controller: _panController,
                        focusNode: _panFocus,
                        enabled: !showOtpField,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => context
                            .read<EligibilityBloc>()
                            .add(PanNumberUpdated(value)),
                        errorText: state.panNumberError,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_nameFocus);
                        },
                      ),

                      SizedBox(height: Gaps.md),

                      // Name
                      CInput(
                        labelText: 'nameAsPerPanLabel'.tr,
                        hintText: 'nameAsPerPanHint'.tr,
                        controller: _nameController,
                        focusNode: _nameFocus,
                        enabled: !showOtpField,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => context
                            .read<EligibilityBloc>()
                            .add(PanFullNameUpdated(value)),
                        errorText: state.panFullNameError,
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_dobFocus);
                        },
                      ),

                      SizedBox(height: Gaps.md),

                      // DOB
                      CInput(
                        labelText: 'dateOfBirthLabel'.tr,
                        hintText: 'dateOfBirthHint'.tr,
                        controller: _dobController,
                        readOnly: true,
                        focusNode: _dobFocus,
                        enabled: !showOtpField,
                        onTap: () => _selectDate(context),
                        errorText: state.panDobError,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.bSecondaryColor,
                          size: 20,
                        ),
                      ),

                      if (showOtpField) ...[
                        SizedBox(height: Gaps.lg),
                        CInput(
                          labelText: 'Enter OTP',
                          hintText: 'Enter the 6-digit code',
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: CButton(
                  text: _getButtonText(state),
                  onPressed: () => _onButtonPressed(state),
                  isLoading:
                      state.panStatus == PanVerificationStatus.verifying ||
                          state.otpStatus == PanOtpStatus.sending,
                  type: ButtonType.primaryWhite,
                  suffixIcon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.black,
                    size: 18,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CText(
                        'Powered by',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.bSecondaryColor,
                        ),
                      ),
                      SizedBox(width: Gaps.xs),
                      Image.asset(
                        'assets/images/value_enable_logo.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  String _getButtonText(EligibilityState state) {
    switch (state.otpStatus) {
      case PanOtpStatus.sent:
        return 'Verify OTP';
      case PanOtpStatus.verified:
        return 'Verified ✓';
      default:
        return 'Check Loan Eligibility';
    }
  }
}