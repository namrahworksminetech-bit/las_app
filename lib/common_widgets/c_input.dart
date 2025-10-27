

import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart'; 

class CInput extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool readOnly;     
  final VoidCallback? onTap; 

  const CInput({
    super.key,
    required this.labelText,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixText,
    this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.readOnly = false, 
    this.onTap,            
  });

  @override
  State<CInput> createState() => _CInputState();
}

class _CInputState extends State<CInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }
@override
  Widget build(BuildContext context) {
    const Color kBorderColor = AppColors.bSecondaryColor; 
    const Color kErrorBorderColor = Colors.red;
    const Color kTextColor = AppColors.white;
    const Color kHintTextColor = AppColors.bSecondaryColor;
    const Color kFocusColor = AppColors.bPrimaryColor; 

    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final Color currentBorderColor = hasError
        ? kErrorBorderColor
        : (_isFocused ? AppColors.borderPrimaryColor : kBorderColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Text(
          widget.labelText,
          style: TextStyle(
            color: hasError ? kErrorBorderColor : (_isFocused ? AppColors.white : kHintTextColor),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: (_isFocused && !hasError)
                ? [
                    BoxShadow(
                      color: kFocusColor.withOpacity(0.5), 
                      spreadRadius: 4.0, 
                      blurRadius: 20.0, 
                      offset: const Offset(0, 4), 
                    )
                  ]
                : [],
          
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.black,
              border: Border.all(
                color: currentBorderColor,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              onChanged: widget.onChanged,
              obscureText: widget.obscureText,
              style: const TextStyle(color: kTextColor, fontSize: 16),
              cursorColor: kFocusColor,
              
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixText: widget.prefixText,
                prefixStyle: const TextStyle(color: kTextColor, fontSize: 16),
                suffixIcon: widget.suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: widget.suffixIcon,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: kHintTextColor),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ),
        
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: kErrorBorderColor, fontSize: 12),
            ),
          ),
      ],
    );
  }
}