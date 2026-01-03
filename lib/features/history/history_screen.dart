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
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(scanHistoryProvider);
    final streak = ref.watch(streakProvider);

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go('/home');
        },
        child: Scaffold(
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
                      _buildHeader(context, isDark, ref),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: history.isEmpty
                              ? _buildEmptyState(context, isDark)
                              : Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    _buildStatGrid(isDark, history, streak),
                                    const SizedBox(height: 24),
                                    if (history.isNotEmpty) ...[
                                      SectionHeader(
                                          title: "HEALTH TREND",
                                          isDark: isDark),
                                      const SizedBox(height: 12),
                                      _HistoryChart(
                                          history: history, isDark: isDark),
                                      const SizedBox(height: 32),
                                    ],
                                    SectionHeader(
                                        title: "RECENT LOGS", isDark: isDark),
                                    const SizedBox(height: 20),
                                    _buildHistoryList(context, isDark, history),
                                    const SizedBox(height: 100),
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
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ));
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
                  (isDark ? AppTheme.accentPrimary : Colors.black)
                      .withValues(alpha: 0.05),
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
                  (isDark ? AppTheme.accentSecondary : Colors.black)
                      .withValues(alpha: 0.04),
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

  Widget _buildHeader(BuildContext context, bool isDark, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("YOUR JOURNEY",
                      style: AppTheme.caption(isDark).copyWith(
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text("PROGRESS\nTRACKER",
                      style: AppTheme.h1(isDark).copyWith(
                          fontSize: 32,
                          height: 0.9,
                          letterSpacing: -1.5,
                          color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await ref.read(analysisRepositoryProvider).clearHistory();
                ref.invalidate(scanHistoryProvider);
              },
              icon: Icon(LucideIcons.trash2,
                  size: 20, color: isDark ? Colors.white : Colors.black),
              style: IconButton.styleFrom(
                backgroundColor: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.history,
                  size: 48,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.2)),
            ),
            const SizedBox(height: 24),
            Text("NO SCANS YET",
                style: AppTheme.h3(isDark).copyWith(letterSpacing: 1)),
            const SizedBox(height: 8),
            Text("Your analyzed products will appear here",
                style: AppTheme.caption(isDark)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text("START SCANNING",
                  style:
                      TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(
      bool isDark, List<ProductAnalysis> history, int streak) {
    final scannedCount = history.length;
    final avgScore = history.isEmpty
        ? 0
        : (history.map((e) => e.score).reduce((a, b) => a + b) / scannedCount)
            .toInt();

    int unsafeIngredients = 0;
    for (var scan in history) {
      unsafeIngredients +=
          scan.ingredients.where((i) => i.rating == SafetyBadge.avoid).length;
    }

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("SCANNED", "$scannedCount", LucideIcons.scan,
            isDark ? Colors.white : Colors.black, isDark),
        _buildStatCard(
            "AVG SCORE",
            "$avgScore",
            LucideIcons.activity,
            avgScore >= 70
                ? AppTheme.safeColor
                : (avgScore >= 40
                    ? AppTheme.cautionColor
                    : AppTheme.avoidColor),
            isDark),
        _buildStatCard("UNSAFE FOUND", "$unsafeIngredients",
            LucideIcons.shieldAlert, AppTheme.avoidColor, isDark),
        _buildStatCard("STREAK", streak.toString().padLeft(2, '0'),
            LucideIcons.zap, AppTheme.cautionColor, isDark),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTheme.h1(isDark).copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
              Text(label, style: AppTheme.caption(isDark)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildHistoryList(
      BuildContext context, bool isDark, List<ProductAnalysis> history) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final scan = history[index];
        final ratingColor = _getRatingColor(scan.rating);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
              '/result/${Uri.encodeComponent(scan.category)}',
              extra: scan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: AppTheme.softShadow(isDark),
              border: Border.all(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.05)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: Stack(
                children: [
                  // Subtle color accent on the left
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: ratingColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Row(
                      children: [
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ratingColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      scan.rating.name.toUpperCase(),
                                      style: TextStyle(
                                        color: ratingColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getFormattedDate(scan.date),
                                    style: AppTheme.caption(isDark).copyWith(
                                      fontSize: 10,
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                scan.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.h3(isDark).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scan.brand.toUpperCase(),
                                style: AppTheme.caption(isDark).copyWith(
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Score Circle
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ratingColor.withValues(alpha: 0.2),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "${scan.score.toInt()}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: ratingColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (50 * index).ms)
              .slideX(begin: 0.05, end: 0),
        );
      },
    );
  }

  Color _getRatingColor(SafetyBadge rating) {
    switch (rating) {
      case SafetyBadge.safe:
        return AppTheme.safeColor;
      case SafetyBadge.caution:
        return AppTheme.cautionColor;
      case SafetyBadge.avoid:
        return AppTheme.avoidColor;
    }
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _HistoryChart extends StatelessWidget {
  final List<ProductAnalysis> history;
  final bool isDark;

  const _HistoryChart({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Take last 7 items and reverse to show oldest to newest left-to-right
    final recentHistory = history.take(7).toList().reversed.toList();
    final spots = recentHistory
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.score))
        .toList();

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) =>
                  isDark ? Colors.white : Colors.black,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()}',
                    TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            getTouchLineStart: (data, index) => 0,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= recentHistory.length) {
                    return const SizedBox.shrink();
                  }
                  final date = recentHistory[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "${date.day}/${date.month}",
                      style: AppTheme.caption(isDark)
                          .copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: isDark ? Colors.white : Colors.black,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  Color dotColor;
                  if (spot.y >= 70) {
                    dotColor = AppTheme.safeColor;
                  } else if (spot.y >= 40) {
                    dotColor = AppTheme.cautionColor;
                  } else {
                    dotColor = AppTheme.avoidColor;
                  }
                  return FlDotCirclePainter(
                    radius: 5,
                    color: isDark ? AppTheme.darkCard : Colors.white,
                    strokeWidth: 3,
                    strokeColor: dotColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.1),
                    (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
