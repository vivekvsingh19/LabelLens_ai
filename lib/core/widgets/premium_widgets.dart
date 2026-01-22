import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/providers/subscription_providers.dart';
import 'package:labelsafe_ai/core/services/revenuecat_service.dart';

/// Widget that gates content behind premium subscription
class PremiumGate extends ConsumerWidget {
  final Widget child;
  final Widget? lockedWidget;
  final String? featureId;
  final String? lockedMessage;
  final bool showUpgradeButton;

  const PremiumGate({
    super.key,
    required this.child,
    this.lockedWidget,
    this.featureId,
    this.lockedMessage,
    this.showUpgradeButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = featureId != null
        ? ref.watch(featureAccessProvider(featureId!))
        : ref.watch(hasPremiumAccessProvider);

    if (hasAccess) {
      return child;
    }

    return lockedWidget ?? _buildDefaultLockedWidget(context);
  }

  Widget _buildDefaultLockedWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.2),
                  const Color(0xFFFFA500).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.lock,
              size: 32,
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium Feature',
            style: AppTheme.h3(isDark).copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lockedMessage ?? 'Upgrade to Pro to unlock this feature',
            style: AppTheme.body(isDark).copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
          if (showUpgradeButton) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/paywall'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.crown,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Upgrade',
                      style: AppTheme.bodyLarge(isDark).copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Small badge showing premium status
class PremiumBadge extends ConsumerWidget {
  final bool showIfFree;

  const PremiumBadge({super.key, this.showIfFree = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statusAsync.when(
      data: (status) {
        if (!status.isActive && !showIfFree) return const SizedBox();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: status.isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  )
                : null,
            color: status.isActive ? null : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status.isActive ? LucideIcons.crown : LucideIcons.user,
                size: 12,
                color: status.isActive
                    ? Colors.white
                    : (isDark ? AppTheme.darkText : AppTheme.lightText),
              ),
              const SizedBox(width: 4),
              Text(
                status.tierName.toUpperCase(),
                style: AppTheme.caption(isDark).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: status.isActive
                      ? Colors.white
                      : (isDark ? AppTheme.darkText : AppTheme.lightText),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

/// Banner prompting upgrade for free users
class UpgradeBanner extends ConsumerWidget {
  final String? message;
  final bool dismissible;
  final VoidCallback? onDismiss;

  const UpgradeBanner({
    super.key,
    this.message,
    this.dismissible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statusAsync.when(
      data: (status) {
        if (status.isActive) return const SizedBox();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withValues(alpha: 0.15),
                const Color(0xFFFFA500).withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.crown,
                  size: 20,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Pro',
                      style: AppTheme.bodyLarge(isDark).copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      message ?? 'Unlock unlimited scans & premium features',
                      style: AppTheme.caption(isDark).copyWith(
                        color: isDark
                            ? AppTheme.darkTextMuted
                            : AppTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/paywall'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GO',
                    style: AppTheme.caption(isDark).copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              if (dismissible) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: isDark
                        ? AppTheme.darkTextMuted
                        : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

/// Shows remaining scans for free users
class RemainingScansWidget extends ConsumerWidget {
  const RemainingScansWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final remainingScans = ref.watch(remainingFreeScansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statusAsync.when(
      data: (status) {
        if (status.isPremiumOrAbove) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.infinity, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Unlimited',
                  style: AppTheme.caption(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final color = remainingScans > 1
            ? AppTheme.safeColor
            : remainingScans == 1
                ? AppTheme.cautionColor
                : AppTheme.avoidColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.scan, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                '$remainingScans scans left',
                style: AppTheme.caption(isDark).copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

/// Helper function to show paywall
Future<bool?> showPaywall(BuildContext context, {String? source}) async {
  return await context.push<bool>('/paywall', extra: source);
}

/// Helper function to show RevenueCat native paywall
Future<void> showNativePaywall() async {
  try {
    await RevenueCatService().presentPaywall();
  } catch (e) {
    debugPrint('Failed to show native paywall: $e');
  }
}

/// Helper function to show paywall if user doesn't have premium
Future<void> showPaywallIfNeeded() async {
  try {
    await RevenueCatService().presentPaywallIfNeeded();
  } catch (e) {
    debugPrint('Failed to show paywall: $e');
  }
}
