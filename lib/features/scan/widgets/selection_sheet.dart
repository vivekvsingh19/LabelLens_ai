import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CategorySelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightBackground,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.borderRadiusLarge)),
          boxShadow: AppTheme.premiumShadow(isDark),
          border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'SELECT ANALYSIS',
              style: AppTheme.caption(isDark),
            ),
            const SizedBox(height: 32),
            _buildMinimalOption(
              context,
              title: 'Food & Nutrition',
              subtitle: 'Check for additives & processing',
              icon: LucideIcons.apple,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                context.push('/camera/food');
              },
            ),
            const SizedBox(height: 16),
            _buildMinimalOption(
              context,
              title: 'Beauty & Skincare',
              subtitle: 'Analyze ingredients for safety',
              icon: LucideIcons.sparkles,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                context.push('/camera/cosmetic');
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.accentPrimary : Colors.black)
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.accentPrimary : Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge(isDark)
                        .copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.toUpperCase(),
                    style: AppTheme.caption(isDark).copyWith(
                        fontSize: 8,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
