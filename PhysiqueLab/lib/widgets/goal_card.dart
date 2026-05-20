import 'package:flutter/material.dart';

import '../models/goal_type.dart';
import '../utils/constants.dart';

/// Selectable goal card for the 2x2 profile setup grid.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final GoalType goal;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.diagonal3Values(
          isSelected ? 1.02 : 1.0,
          isSelected ? 1.02 : 1.0,
          1.0,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF2A2A2A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              goal.label,
              style: AppTextStyles.subheading.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
