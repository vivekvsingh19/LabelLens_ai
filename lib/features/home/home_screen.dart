import 'package:flutter/material.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/home_data.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    _homeData = HomeData.mock();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          _buildBackgroundBloom(isDark),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildMainHeroCard(isDark),
                        const SizedBox(height: 24),
                        _buildQuickActions(isDark),
                        const SizedBox(height: 48),
                        _buildSectionHeader("RECENT ANALYSIS", isDark),
                        const SizedBox(height: 20),
                        _buildModernScansList(isDark),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBloom(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? AppTheme.accentPrimary : const Color(0xFFE0F7FA))
                      .withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -20, end: 20, duration: 4.seconds),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark ? AppTheme.accentSecondary : const Color(0xFFE8EAF6))
                      .withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveX(begin: -30, end: 30, duration: 5.seconds),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HELLO, VIVEK", style: AppTheme.caption(isDark)),
                const SizedBox(height: 4),
                Text("DASHBOARD",
                    style: AppTheme.h2(isDark).copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.accentPrimary : null)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.1)),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                child: Icon(LucideIcons.user,
                    size: 20, color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeroCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.premiumShadow(isDark),
        border: Border.all(
            color: (isDark ? AppTheme.accentPrimary : Colors.black)
                .withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MY SAFETY SCORE",
                  style: AppTheme.caption(isDark)
                      .copyWith(color: isDark ? AppTheme.accentPrimary : null)),
              Icon(LucideIcons.info,
                  size: 16,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_homeData.safetyScore.score}",
                style: AppTheme.score(isDark).copyWith(height: 1),
              ).animate().shimmer(duration: 2.seconds),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text("/100",
                    style: AppTheme.h2(isDark).copyWith(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.2))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: _homeData.safetyScore.score / 100,
              minHeight: 8,
              backgroundColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppTheme.accentPrimary : Colors.black),
            ),
          ).animate().scaleX(duration: 1.seconds, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            "Your safety index improved by 12% this week.",
            style: AppTheme.bodySmall(isDark)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
            child: _buildActionTile("SUGAR", "05g", LucideIcons.candy,
                AppTheme.accentPrimary, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("SODIUM", "2.1g", LucideIcons.droplets,
                AppTheme.accentSecondary, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("FATS", "08g", LucideIcons.flame,
                AppTheme.accentSpark, isDark)),
      ],
    );
  }

  Widget _buildActionTile(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: AppTheme.h3(isDark)
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.caption(isDark)
                  .copyWith(fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Text(title,
            style: AppTheme.caption(isDark)
                .copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
                height: 1,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05))),
      ],
    );
  }

  Widget _buildModernScansList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _homeData.recentScans.take(3).length,
      itemBuilder: (context, index) {
        final scan = _homeData.recentScans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: AppTheme.softShadow(isDark),
            border: Border.all(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.02)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.03),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(LucideIcons.package,
                    size: 28,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scan.productName,
                        style:
                            AppTheme.bodyLarge(isDark).copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      "ANALYZED 2H AGO",
                      style: AppTheme.caption(isDark).copyWith(
                          fontSize: 8,
                          color: isDark
                              ? AppTheme.accentPrimary.withValues(alpha: 0.6)
                              : null),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (200 * index).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }
}
