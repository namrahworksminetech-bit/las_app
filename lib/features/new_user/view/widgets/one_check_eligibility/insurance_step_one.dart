import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/drop_down.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/home/view_home.dart';   // ⬅ EXIT redirection target

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

  String? insurer;
  bool accepted = false;

  @override
  void initState() {
    super.initState();
    context.read<EligibilityBloc>().add(FetchInsurers());
  }

  /// ---------------- EXIT CONFIRM POPUP ----------------
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
          TextButton(onPressed: ()=> Navigator.pop(ctx,false), child: const Text("Cancel")),
          TextButton(onPressed: ()=> Navigator.pop(ctx,true),  child: const Text("Confirm")),
        ],
      ),
    ) ?? false;
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }
  //-------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ⬅ System Back Handling Same as Other Pages
      onWillPop: () async {
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

                  /// ---------------- DROPDOWN ----------------
                  CustomDropdown(
                    label: "Select Your Insurer",
                    value: state.insurerCode != null &&
                           state.insurers.any((e) => e["code"] == state.insurerCode)
                        ? state.insurerCode
                        : null,
                    items: state.insurers.map((e) => e["code"] as String).toList(),
                    itemBuilder: (code) =>
                      state.insurers.firstWhere((e) => e["code"] == code)["name"],
                    onChanged: (code) {
                      if (code == null) return;
                      final selected = state.insurers.firstWhere((e) => e["code"] == code);
    
                      context.read<EligibilityBloc>().add(
                        SaveInsuranceForm(
                          insurerCode: selected["code"],
                          name: nameController.text,
                          dob: dobController.text,
                          policyNumber: policyController.text,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// ---------------- INPUTS ----------------
                  CInput(
                    labelText: "Policy Number",
                    controller: policyController,
                    hintText: "Enter Policy Number",
                  ),

                  const SizedBox(height: 18),

                  CInput(
                    labelText: "Name",
                    controller: nameController,
                    hintText: "Enter Your Name",
                  ),

                  const SizedBox(height: 18),

                  CInput(
                    labelText: "Date of Birth",
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: const Icon(Icons.calendar_today_outlined,
                        color: AppColors.bSecondaryColor, size: 20),
                  ),

                  const SizedBox(height: 20),

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
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  CButton(
                    text: "Next",
                    type: ButtonType.primaryWhite,
                    onPressed:
                      accepted &&
                      state.insurerCode != null &&
                      policyController.text.isNotEmpty &&
                      nameController.text.isNotEmpty &&
                      dobController.text.isNotEmpty
                    ? () {
                        context.read<EligibilityBloc>().add(
                          SaveInsuranceForm(
                            insurerCode: state.insurerCode!,
                            policyNumber: policyController.text,
                            name: nameController.text,
                            dob: dobController.text,
                          ),
                        );

                        context.read<EligibilityBloc>().add(NextStepPressed());
                      }
                    : null,
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
                        Image.asset('assets/images/value_enable_logo.png', height: 20),
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
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
}
