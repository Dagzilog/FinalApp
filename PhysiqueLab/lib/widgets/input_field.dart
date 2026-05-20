import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';

/// Themed TextFormField wrapper matching the dark PhysiqueLab style.
class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTextStyles.subheading.copyWith(fontSize: 16),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: AppTextStyles.error,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
