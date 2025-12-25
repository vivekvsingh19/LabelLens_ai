import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/widgets/section_header.dart';
import 'package:labelsafe_ai/core/models/enums.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'dart:math' as math;

class ResultScreen extends StatefulWidget {
  final ProductAnalysis analysis;
  const ResultScreen({super.key, required this.analysis});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showFullReport = false;
  final Set<int> _expandedAlerts = {};

  ProductAnalysis get analysis => widget.analysis;

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

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    // We'll wrap the main logic in a helper to keep build clean
    // Access widget.analysis instead of analysis
    final analysis = widget.analysis;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratingColor = _getRatingColor(analysis.rating);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphic background tap-to-dismiss
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ).animate().fadeIn(),
          ),

          // Main Content Sheet
          Positioned.fill(
            top: 60, // Top margin to show it's a sheet
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.borderRadiusLarge)),
                boxShadow: AppTheme.premiumShadow(isDark),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Pull Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding:
                          EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 40),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildTopBar(context, isDark),
                        const SizedBox(height: 32),
                        _buildImmersiveHero(isDark, ratingColor),
                        const SizedBox(height: 40),
                        _buildQuickStats(isDark),
                        const SizedBox(height: 32),
                        _buildCompositionAnalysis(isDark),
                        const SizedBox(height: 24),
                        _buildRecommendationCard(isDark),
                        const SizedBox(height: 24),
                        ...[
                          if (!_showFullReport) ...[
                            _buildCriticalAlerts(isDark),
                            const SizedBox(height: 24),
                          ],
                          if (!_showFullReport)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _showFullReport = true),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.05)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("VIEW FULL ANALYSIS",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.0)),
                                    const SizedBox(width: 8),
                                    Icon(LucideIcons.chevronDown,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2, end: 0)
                          else
                            ...[
                              _buildHighlightChips(isDark, ratingColor),
                              const SizedBox(height: 32),
                              if (_showFullReport) ...[
                                SectionHeader(
                                    title: "AI INSIGHTS", isDark: isDark),
                                const SizedBox(height: 16),
                                _buildSummaryCard(isDark, ratingColor),
                              ],
                              const SizedBox(height: 48),
                              SectionHeader(
                                  title: "INGREDIENT BREAKDOWN",
                                  isDark: isDark),
                              const SizedBox(height: 24),
                              ...analysis.ingredients.map((ing) =>
                                  _buildModernIngredientTile(ing, isDark)),
                              const SizedBox(height: 48),
                            ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
                        ],
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ratingColor,
                              foregroundColor: Colors.white,
                              fixedSize: const Size(180, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.scanLine, size: 18),
                                const SizedBox(width: 8),
                                const Text('NEW SCAN',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().slideY(
                  begin: 1.0,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryBadge(analysis.category, isDark),
              const SizedBox(height: 12),
              Text(
                analysis.brand.toUpperCase(),
                style: AppTheme.caption(isDark).copyWith(
                  fontSize: 9,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                analysis.productName,
                style: AppTheme.h2(isDark).copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.share2, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.x, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String category, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTheme.caption(isDark).copyWith(
          fontSize: 8,
          letterSpacing: 0,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImmersiveHero(bool isDark, Color ratingColor) {
    return Center(
      child: SizedBox(
        height: 240,
        width: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ratingColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 3.seconds,
                ),

            // Custom Gauge
            CustomPaint(
              size: const Size(220, 220),
              painter: _SafetyGaugePainter(
                score: analysis.score,
                color: ratingColor,
                isDark: isDark,
              ),
            )
                .animate()
                .rotate(duration: 1.5.seconds, curve: Curves.easeOutQuart),

            // Score Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  analysis.score.toInt().toString(),
                  style: AppTheme.score(isDark).copyWith(
                    fontSize: 88,
                    height: 1,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "INDEX",
                  style: AppTheme.caption(isDark).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSafetyStatusBadge(analysis.rating, ratingColor, isDark),
              ],
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStatusBadge(SafetyBadge rating, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        rating.name.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    final safeCount =
        analysis.ingredients.where((i) => i.rating == SafetyBadge.safe).length;
    final cautionCount = analysis.ingredients
        .where((i) => i.rating == SafetyBadge.caution)
        .length;
    final avoidCount =
        analysis.ingredients.where((i) => i.rating == SafetyBadge.avoid).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(safeCount.toString(), "SAFE",
              AppTheme.safeColor, LucideIcons.checkCircle, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(cautionCount.toString(), "CAUTION",
              AppTheme.cautionColor, LucideIcons.alertTriangle, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(avoidCount.toString(), "AVOID",
              AppTheme.avoidColor, LucideIcons.xCircle, isDark),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCompositionAnalysis(bool isDark) {
    if (analysis.ingredients.isEmpty) return const SizedBox.shrink();

    final total = analysis.ingredients.length;

    // Calculate counts
    final harmfulCount = analysis.ingredients
        .where((i) =>
            i.rating == SafetyBadge.avoid || i.rating == SafetyBadge.caution)
        .length;

    final stabilizerCount = analysis.ingredients.where((i) {
      final f = i.function.toLowerCase();
      return f.contains('stabilizer') ||
          f.contains('thickener') ||
          f.contains('emulsifier') ||
          f.contains('preservative');
    }).length;

    final sugarCount = analysis.ingredients.where((i) {
      final n = i.name.toLowerCase();
      final f = i.function.toLowerCase();
      return f.contains('sweetener') ||
          n.contains('sugar') ||
          n.contains('syrup') ||
          n.contains('fructose') ||
          n.contains('glucose');
    }).length;

    // Use nutritional percentages if available (non-zero), otherwise fallback to ingredient count for sugar
    // For fats, we only have nutritional info now.
    final fatPercent = analysis.fatPercentage / 100.0;
    final sugarPercent = analysis.sugarPercentage > 0
        ? analysis.sugarPercentage / 100.0
        : sugarCount / total;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.pieChart,
                  size: 14,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              Text("COMPOSITION BREAKDOWN",
                  style: AppTheme.caption(isDark).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniRing(
                  harmfulCount / total, "RISK", AppTheme.avoidColor, isDark),
              _buildMiniRing(stabilizerCount / total, "PROCESSED",
                  AppTheme.cautionColor, isDark),
              _buildMiniRing(
                  sugarPercent, "SUGAR", AppTheme.cautionColor, isDark),
              _buildMiniRing(fatPercent, "FATS", AppTheme.cautionColor, isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildMiniRing(
      double percent, String label, Color color, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CustomPaint(
            painter: _MiniRingPainter(
                percent: percent,
                color: isDark ? Colors.white : Colors.black,
                isDark: isDark),
            child: Center(
              child: Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.caption(isDark)
              .copyWith(fontSize: 8, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.h2(isDark).copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.caption(isDark).copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightChips(bool isDark, Color ratingColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: analysis.highlights.map((tag) {
        final isNegative = tag.toLowerCase().contains("contains") ||
            tag.toLowerCase().contains("processed") ||
            tag.toLowerCase().contains("regulator");
        final chipColor = isDark ? Colors.white : Colors.black;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNegative ? LucideIcons.alertCircle : LucideIcons.sparkles,
                size: 12,
                color: chipColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tag,
                  style: AppTheme.bodySmall(isDark).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildRecommendationCard(bool isDark) {
    final rec = analysis.recommendation;
    final isBuy =
        rec.toLowerCase().contains('buy') || rec.toLowerCase().contains('safe');
    final isAvoid = rec.toLowerCase().contains('avoid') ||
        rec.toLowerCase().contains('don\'t');

    Color color;
    IconData icon;
    String title;

    if (isBuy) {
      color = AppTheme.safeColor;
      icon = LucideIcons.thumbsUp;
      title = "RECOMMENDED";
    } else if (isAvoid) {
      color = AppTheme.avoidColor;
      icon = LucideIcons.thumbsDown;
      title = "NOT RECOMMENDED";
    } else {
      color = AppTheme.cautionColor;
      icon = LucideIcons.alertTriangle;
      title = "CONSUME WITH CAUTION";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSummaryCard(bool isDark, Color ratingColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brainCircuit,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.8),
                  size: 20),
              const SizedBox(width: 12),
              Text(
                "AI ANALYSIS",
                style: AppTheme.caption(isDark).copyWith(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            analysis.overview,
            style: AppTheme.body(isDark).copyWith(
              height: 1.7,
              fontSize: 15,
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildModernIngredientTile(IngredientDetail ing, bool isDark) {
    final color = isDark ? Colors.white : Colors.black;
    final ratingColor = _getRatingColor(ing.rating);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Stack(
          children: [
            // Suble background tint gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ratingColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ing.rating.name.toUpperCase(),
                          style: TextStyle(
                            color: ratingColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ing.name,
                              style: AppTheme.h3(isDark).copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildFunctionalTag(ing.function, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      ing.technicalName.toUpperCase(),
                      style: AppTheme.caption(isDark).copyWith(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.3),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info,
                            size: 14, color: color.withValues(alpha: 0.5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ing.explanation,
                            style: AppTheme.bodySmall(isDark).copyWith(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.7),
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildFunctionalTag(String function, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        function.toUpperCase(),
        style: AppTheme.caption(isDark).copyWith(
          fontSize: 8,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCriticalAlerts(bool isDark) {
    // Filter for avoid/caution ingredients
    final alerts = analysis.ingredients
        .where((i) =>
            i.rating == SafetyBadge.avoid || i.rating == SafetyBadge.caution)
        .take(3)
        .toList();

    if (alerts.isEmpty) return const SizedBox.shrink();

    final alertColor = AppTheme.avoidColor;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 16, color: alertColor),
            const SizedBox(width: 8),
            Text(
              "CRITICAL INGREDIENTS TO WATCH",
              style: AppTheme.caption(isDark).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: alertColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.asMap().entries.map((entry) {
          final index = entry.key;
          final ing = entry.value;
          final isExpanded = _expandedAlerts.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedAlerts.remove(index);
                } else {
                  _expandedAlerts.add(index);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.xCircle,
                          size: 16, color: alertColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ing.name,
                              style: AppTheme.bodySmall(isDark).copyWith(
                                  fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ing.explanation,
                              style: AppTheme.caption(isDark).copyWith(
                                fontSize: 12,
                                letterSpacing: 0,
                                height: 1.4,
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.7),
                              ),
                              maxLines: isExpanded ? null : 2,
                              overflow:
                                  isExpanded ? null : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: alertColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ing.rating.name.toUpperCase(),
                          style: TextStyle(
                              color: alertColor,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (ing.explanation.length > 80)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExpanded
                                ? LucideIcons.chevronUp
                                : LucideIcons.chevronDown,
                            size: 14,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpanded ? "Show less" : "Show details",
                            style: AppTheme.caption(isDark).copyWith(
                              fontSize: 10,
                              color: textColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SafetyGaugePainter extends CustomPainter {
  final double score;
  final Color color;
  final bool isDark;

  _SafetyGaugePainter({
    required this.score,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Background track
    final bgPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Active progress
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.5),
          color,
        ],
        stops: const [0.0, 1.0],
        startAngle: math.pi * 0.75,
        endAngle: math.pi * 2.25,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );

    // Decorative dots/markers
    final markerPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2);

    for (int i = 0; i <= 10; i++) {
      final angle = math.pi * 0.75 + (i / 10) * math.pi * 1.5;
      final x = center.dx + (radius - strokeWidth * 2.5) * math.cos(angle);
      final y = center.dy + (radius - strokeWidth * 2.5) * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniRingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final bool isDark;

  _MiniRingPainter(
      {required this.percent, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 5.0;

    final bgPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * percent.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
