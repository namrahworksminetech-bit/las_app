import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart';

enum ButtonType {
  primary,
  primaryWhite,
  secondary,
  secondaryBlack,
  secondaryGrey,
}

class CButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Widget? suffixIcon;
  final bool isLoading;

  const CButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.suffixIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide side = BorderSide.none;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = AppColors.bPrimaryColor;
        foregroundColor = AppColors.white;
        break;
      case ButtonType.primaryWhite:
        backgroundColor = AppColors.white;
        foregroundColor = AppColors.black;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.white;
        side = const BorderSide(color: AppColors.white, width: 1.5);
        break;
      case ButtonType.secondaryBlack:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.black;
        side = const BorderSide(color: AppColors.black, width: 1.5);
        break;
      case ButtonType.secondaryGrey:
        backgroundColor = AppColors.bSecondaryColor.withOpacity(0.5);
        foregroundColor = AppColors.white;
        break;
    }

    final style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 0,
      side: side,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isLoading)
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2,
                ),
              )
            else
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (suffixIcon != null && !isLoading) ...[
              const SizedBox(width: 8),
              IconTheme(
                data: IconThemeData(color: foregroundColor, size: 18),
                child: suffixIcon!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
