import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class Step1PanPage extends StatefulWidget {
  const Step1PanPage({super.key});

  @override
  State<Step1PanPage> createState() => _Step1PanPageState();
}

class _Step1PanPageState extends State<Step1PanPage> {
  late TextEditingController _panController;
  late TextEditingController _nameController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();

    final state = context.read<EligibilityBloc>().state;
    _panController = TextEditingController(text: state.formData.panNumber);
    _nameController = TextEditingController(text: state.formData.panFullName);
    _dobController = TextEditingController(text: state.formData.panDob);
  }

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EligibilityBloc, EligibilityState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Gaps.xxl),

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
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CButton(
                text:
                    state.isLoading ? 'checking'.tr : 'checkLoanEligibility'.tr,
                onPressed: state.isLoading
                    ? () {}
                    : () => context.read<EligibilityBloc>().add(
                          NextStepPressed(),
                        ),
                type: ButtonType.primaryWhite,
                suffixIcon: state.isLoading
                    ? null
                    : const Icon(
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
    );
  }
}
