import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart';

class CDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const CDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: hasError ? Colors.red : AppColors.bSecondaryColor,
          ),
        ),

        const SizedBox(height: 6),

        /// Dropdown field box
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: hasError ? Colors.red : AppColors.bSecondaryColor,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.black,

              /// 👇 Placeholder when nothing is selected
              hint: const Text(
                "Select",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),

              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),

              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              onChanged: onChanged,
            ),
          ),
        ),

        /// Error text
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
