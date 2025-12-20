import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/home_data.dart';
import 'package:labelsafe_ai/core/mock/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeData _homeData;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual data fetching
    _homeData = HomeData.mock();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  Color _getStatusColor(SafetyBadge rating, bool isDark) {
    switch (rating) {
      case SafetyBadge.safe:
        return isDark ? AppTheme.darkSafe : AppTheme.lightSafe;
      case SafetyBadge.caution:
        return isDark ? AppTheme.darkCaution : AppTheme.lightCaution;
      case SafetyBadge.avoid:
        return isDark ? AppTheme.darkAvoid : AppTheme.lightAvoid;
    }
  }

  String _getStatusText(SafetyBadge rating) {
    switch (rating) {
      case SafetyBadge.safe:
        return "Safe";
      case SafetyBadge.caution:
        return "Caution";
      case SafetyBadge.avoid:
        return "Avoid";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildGreeting(isDark),
                  if (_homeData.isFirstTime) ...[
                    const SizedBox(height: 48),
                    _buildEmptyState(isDark),
                    const SizedBox(height: 32),
                    _buildPrimaryActionButton(context, isDark),
                  ] else ...[
                    const SizedBox(height: 32),
                    _buildDailySummary(isDark),
                    const SizedBox(height: 32),
                    _buildPrimaryActionButton(context, isDark),
                    const SizedBox(height: 32),
                    _buildDivider(isDark),
                    const SizedBox(height: 32),
                    _buildDailyInsight(isDark),
                    const SizedBox(height: 32),
                    _buildFoodSafetyScore(isDark),
                    const SizedBox(height: 32),
                    _buildDivider(isDark),
                    const SizedBox(height: 16),
                    _buildRecentScans(isDark),
                    if (_homeData.showPremiumTease) ...[
                      const SizedBox(height: 32),
                      _buildPremiumTease(isDark),
                    ],
                  ],
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0, top: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.person_outline,
              size: 24,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
            onPressed: () => context.go('/profile'),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
          margin: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
    );
  }

  Widget _buildGreeting(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: AppTheme.bodySmall(isDark),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's review your food choices today",
          style: AppTheme.h1(isDark),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Text(
        "Scan your first food label to get started",
        style: AppTheme.body(isDark).copyWith(
          color:
              isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDailySummary(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TODAY'S FOOD SAFETY",
          style: AppTheme.caption(isDark),
        ),
        const SizedBox(height: 8),
        Text(
          _homeData.dailySummary.status,
          style: AppTheme.h2(isDark),
        ),
        const SizedBox(height: 4),
        Text(
          _homeData.dailySummary.detail,
          style: AppTheme.body(isDark).copyWith(
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context, bool isDark) {
    return _MinimalButton(
      onTap: () {
        // Simple tap - navigate directly to food scan
        context.push('/camera/food');
      },
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Scan Food Label",
              style: AppTheme.bodyLarge(isDark).copyWith(
                color:
                    isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Ingredients • sugar • additives",
              style: AppTheme.bodySmall(isDark).copyWith(
                color: isDark
                    ? AppTheme.darkBackground.withOpacity(0.7)
                    : AppTheme.lightBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
    );
  }

  Widget _buildDailyInsight(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TODAY'S INSIGHT",
          style: AppTheme.caption(isDark),
        ),
        const SizedBox(height: 8),
        Text(
          _homeData.dailyInsight,
          style: AppTheme.body(isDark),
        ),
      ],
    );
  }

  Widget _buildFoodSafetyScore(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "YOUR FOOD SAFETY SCORE",
          style: AppTheme.caption(isDark),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "${_homeData.safetyScore.score}",
              style: AppTheme.score(isDark),
            ),
            const SizedBox(width: 8),
            Text(
              _homeData.safetyScore.trend,
              style: AppTheme.bodySmall(isDark),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _homeData.safetyScore.period,
          style: AppTheme.bodySmall(isDark),
        ),
      ],
    );
  }

  Widget _buildRecentScans(bool isDark) {
    if (_homeData.recentScans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RECENT SCANS",
          style: AppTheme.caption(isDark),
        ),
        const SizedBox(height: 16),
        ..._homeData.recentScans.take(5).map((scan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Navigate to result screen
                  // TODO: Implement navigation with scan data
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        scan.productName,
                        style: AppTheme.body(isDark),
                      ),
                    ),
                    Text(
                      _getStatusText(scan.rating),
                      style: AppTheme.bodySmall(isDark).copyWith(
                        color: _getStatusColor(scan.rating, isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPremiumTease(bool isDark) {
    return InkWell(
      onTap: () {
        // Navigate to subscription screen
        // TODO: Implement premium paywall
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Unlock weekly food safety insights",
            style: AppTheme.body(isDark).copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "→",
            style: AppTheme.body(isDark).copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal button with opacity feedback only (no ripple, no elevation)
class _MinimalButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;
  final Widget child;

  const _MinimalButton({
    required this.onTap,
    required this.isDark,
    required this.child,
  });

  @override
  State<_MinimalButton> createState() => _MinimalButtonState();
}

class _MinimalButtonState extends State<_MinimalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        opacity: _isPressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 64,
          color: widget.isDark
              ? AppTheme.darkTextPrimary
              : AppTheme.lightTextPrimary,
          child: widget.child,
        ),
      ),
    );
  }
}
