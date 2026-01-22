import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/subscription_models.dart';
import 'package:labelsafe_ai/core/providers/subscription_providers.dart';
import 'package:labelsafe_ai/core/services/revenuecat_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionAsync = ref.watch(subscriptionStatusProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/profile');
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: Text(
            'SUBSCRIPTION',
            style: AppTheme.h2(isDark).copyWith(
              letterSpacing: -1,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft,
                color: isDark ? AppTheme.darkText : AppTheme.lightText),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: subscriptionAsync.when(
          data: (status) => _buildContent(context, ref, isDark, status),
          loading: () => _buildLoading(isDark),
          error: (e, _) => _buildError(context, ref, isDark, e.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    SubscriptionStatus status,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(context, isDark, status),
          const SizedBox(height: 24),
          if (status.isActive) ...[
            _buildSubscriptionDetails(isDark, status),
            const SizedBox(height: 24),
          ],
          _buildFeaturesComparison(context, isDark, status),
          const SizedBox(height: 24),
          if (!status.isActive)
            _buildUpgradeButton(context, isDark)
          else
            _buildManageButton(context, isDark),
          const SizedBox(height: 16),
          _buildRestoreButton(context, ref, isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    bool isDark,
    SubscriptionStatus status,
  ) {
    final isActive = status.isActive;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color:
            isActive ? null : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : AppTheme.softShadow(isDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isActive ? LucideIcons.crown : LucideIcons.user,
                  size: 28,
                  color: isActive
                      ? Colors.white
                      : (isDark ? AppTheme.darkText : AppTheme.lightText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.tierName.toUpperCase(),
                      style: AppTheme.h3(isDark).copyWith(
                        fontWeight: FontWeight.w900,
                        color: isActive ? Colors.white : null,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.tierDescription,
                      style: AppTheme.body(isDark).copyWith(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.8)
                            : (isDark
                                ? AppTheme.darkTextMuted
                                : AppTheme.lightTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isActive) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: isDark
                        ? AppTheme.darkTextMuted
                        : AppTheme.lightTextMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upgrade to Pro to unlock all features and unlimited scans',
                      style: AppTheme.caption(isDark).copyWith(
                        color: isDark
                            ? AppTheme.darkTextMuted
                            : AppTheme.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSubscriptionDetails(bool isDark, SubscriptionStatus status) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUBSCRIPTION DETAILS',
            style: AppTheme.caption(isDark).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            isDark,
            'Plan',
            status.tierName,
            LucideIcons.package,
          ),
          if (status.productIdentifier != null)
            _buildDetailRow(
              isDark,
              'Product',
              _formatProductId(status.productIdentifier!),
              LucideIcons.tag,
            ),
          if (status.expirationDate != null)
            _buildDetailRow(
              isDark,
              status.willRenew ? 'Renews on' : 'Expires on',
              dateFormat.format(status.expirationDate!),
              LucideIcons.calendar,
            ),
          _buildDetailRow(
            isDark,
            'Auto-renew',
            status.willRenew ? 'Enabled' : 'Disabled',
            LucideIcons.refreshCw,
            valueColor:
                status.willRenew ? AppTheme.safeColor : AppTheme.avoidColor,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailRow(
    bool isDark,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.body(isDark).copyWith(
                color:
                    isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyLarge(isDark).copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatProductId(String productId) {
    if (productId.contains('monthly')) return 'Monthly';
    if (productId.contains('yearly') || productId.contains('annual')) {
      return 'Annual';
    }
    if (productId.contains('lifetime')) return 'Lifetime';
    return productId;
  }

  Widget _buildFeaturesComparison(
    BuildContext context,
    bool isDark,
    SubscriptionStatus status,
  ) {
    final features = [
      _Feature('Scans per day', '3', 'Unlimited', LucideIcons.scan),
      _Feature('History items', '10', 'Unlimited', LucideIcons.history),
      _Feature('Advanced AI analysis', '✗', '✓', LucideIcons.sparkles),
      _Feature('Export data', '✗', '✓', LucideIcons.download),
      _Feature('Priority support', '✗', '✓', LucideIcons.headphones),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAN COMPARISON',
            style: AppTheme.caption(isDark).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'FREE',
                    style: AppTheme.caption(isDark).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PRO',
                      style: AppTheme.caption(isDark).copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Features
          ...features.map((feature) => _buildFeatureComparisonRow(
                isDark,
                feature,
                status.isPremiumOrAbove,
              )),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeatureComparisonRow(
    bool isDark,
    _Feature feature,
    bool isPremium,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            feature.icon,
            size: 16,
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              feature.name,
              style: AppTheme.body(isDark),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                feature.freeValue,
                style: AppTheme.body(isDark).copyWith(
                  color: feature.freeValue == '✗'
                      ? AppTheme.avoidColor
                      : (isDark
                          ? AppTheme.darkTextMuted
                          : AppTheme.lightTextMuted),
                  fontWeight: feature.freeValue == '✓' ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                feature.proValue,
                style: AppTheme.body(isDark).copyWith(
                  color: feature.proValue == '✓'
                      ? AppTheme.safeColor
                      : const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/paywall'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.crown, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'UPGRADE TO PRO',
              style: AppTheme.bodyLarge(isDark).copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildManageButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _openCustomerCenter(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.settings,
              size: 20,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
            const SizedBox(width: 12),
            Text(
              'MANAGE SUBSCRIPTION',
              style: AppTheme.bodyLarge(isDark).copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildRestoreButton(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () => _restorePurchases(context, ref),
        child: Text(
          'Restore Purchases',
          style: AppTheme.body(isDark).copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? Colors.white : AppTheme.lightText,
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: 64,
              color: AppTheme.avoidColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Subscription',
              style: AppTheme.h3(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.body(isDark).copyWith(
                color:
                    isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () =>
                  ref.read(subscriptionStatusProvider.notifier).refresh(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Try Again',
                  style: AppTheme.bodyLarge(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomerCenter(BuildContext context) async {
    try {
      await RevenueCatService().presentCustomerCenter();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open subscription management: $e'),
            backgroundColor: AppTheme.avoidColor,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(purchaseStateProvider.notifier).restorePurchases();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
              result.hasPremium ? AppTheme.safeColor : AppTheme.cautionColor,
        ),
      );
    }
  }
}

class _Feature {
  final String name;
  final String freeValue;
  final String proValue;
  final IconData icon;

  _Feature(this.name, this.freeValue, this.proValue, this.icon);
}
