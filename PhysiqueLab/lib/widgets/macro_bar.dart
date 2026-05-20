import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Horizontal stacked bar for protein / fat / carbs split.
class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.proteinPercent,
    required this.fatPercent,
    required this.carbsPercent,
  });

  final double proteinPercent;
  final double fatPercent;
  final double carbsPercent;

  @override
  Widget build(BuildContext context) {
    final total = proteinPercent + fatPercent + carbsPercent;
    if (total <= 0) {
      return const SizedBox(height: 12);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(
              flex: proteinPercent.round().clamp(1, 100),
              child: Container(color: AppColors.macroProtein),
            ),
            Expanded(
              flex: fatPercent.round().clamp(1, 100),
              child: Container(color: AppColors.macroFat),
            ),
            Expanded(
              flex: carbsPercent.round().clamp(1, 100),
              child: Container(color: AppColors.macroCarbs),
            ),
          ],
        ),
      ),
    );
  }
}
