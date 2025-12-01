import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/abcl/bloc/abcl_bloc.dart';
import 'package:las_app/features/abcl/view/concern_page.dart';

class EligibilityDetailsForm extends StatefulWidget {
  const EligibilityDetailsForm({super.key});

  @override
  State<EligibilityDetailsForm> createState() => _EligibilityDetailsFormState();
}

class _EligibilityDetailsFormState extends State<EligibilityDetailsForm> {
  /// Dropdown Options
  final List<String> genderList = ['Male', 'Female', 'Other'];
  final List<String> statusList = ['Single', 'Married', 'Divorced'];
  final List<String> applicationList = ['Individual', 'Business'];
  final List<String> employmentList = ['Salaried', 'Business'];

  /// Text Controllers
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController purposeCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();

  /// Selected Dropdown Values
  String? gender, maritalStatus, applicationType, employmentType;

  /// 🔥 Validate Inputs
  bool _validateForm() {
    if (motherNameCtrl.text.trim().isEmpty) return false;
    if (gender == null) return false;
    if (maritalStatus == null) return false;
    if (applicationType == null) return false;
    if (employmentType == null) return false;
    if (purposeCtrl.text.trim().isEmpty) return false;
    if (addressCtrl.text.trim().isEmpty) return false;
    if (pinCodeCtrl.text.trim().length != 6) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("Eligibility Details", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CInput(labelText: "Mother's Name", controller: motherNameCtrl),
              const SizedBox(height: 18),

              CDropdown(
                label: "Gender",
                items: genderList,
                value: gender,
                onChanged: (v) => setState(() => gender = v),
              ),
              const SizedBox(height: 18),

              CDropdown(
                label: "Marital Status",
                items: statusList,
                value: maritalStatus,
                onChanged: (v) => setState(() => maritalStatus = v),
              ),
              const SizedBox(height: 18),

              CDropdown(
                label: "Application Type",
                items: applicationList,
                value: applicationType,
                onChanged: (v) => setState(() => applicationType = v),
              ),
              const SizedBox(height: 18),

              CDropdown(
                label: "Employment Type",
                items: employmentList,
                value: employmentType,
                onChanged: (v) => setState(() => employmentType = v),
              ),
              const SizedBox(height: 18),

              CInput(labelText: "Purpose of Loan", controller: purposeCtrl),
              const SizedBox(height: 18),

              CInput(labelText: "Address", controller: addressCtrl),
              const SizedBox(height: 18),

              CInput(
                labelText: "Pincode",
                controller: pinCodeCtrl,
                hintText: "6 digit pincode",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 40),

              /// NEXT → Save to Bloc + Navigate
              CButton(
                text: "Next",
                type: ButtonType.primaryWhite,
                suffixIcon: const Icon(Icons.arrow_forward),
               onPressed: () {
  if (!_validateForm()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please complete all fields")),
    );
    return;
  }

  /// Save Form Data
  context.read<AbclBloc>().add(
    AbclSaveFormEvent(
      motherName: motherNameCtrl.text.trim(),
      gender: gender!,
      marital: maritalStatus!,
      applicantType: applicationType!,
      employmentType: employmentType!,
      purpose: purposeCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      pinCode: pinCodeCtrl.text.trim(),
    ),
  );

  /// IMPORTANT FIX 🔥
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<AbclBloc>(),
        child: const ConcernPage(),
      ),
    ),
  );
}),
            ],
          ),
        ),
      ),
    );
  }
}
