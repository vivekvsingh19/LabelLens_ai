import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/subscription_models.dart';
import 'package:labelsafe_ai/core/providers/subscription_providers.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final bool showCloseButton;
  final String? source;

  const PaywallScreen({
    super.key,
    this.showCloseButton = true,
    this.source,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPackageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final packagesAsync = ref.watch(subscriptionPackagesProvider);
    final purchaseState = ref.watch(purchaseStateProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A2E),
                            AppTheme.darkBackground,
                          ]
                        : [
                            const Color(0xFFF0F4FF),
                            AppTheme.lightBackground,
                          ],
                  ),
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(isDark),
                  const SizedBox(height: 32),
                  _buildFeatures(isDark),
                  const SizedBox(height: 32),
                  packagesAsync.when(
                    data: (packages) => _buildPackages(isDark, packages),
                    loading: () => _buildLoadingPackages(isDark),
                    error: (e, _) => _buildErrorState(isDark, e.toString()),
                  ),
                  const SizedBox(height: 24),
                  _buildPurchaseButton(isDark, packagesAsync, purchaseState),
                  const SizedBox(height: 16),
                  _buildRestoreButton(isDark),
                  const SizedBox(height: 24),
                  _buildLegalLinks(isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Close button
            if (widget.showCloseButton)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Premium icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.crown,
            size: 40,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shimmer(duration: 2000.ms, delay: 600.ms),
        const SizedBox(height: 24),
        Text(
          'UPGRADE TO PRO',
          style: AppTheme.h2(isDark).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'Unlock the full power of LabelSafe AI',
          style: AppTheme.body(isDark).copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      ],
    );
  }

  Widget _buildFeatures(bool isDark) {
    final features = [
      _FeatureItem(
        icon: LucideIcons.infinity,
        title: 'Unlimited Scans',
        description: 'Scan as many products as you want',
      ),
      _FeatureItem(
        icon: LucideIcons.sparkles,
        title: 'Advanced AI Analysis',
        description: 'Deeper insights with premium AI models',
      ),
      _FeatureItem(
        icon: LucideIcons.history,
        title: 'Unlimited History',
        description: 'Access your complete scan history',
      ),
      _FeatureItem(
        icon: LucideIcons.download,
        title: 'Export Data',
        description: 'Download and share your analysis reports',
      ),
      _FeatureItem(
        icon: LucideIcons.headphones,
        title: 'Priority Support',
        description: 'Get help faster with dedicated support',
      ),
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
            'PRO FEATURES',
            style: AppTheme.caption(isDark).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 16),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return _buildFeatureRow(isDark, feature)
                .animate()
                .fadeIn(duration: 300.ms, delay: (100 * index).ms)
                .slideX(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(bool isDark, _FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              size: 20,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTheme.bodyLarge(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  feature.description,
                  style: AppTheme.caption(isDark).copyWith(
                    color: isDark
                        ? AppTheme.darkTextMuted
                        : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.check,
            size: 20,
            color: AppTheme.safeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPackages(bool isDark, List<SubscriptionPackage> packages) {
    if (packages.isEmpty) {
      return _buildNoPackagesState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE YOUR PLAN',
          style: AppTheme.caption(isDark).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...packages.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;
          return _buildPackageCard(isDark, package, index)
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 * index).ms)
              .slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildPackageCard(
      bool isDark, SubscriptionPackage package, int index) {
    final isSelected = _selectedPackageIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.premiumShadow(isDark) : null,
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.3),
                  width: 2,
                ),
                color:
                    isSelected ? const Color(0xFFFFD700) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),

            // Package details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPackageTitle(package),
                        style: AppTheme.bodyLarge(isDark).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (package.isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: AppTheme.caption(isDark).copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.billingPeriod,
                    style: AppTheme.caption(isDark).copyWith(
                      color: isDark
                          ? AppTheme.darkTextMuted
                          : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  package.priceString,
                  style: AppTheme.h3(isDark).copyWith(
                    fontWeight: FontWeight.w900,
                    color: isSelected ? const Color(0xFFFFD700) : null,
                  ),
                ),
                if (package.periodUnit == 'year') ...[
                  Text(
                    _getMonthlyEquivalent(package),
                    style: AppTheme.caption(isDark).copyWith(
                      color: isDark
                          ? AppTheme.darkTextMuted
                          : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPackageTitle(SubscriptionPackage package) {
    if (package.periodUnit == 'year') return 'Annual';
    if (package.periodUnit == 'month' && package.periodValue == 1) {
      return 'Monthly';
    }
    if (package.periodUnit == 'lifetime') return 'Lifetime';
    return package.title;
  }

  String _getMonthlyEquivalent(SubscriptionPackage package) {
    final monthlyPrice = package.price / 12;
    return '\$${monthlyPrice.toStringAsFixed(2)}/mo';
  }

  Widget _buildLoadingPackages(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
      ),
    );
  }

  Widget _buildNoPackagesState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppTheme.cautionColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Plans Available',
            style: AppTheme.h3(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load subscription plans. Please try again later.',
            style: AppTheme.body(isDark).copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 48,
            color: AppTheme.avoidColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Plans',
            style: AppTheme.h3(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.body(isDark).copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => ref.refresh(subscriptionPackagesProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    );
  }

  Widget _buildPurchaseButton(
    bool isDark,
    AsyncValue<List<SubscriptionPackage>> packagesAsync,
    PurchaseState purchaseState,
  ) {
    final isLoading = purchaseState.status == PurchaseStatus.loading;

    return packagesAsync.when(
      data: (packages) {
        if (packages.isEmpty) return const SizedBox();

        final selectedPackage = packages[_selectedPackageIndex];

        return GestureDetector(
          onTap: isLoading ? null : () => _handlePurchase(selectedPackage),
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
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      'CONTINUE • ${selectedPackage.priceString}',
                      style: AppTheme.bodyLarge(isDark).copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildRestoreButton(bool isDark) {
    return GestureDetector(
      onTap: _handleRestore,
      child: Text(
        'Restore Purchases',
        style: AppTheme.body(isDark).copyWith(
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildLegalLinks(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _openTerms(),
          child: Text(
            'Terms of Service',
            style: AppTheme.caption(isDark).copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          '  •  ',
          style: AppTheme.caption(isDark).copyWith(
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
        ),
        GestureDetector(
          onTap: () => _openPrivacy(),
          child: Text(
            'Privacy Policy',
            style: AppTheme.caption(isDark).copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase(SubscriptionPackage package) async {
    if (package.rcPackage == null) {
      _showError('Invalid package selected');
      return;
    }

    final success = await ref
        .read(purchaseStateProvider.notifier)
        .purchase(package.rcPackage!);

    if (success && mounted) {
      _showSuccess('Welcome to LabelSafe AI Pro!');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop(true);
    } else {
      final state = ref.read(purchaseStateProvider);
      if (state.status == PurchaseStatus.error) {
        _showError(state.message ?? 'Purchase failed');
      }
    }
  }

  Future<void> _handleRestore() async {
    final result =
        await ref.read(purchaseStateProvider.notifier).restorePurchases();

    if (result.hasPremium && mounted) {
      _showSuccess('Purchases restored successfully!');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.pop(true);
    } else {
      _showError(result.message);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.safeColor,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.avoidColor,
      ),
    );
  }

  void _openTerms() {
    // TODO: Open terms of service URL
  }

  void _openPrivacy() {
    // TODO: Open privacy policy URL
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
