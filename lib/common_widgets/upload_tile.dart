import 'package:flutter/material.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_colors.dart';


Widget UploadTile(String title, String? file, Function onTap) {
  bool isSelected = file != null;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: const Color(0xFF1A1A1A),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () => onTap(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bPrimaryColor : Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                CText(
                  isSelected ? "Selected ✓" : "Select File",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
