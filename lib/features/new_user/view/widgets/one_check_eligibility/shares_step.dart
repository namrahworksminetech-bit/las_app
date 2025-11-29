// step_shares_details_page.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart'; // 👈 using UploadTile here
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/insurance_success_screen.dart';

class StepSharesDetailsPage extends StatefulWidget {
  const StepSharesDetailsPage({super.key});

  @override
  State<StepSharesDetailsPage> createState() => _StepSharesDetailsPageState();
}

class _StepSharesDetailsPageState extends State<StepSharesDetailsPage> {
  String? broker;
  final dpIdController = TextEditingController();
  String? holdingFile; // to show selected file name in UploadTile

  @override
  void dispose() {
    dpIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EligibilityBloc, EligibilityState>(
      listener: (context, state) {
        /// ❗ Show upload/submit errors
        if (state.shareError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.shareError!)),
          );
        }

        /// 🔥 Success → navigate
        if (state.shareSuccess == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InsuranceSuccessScreen()),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
       
              CDropdown(
                label: "Select Your Broker",
                value: broker,
                items: const ["Zerodha", "Upstox", "Groww", "Angel One"],
                onChanged: (v) => setState(() => broker = v),
              ),

              const SizedBox(height: 18),

    
              CInput(
                labelText: "Depository Participant ID",
                controller: dpIdController,
                hintText: "Enter DP ID",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              /// ================= UPLOAD TILE =================
              UploadTile(
                "Holding Statement *",
                holdingFile, // will show file name or "Select file"
                () async {
                  if (state.isShareUploading) return;

                  final pick = await FilePicker.platform.pickFiles(withData: true);
                  if (pick == null || pick.files.single.bytes == null) return;

                  final file = pick.files.single;
                  final bytes = file.bytes!;
                  final ext = file.extension?.toLowerCase();

                  if (ext == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid file type")),
                    );
                    return;
                  }

                  // You can refine this if backend wants pdf/jpg/docx etc.
                  final mime = "application/$ext";
                  final fileType = ext;

                  // 🔥 Trigger Bloc event to upload
                  context.read<EligibilityBloc>().add(
                        UploadHoldingFile(
                          fileBytes: bytes,
                          mimeType: mime,
                          fileType: fileType,
                        ),
                      );

                  setState(() => holdingFile = file.name);
                },
              ),

              const SizedBox(height: 10),

              /// Show uploaded key/path from backend (S3 key)
              if (state.shareUploadPath != null)
                CText(
                  "Uploaded ✓ (${state.shareUploadPath})",
                  style: AppTypography.caption.copyWith(color: Colors.green),
                ),

              const SizedBox(height: 30),

              /// ================= SUBMIT FORM =================
              CButton(
                text: state.isShareSubmitting ? "Submitting..." : "Next",
                onPressed: state.shareUploadPath != null &&
                        broker != null &&
                        !state.isShareUploading
                    ? () {
                        context.read<EligibilityBloc>().add(
                              SubmitShareDetails(
                                broker: broker!,
                                dpId: dpIdController.text,
                              ),
                            );
                      }
                    : null,
              ),

              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CText(
                      'Powered by',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.bSecondaryColor),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(
                      'assets/images/value_enable_logo.png',
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
