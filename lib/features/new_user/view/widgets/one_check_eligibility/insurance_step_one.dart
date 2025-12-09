import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_snackbar.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/drop_dwon.dart';
import 'package:las_app/core/extensions/formatted_date_ext.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/home/view_home.dart';

class StepInsuranceDetailsPage extends StatefulWidget {
  const StepInsuranceDetailsPage({super.key});

  @override
  State<StepInsuranceDetailsPage> createState() =>
      _StepInsuranceDetailsPageState();
}

class _StepInsuranceDetailsPageState extends State<StepInsuranceDetailsPage> {
  final policyController = TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
String? backendDob;
  bool accepted = false;

  @override
  void initState() {
    super.initState();
    context.read<EligibilityBloc>().add(FetchInsurers());
  }

  /// Exit Dialog
  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Exit to Home?"),
            content: const Text(
              "If you leave this step, entered details will be lost.\nDo you want to continue?",
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Confirm")),
            ],
          ),
        ) ??
        false;
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final state = context.read<EligibilityBloc>().state;

        if (state.pageIndex != 1) return true;

        bool exit = await _showExitDialog();
        if (exit) _goHome();
        return false;
      },

      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocBuilder<EligibilityBloc, EligibilityState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                CustomDropdown(
  label: "Select Your Insurer",

  value: state.insurerCode,
  items: state.insurers
      .map((e) => e["code"] as String)
      .toSet()            // <-- remove duplicates
      .toList(),

  itemBuilder: (code) {
    final entry = state.insurers.firstWhere((e) => e["code"] == code);
    return entry["name"];
  },

  onChanged: (code) {
    if (code == null) return;

    context.read<EligibilityBloc>().add(
      SaveInsuranceForm(
        insurerCode: code,
        name: nameController.text,
        dob: dobController.text,
        policyNumber: policyController.text,
      ),
    );
  },
),


                  const SizedBox(height: 18),

                  CInput(
                    labelText: "Policy Number",
                    hintText: 'Enter valid policy number',
                    controller: policyController,
                  ),

                  const SizedBox(height: 18),

                  CInput(
                    labelText: "Name",
                    hintText: 'Enter your name',
                    controller: nameController,
                  ),

                  const SizedBox(height: 18),

                  CInput(
                    labelText: "Date of Birth",
                    hintText: "DOB",
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.bSecondaryColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 20),

                

                  const SizedBox(height: 20),

                CButton(
  text: "Next",
  type: ButtonType.primaryWhite,
  onPressed: () {
    final bloc = context.read<EligibilityBloc>();
    final insurer = bloc.state.insurerCode;
    final policy = policyController.text.trim();
    final name = nameController.text.trim();
    final dob = dobController.text.trim();

    if (insurer == null || insurer.isEmpty) {
      CSnackBar.show(context, "Please select an insurer", isError: true);
      return;
    }
    if (policy.isEmpty) {
      CSnackBar.show(context, "Please enter policy number", isError: true);
      return;
    }
    if (name.isEmpty) {
      CSnackBar.show(context, "Please enter your name", isError: true);
      return;
    }
    if (dob.isEmpty) {
      CSnackBar.show(context, "Please select date of birth", isError: true);
      return;
    }

    //  All good — save form and continue
    bloc.add(
      SaveInsuranceForm(
        insurerCode: insurer,
        policyNumber: policy,
        name: name,
        dob: backendDob ?? dob,
      ),
    );

    bloc.add(NextStepPressed());
  },
),

                  const SizedBox(height: 30),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CText('Powered by',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.bSecondaryColor,
                            )),
                        Gaps.wXs,
                        Image.asset('assets/images/value_enable_logo.png',
                            height: 20),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = picked.toformattedDDMMYYYY;
       backendDob= picked.toBackendDDMMYYYY;
    }
  }
}
