// step_shares_details_page.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart';
import 'package:las_app/common_widgets/c_drop_down.dart';
import 'package:las_app/common_widgets/c_input.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/common_widgets/upload_tile.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/insurance_success_screen.dart';
import 'package:las_app/features/home/view_home.dart'; // ⬅ Required same as lender screen

class StepSharesDetailsPage extends StatefulWidget {
  const StepSharesDetailsPage({super.key});

  @override
  State<StepSharesDetailsPage> createState() => _StepSharesDetailsPageState();
}

class _StepSharesDetailsPageState extends State<StepSharesDetailsPage> {
  String? broker;
  final dpIdController = TextEditingController();
  String? holdingFile;

  @override
  void dispose() {
    dpIdController.dispose();
    super.dispose();
  }

  Future<bool> _showExitConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Exit to Home?"),
        content: const Text(
          "If you leave this page, entered details will be lost.\nDo you want to continue?"
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx,false), child: const Text("Cancel")),
          TextButton(onPressed: ()=> Navigator.pop(ctx,true), child: const Text("Confirm")),
        ],
      ),
    );
    return result ?? false;
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Home()),
      (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final exit = await _showExitConfirmDialog();
        if (exit) _navigateToDashboard();
        return false; 
      },

      child: Scaffold( 
        backgroundColor: AppColors.black,
        body: BlocConsumer<EligibilityBloc, EligibilityState>(
          listener: (context, state) {
            if (state.shareError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.shareError!)),
              );
            }

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

                  UploadTile(
                    "Holding Statement *",
                    holdingFile,
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

                      context.read<EligibilityBloc>().add(
                        UploadHoldingFile(
                          fileBytes: bytes,
                          mimeType: "application/$ext",
                          fileType: ext,
                        ),
                      );

                      setState(() => holdingFile = file.name);
                    },
                  ),

                  const SizedBox(height: 10),

                  if (state.shareUploadPath != null)
                    CText(
                      "Uploaded ✓ (${state.shareUploadPath})",
                      style: AppTypography.caption.copyWith(color: Colors.green),
                    ),

                  const SizedBox(height: 30),

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
                          style: AppTypography.caption.copyWith(color: AppColors.bSecondaryColor),
                        ),
                        const SizedBox(width: 4),
                        Image.asset('assets/images/value_enable_logo.png', height: 20),
                      ],
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
}
