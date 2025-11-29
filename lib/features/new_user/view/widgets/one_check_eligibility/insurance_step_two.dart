import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/insurance_success_screen.dart';
import 'package:las_app/features/new_user/view/succcess_pledge_view.dart';

class StepInsuranceUploadPage extends StatelessWidget {
  const StepInsuranceUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EligibilityBloc, EligibilityState>(
      listener: (context, state) {
        if (state.insuranceSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InsuranceSuccessScreen()),
          );
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

              /// 📄 UNIT
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

              const SizedBox(height: 14),

              /// 📄 POLICY
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

              if (state.isUploadingPolicy ||
                  state.isUploadingUnit)
                _uploadingLabel("Uploading document..."),

              const Spacer(),

              /// 🔥 LOCAL SUBMIT LOADER INDICATOR
              if (state.isSubmittingInsurance)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: CircularProgressIndicator(color: AppColors.bPrimaryColor),
                  ),
                ),
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

