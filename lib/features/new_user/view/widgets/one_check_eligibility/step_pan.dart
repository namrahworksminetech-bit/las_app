// step1_pan_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/app.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/extensions/formatted_date_ext.dart';
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
late TextEditingController _emailController;

  final FocusNode _panFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = context.read<EligibilityBloc>().state;
    _panController = TextEditingController(text: state.formData.panNumber);
    _nameController = TextEditingController(text: state.formData.panFullName);
    _dobController = TextEditingController(text: state.formData.panDob);
    _otpController = TextEditingController();
    _emailController = TextEditingController(text: state.formData.panEmail);

  }

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _otpController.dispose();
    _panFocus.dispose();
    _nameFocus.dispose();
    _dobFocus.dispose();
    _otpFocus.dispose();
_emailController.dispose();

    super.dispose();
  }

  bool _isValidPan(String pan) {
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    return regex.hasMatch(pan.toUpperCase());
  }

Future<void> _selectDate(BuildContext context) async {
  FocusScope.of(context).unfocus();

  final DateTime? picked = await showDatePicker(
    context: context,
    locale: const Locale('en', 'IN'),
    initialDate: DateTime(2000, 1, 1),
    firstDate: DateTime(1920),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    // UI: MM-DD-YYYY
    _dobController.text = picked.toformattedDDMMYYYY;

    // Backend: DD-MM-YYYY
    final backendDate = picked.toBackendDDMMYYYY;

    context.read<EligibilityBloc>().add(
      PanDobUpdated(backendDate), // send backend format
    );
  }
}



  void _onButtonPressed(EligibilityState state) {
    FocusManager.instance.primaryFocus?.unfocus();
    final bloc = context.read<EligibilityBloc>();
    final pan = _panController.text.trim().toUpperCase();
    if (!_isValidPan(pan)) {
      CSnackBar.show(
        context,
        "Please enter a valid PAN number (e.g., ABCDE1234F)",
      );
      return;
    }
    // 🔹 Step 1: Verify PAN
    if (state.otpStatus == PanOtpStatus.initial ||
        state.otpStatus == PanOtpStatus.failed) {
      bloc.add(
        VerifyPanPressed(
          pan: _panController.text.trim(),
           dob: state.formData.panDob ?? "",   
          name: _nameController.text.trim(),
    email: _emailController.text.trim(),           
        ),
      );
      return;
    }

    // 🔹 Step 2: Verify OTP
    if (state.otpStatus == PanOtpStatus.sent) {
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
        builder: (ctx) =>
            BlocProvider.value(value: bloc, child: const EligibilityScreen()),
      ),
    );
  }
String _formatDobForDisplay(String backend) {
  if (!backend.contains("-")) return backend;
  final p = backend.split("-");
  return "${p[2]}/${p[1]}/${p[0]}";  // DD/MM/YYYY
}

  Future<bool> _showExitConfirmDialog() async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit Application?"),
          content: const Text(
            "Are you sure you want to exit this step and go back to the Dashboard?",
             style: TextStyle( color: kIsWeb ? AppColors.black : AppColors.white,),
          ),
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
                  padding: const EdgeInsets.fromLTRB(15.0, 15.0, 5.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _onGoBackPressed,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back,
                              color: AppColors.white,
                              size: 20,
                            ),
                            Gaps.wXs,
                            CText(
                              'Go Back',
                              style: AppTypography.bodyWhite.copyWith(),
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

  inputFormatters: [
    LengthLimitingTextInputFormatter(10),      // 🔥 MAX 10 characters
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), // optional: restrict to PAN-valid chars
  ],

  onChanged: (value) {
    final upper = value.toUpperCase();

    if (_panController.text != upper) {
      final pos = _panController.selection;
      _panController.value = TextEditingValue(
        text: upper,
        selection: pos,
      );
    }

    context.read<EligibilityBloc>().add(PanNumberUpdated(upper));
      getIt<AppStateProvider>().setName(value.trim());
  },

  errorText: state.panLiveError != null &&
          state.panLiveError != "Valid PAN"
      ? state.panLiveError
      : null,
)
,

// small “valid” line below input (if valid)
if (state.panLiveError == "Valid PAN")
  Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Text(
      "✓ Valid PAN",
      style: AppTypography.caption.copyWith(
        color: Colors.green,
        fontWeight: FontWeight.w500,
      ),
    ),
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
                        ),SizedBox(height: Gaps.md),

CInput(
  labelText: "Email Address",
  hintText: "Enter your email",
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  enabled: state.otpStatus == PanOtpStatus.initial ||
          state.otpStatus == PanOtpStatus.failed,
  onChanged: (value) {
    context.read<EligibilityBloc>().add(PanEmailUpdated(value.trim()));
      getIt<AppStateProvider>().setEmail(value.trim());
  },

  errorText: state.panEmailError,
),


                        SizedBox(height: Gaps.md),

                        // DOB
           CInput(
  labelText: 'dateOfBirthLabel'.tr,
  hintText: 'dateOfBirthHint'.tr,
  controller: TextEditingController(
text: _dobController.text, // directly show dd-mm-yyyy

  ),
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
)

,

                 if (showOtpField) ...[
  SizedBox(height: Gaps.lg),

  BlocBuilder<EligibilityBloc, EligibilityState>(
    buildWhen: (prev, curr) => prev.isOtpVisible != curr.isOtpVisible,
    builder: (context, state) {
      return CInput(
        labelText: 'Enter OTP',
        hintText: 'Enter the 6-digit code',
        controller: _otpController,
        keyboardType: TextInputType.number,

        obscureText: !state.isOtpVisible, 

        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.digitsOnly,
        ],

        suffixIcon: GestureDetector(
          onTap: () {
            context.read<EligibilityBloc>().add(ToggleOtpVisibility());
          },
          child: Icon(
            state.isOtpVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.bSecondaryColor,
            size: 20,
          ),
        ),
      );
    },
  ),
],
SizedBox(height: 5,),
BlocBuilder<EligibilityBloc, EligibilityState>(
  buildWhen: (p, c) => p.agreedToTerms != c.agreedToTerms,
  builder: (context, state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: state.agreedToTerms,
            activeColor: AppColors.bPrimaryColor, // your primary color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // BR.cXSmall
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(
              vertical: -4,
              horizontal: -4,
            ),
            onChanged: (val) {
              context.read<EligibilityBloc>().add(
                TermsAgreementToggled(val ?? false),
              );
            },
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<EligibilityBloc>().add(
                  TermsAgreementToggled(!state.agreedToTerms),
                );
              },
              child: Text(
                "I agree with the Terms and Conditions of this app",
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white,
                  height: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
)

                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CButton(
                    text: _getButtonText(state),
                   onPressed: state.agreedToTerms ? () => _onButtonPressed(state) : null,

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
}
