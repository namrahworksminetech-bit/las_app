import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  /// 🔥 Custom text support like you added earlier (name instead of code)
  final String Function(String value)? itemBuilder;

  final String? errorText;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemBuilder,
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

        /// Dropdown container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
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

              hint: Text(
                "Select",
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),

              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),

              items: items.map((val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    itemBuilder != null ? itemBuilder!(val) : val,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          )
      ],
    );
  }
}
