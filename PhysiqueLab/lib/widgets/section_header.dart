import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Section label used above grouped dashboard content.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.subheading),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
