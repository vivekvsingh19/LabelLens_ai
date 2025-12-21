import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/models/enums.dart';
import 'package:labelsafe_ai/core/providers/ui_providers.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/widgets/section_header.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: historyAsync.when(
        data: (history) => Stack(
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
                          _buildMainHeroCard(isDark, history),
                          const SizedBox(height: 24),
                          _buildQuickActions(isDark, history),
                          const SizedBox(height: 48),
                          SectionHeader(
                              title: "RECENT ANALYSIS", isDark: isDark),
                          const SizedBox(height: 20),
                          _buildModernScansList(context, isDark, history),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
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
            Expanded(
              child: Column(
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
            ),
            const SizedBox(width: 16),
            _buildStreakIndicator(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(bool isDark) {
    // Calculate streak based on scan history
    // For now, using a simple counter - can be enhanced with actual streak logic
    final streak = 7; // This can be calculated from actual scan dates

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.15),
            const Color(0xFFFF8C42).withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildMainHeroCard(bool isDark, List<ProductAnalysis> history) {
    final lastScore = history.isEmpty ? 0 : history.first.score.toInt();

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
              Text("LATEST SAFETY SCORE",
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
                "$lastScore",
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
              value: lastScore / 100,
              minHeight: 8,
              backgroundColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppTheme.accentPrimary : Colors.black),
            ),
          ).animate().scaleX(duration: 1.seconds, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            history.isEmpty
                ? "Start scanning products to see your safety index."
                : "Your safety profile is based on your latest analysis.",
            style: AppTheme.bodySmall(isDark)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions(bool isDark, List<ProductAnalysis> history) {
    // Calculate real stats from last 5 products
    int avoidCount = 0;
    int cautionCount = 0;
    int safeCount = 0;

    for (var scan in history.take(5)) {
      for (var ing in scan.ingredients) {
        if (ing.rating == SafetyBadge.avoid) avoidCount++;
        if (ing.rating == SafetyBadge.caution) cautionCount++;
        if (ing.rating == SafetyBadge.safe) safeCount++;
      }
    }

    return Row(
      children: [
        Expanded(
            child: _buildActionTile("AVOIDED", avoidCount.toString(),
                LucideIcons.skull, AppTheme.avoid, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("CAUTIONS", cautionCount.toString(),
                LucideIcons.alertTriangle, AppTheme.caution, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("SAFE", safeCount.toString(),
                LucideIcons.checkCircle, AppTheme.safe, isDark)),
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

  Widget _buildModernScansList(
      BuildContext context, bool isDark, List<ProductAnalysis> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Center(
          child: Text("No scans yet", style: AppTheme.caption(isDark)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.take(3).length,
      itemBuilder: (context, index) {
        final scan = history[index];
        final timeAgo = _getTimeAgo(scan.date);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
              '/result/${Uri.encodeComponent(scan.category)}',
              extra: scan),
          child: Container(
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
                    color: (isDark ? AppTheme.accentPrimary : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                      scan.category.toLowerCase() == 'food'
                          ? LucideIcons.apple
                          : LucideIcons.sparkles,
                      size: 28,
                      color: (isDark ? AppTheme.accentPrimary : Colors.black)
                          .withValues(alpha: 0.4)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.productName,
                          style: AppTheme.bodyLarge(isDark)
                              .copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        "ANALYZED $timeAgo",
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
                  onPressed: () => context.push(
                      '/result/${Uri.encodeComponent(scan.category)}',
                      extra: scan),
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (200 * index).ms)
              .slideX(begin: 0.05, end: 0),
        );
      },
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "${diff.inDays}D AGO";
    if (diff.inHours > 0) return "${diff.inHours}H AGO";
    if (diff.inMinutes > 0) return "${diff.inMinutes}M AGO";
    return "JUST NOW";
  }
}
