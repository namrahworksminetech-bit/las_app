// lib/common_widgets/c_text.dart
import 'package:flutter/material.dart';
import '../core/theme/app_typography.dart';

class CText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final VoidCallback? onTap; // ✅ Add this

  const CText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style ?? AppTypography.body,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.visible,
      textAlign: textAlign,
    );

    if (onTap == null) return textWidget;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: textWidget,
      ),
    );
  }
}
