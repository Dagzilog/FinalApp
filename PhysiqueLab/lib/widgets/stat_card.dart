import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/constants.dart';

/// Reusable metric summary card with optional stagger animation.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.animationIndex = 0,
    this.child,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final int animationIndex;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: accentColor != null
            ? Border.all(color: accentColor!.withValues(alpha: 0.4))
            : null,
      ),
      child: child ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: accentColor ?? AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(title, style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.heading.copyWith(
                  color: accentColor ?? AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.body),
              ],
            ],
          ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.15,
          end: 0,
          duration: 350.ms,
          delay: (50 * animationIndex).ms,
          curve: Curves.easeOut,
        );
  }
}
