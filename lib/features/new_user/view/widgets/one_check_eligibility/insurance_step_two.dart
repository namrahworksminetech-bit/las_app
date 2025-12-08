import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/insurance_success_screen.dart';

class StepInsuranceUploadPage extends StatelessWidget {
  const StepInsuranceUploadPage({super.key});

  @override
  Widget build(BuildContext context) {
 return WillPopScope(
  onWillPop: () async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EligibilityBloc>().add(JumpToPage(1));
    });
    return false;
  },
  child: Scaffold(
    backgroundColor: AppColors.black,
    body: BlocConsumer<EligibilityBloc, EligibilityState>(
      listener: (context, state) {
        if (state.insuranceSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InsuranceSuccessScreen()),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // MAIN SCREEN
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CText("Upload Documents",
                      style: const TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 18),

                  UploadTile("Unit Statement *", state.unitKey, () async {
                    if (state.isUploadingUnit) return;

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

                  UploadTile("Policy Bond *", state.policyKey, () async {
                    if (state.isUploadingPolicy) return;

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

                  const Spacer(),
                ],
              ),
            ),

            // 🔥 FULLSCREEN BLOCKING LOADER — STAYS UNTIL UPLOAD COMPLETES
            if (state.isUploadingUnit || state.isUploadingPolicy)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.bPrimaryColor,
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

  Widget _uploadingLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: CText(
          text,
          style: const TextStyle(color: Colors.orange, fontSize: 12),
        ),
      );
}
