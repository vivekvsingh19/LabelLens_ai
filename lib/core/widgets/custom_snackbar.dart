import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final config = _getConfig(type, isDark);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                config.icon,
                color: config.iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.body(isDark).copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: Icon(
                LucideIcons.x,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 18,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: config.borderColor,
            width: 1,
          ),
        ),
        elevation: 8,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static _SnackBarConfig _getConfig(SnackBarType type, bool isDark) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: LucideIcons.checkCircle,
          iconColor: AppTheme.safeColor,
          iconBgColor: AppTheme.safeColor.withValues(alpha: 0.15),
          borderColor: AppTheme.safeColor.withValues(alpha: 0.3),
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: LucideIcons.alertCircle,
          iconColor: AppTheme.avoidColor,
          iconBgColor: AppTheme.avoidColor.withValues(alpha: 0.15),
          borderColor: AppTheme.avoidColor.withValues(alpha: 0.3),
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: LucideIcons.alertTriangle,
          iconColor: AppTheme.cautionColor,
          iconBgColor: AppTheme.cautionColor.withValues(alpha: 0.15),
          borderColor: AppTheme.cautionColor.withValues(alpha: 0.3),
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: LucideIcons.info,
          iconColor: isDark ? Colors.white70 : Colors.black54,
          iconBgColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
          borderColor: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;

  _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
  });
}
