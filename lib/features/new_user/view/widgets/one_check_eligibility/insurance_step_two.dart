import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/insurance_success_screen.dart';
import 'package:las_app/features/home/view_home.dart';

class StepInsuranceUploadPage extends StatelessWidget {
  const StepInsuranceUploadPage({super.key});

  /// Exit dialog (same structure as other pages)
  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Exit to Home?"),
        content: const Text("If you leave, uploaded documents will be lost.\nContinue?"),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx,false), child: const Text("Cancel")),
          TextButton(onPressed: ()=> Navigator.pop(ctx,true), child: const Text("Confirm")),
        ],
      ),
    ) ?? false;
  }

  void _goHome(BuildContext context) {
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
        bool exit = await _showExitDialog(context);
        if (exit) _goHome(context);
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
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CText("Upload Documents",
                      style: const TextStyle(fontSize: 12, color: Colors.white)),
                  const SizedBox(height: 18),

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

                  if (state.isUploadingPolicy || state.isUploadingUnit)
                    _uploadingLabel("Uploading document..."),

                  const Spacer(),

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
        ),
      ),
    );
  }

  Widget _uploadingLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: CText(text, style: const TextStyle(color: Colors.orange, fontSize: 12)),
  );
}
