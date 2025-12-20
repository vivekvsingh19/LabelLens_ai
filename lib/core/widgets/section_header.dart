import 'package:flutter/material.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.caption(isDark).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}
