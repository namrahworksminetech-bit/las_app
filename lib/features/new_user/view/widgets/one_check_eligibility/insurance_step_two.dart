import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';

class StepInsuranceUploadPage extends StatelessWidget {
  const StepInsuranceUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EligibilityBloc, EligibilityState>(
      listener: (context, state) {
        if (state.insuranceSuccess) {
          Navigator.pushNamed(context, "/insuranceSuccess");
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CText("Upload Documents",
                  style: const TextStyle(fontSize: 12, color: Colors.white)),

              const SizedBox(height: 18),

              /// 📄 UNIT STATEMENT UPLOAD
             UploadTile("Unit Statement *", state.unitKey, () async {
  final pick = await FilePicker.platform.pickFiles(withData: true);
  if (pick != null) {
    context.read<EligibilityBloc>().add(
      UploadUnitStatement(
        fileBytes: pick.files.first.bytes!,
        mimeType: "application/${pick.files.first.extension}",
        fileType: pick.files.first.extension!,
      ),
    );
  }
}),
SizedBox(height: 14),

UploadTile("Policy Bond *", state.policyKey, () async {
  final pick = await FilePicker.platform.pickFiles(withData: true);
  if (pick != null) {
    context.read<EligibilityBloc>().add(
      UploadPolicyBond(
        fileBytes: pick.files.first.bytes!,
        mimeType: "application/${pick.files.first.extension}",
        fileType: pick.files.first.extension!,
      ),
    );
  }
}),

              if (state.isUploadingPolicy)
                _uploadingLabel("Uploading Policy Document..."),

              const Spacer(),

              // CButton(
              //   text: state.isSubmittingInsurance ? "Submitting..." : "Confirm & Continue",
              //   onPressed: state.unitKey != null && state.policyKey != null
              //       ? () => context.read<EligibilityBloc>().add(SubmitInsuranceDetails())
              //       : null,
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _uploadingLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: CText(text, style: const TextStyle(color: Colors.orange, fontSize: 12)),
      );
}

