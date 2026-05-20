import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// BMI value with color-coded category chip.
class BmiBadge extends StatelessWidget {
  const BmiBadge({
    super.key,
    required this.bmi,
    required this.category,
  });

  final double bmi;
  final String category;

  Color get _categoryColor {
    return switch (category) {
      'Underweight' => AppColors.warning,
      'Normal' => AppColors.success,
      'Overweight' => AppColors.warning,
      _ => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          bmi.toStringAsFixed(1),
          style: AppTextStyles.heading,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _categoryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _categoryColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            category,
            style: AppTextStyles.caption.copyWith(color: _categoryColor),
          ),
        ),
      ],
    );
  }
}
