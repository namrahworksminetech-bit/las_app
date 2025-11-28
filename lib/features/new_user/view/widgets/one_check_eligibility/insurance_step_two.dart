import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:las_app/common_widgets/c_text.dart';

import 'package:las_app/core/theme/app_colors.dart';


class StepInsuranceUploadPage extends StatefulWidget {
  const StepInsuranceUploadPage({super.key});

  @override
  State<StepInsuranceUploadPage> createState() =>
      _StepInsuranceUploadPageState();
}

class _StepInsuranceUploadPageState extends State<StepInsuranceUploadPage> {
  String? unitFile;
  String? policyBond;

  selectFile(bool isUnit) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (isUnit)
          unitFile = result.files.first.name;
        else
          policyBond = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 SECTION TITLE (same size as dropdown label)
          CText(
            "Upload Documents",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 14),

          /// Upload tiles
          UploadTile("Unit Statement *", unitFile, () => selectFile(true)),
          const SizedBox(height: 16),

          UploadTile("Policy Bond *", policyBond, () => selectFile(false)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

Widget UploadTile(String title, String? file, Function onTap) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: const Color(0xFF1A1A1A),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// 🔥 Title with colored star
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title.replaceAll('*', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (title.contains('*'))
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.bPrimaryColor, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        /// 📤 Select file button with upload icon
        GestureDetector(
          onTap: () => onTap(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.upload_rounded,
                  size: 14,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
                CText(
                  file ?? "Select file",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}
