import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class StepInsuranceDetailsPage extends StatefulWidget {
  const StepInsuranceDetailsPage({super.key});

  @override
  State<StepInsuranceDetailsPage> createState() =>
      _StepInsuranceDetailsPageState();
}

class _StepInsuranceDetailsPageState extends State<StepInsuranceDetailsPage> {
  final policyController = TextEditingController();
  String? insurer;
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Dropdown
                  CDropdown(
                    label: "Select Your Insurer to continue with",
                    value: insurer,
                    items: const [
                      "Max Life Insurance Co. Ltd",
                      "HDFC Life",
                      "ICICI Prudential",
                    ],
                    onChanged: (v) => setState(() => insurer = v),
                  ),
                  const SizedBox(height: 18),

                  /// Policy number input – number keyboard only
                  CInput(
                    labelText: "Policy Number",
                    controller: policyController,
                    hintText: "Enter Policy Number",
                    keyboardType: TextInputType.number,
                  ),

                  const Spacer(),

                  /// Checkbox + text
                  Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.bPrimaryColor,
                        value: accepted,
                        onChanged: (v) => setState(() => accepted = v!),
                      ),
                      Expanded(
                        child: CText(
                          "Life Assured is different than the policyholder",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  CButton(
                    text: "Next",
                    type: ButtonType.primaryWhite,
                    onPressed: (accepted &&
                            insurer != null &&
                            policyController.text.isNotEmpty)
                        ? () => context
                            .read<EligibilityBloc>()
                            .add(NextStepPressed())
                        : null,
                  ),

                  const SizedBox(height: 4),
                   Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CText(
                            'Powered by',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.bSecondaryColor,
                            ),
                          ),
                          Gaps.wXs,
                          Image.asset(
                            'assets/images/value_enable_logo.png',
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                     
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
