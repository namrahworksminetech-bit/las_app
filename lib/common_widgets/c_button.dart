import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const CButton({super.key, required this.label, this.onPressed, this.loading=false});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2,)) : Text(label),
    );
  }
}
