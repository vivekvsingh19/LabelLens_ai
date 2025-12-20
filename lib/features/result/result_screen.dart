import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/widgets/section_header.dart';
import 'package:labelsafe_ai/core/models/enums.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'dart:math' as math;

class ResultScreen extends StatelessWidget {
  final ProductAnalysis analysis;
  const ResultScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ratingColor = analysis.rating == SafetyBadge.safe
        ? AppTheme.safe
        : (analysis.rating == SafetyBadge.caution
            ? AppTheme.caution
            : AppTheme.avoid);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: Colors.transparent,
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
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 24),
                      _buildTopBar(context, isDark),
                      const SizedBox(height: 32),
                      _buildImmersiveHero(isDark, ratingColor),
                      const SizedBox(height: 40),
                      _buildQuickStats(isDark),
                      const SizedBox(height: 32),
                      _buildHighlightChips(isDark, ratingColor),
                      const SizedBox(height: 48),
                      SectionHeader(title: "AI INSIGHTS", isDark: isDark),
                      const SizedBox(height: 16),
                      _buildSummaryCard(isDark, ratingColor),
                      const SizedBox(height: 48),
                      SectionHeader(
                          title: "INGREDIENT BREAKDOWN", isDark: isDark),
                      const SizedBox(height: 24),
                      ...analysis.ingredients.map(
                          (ing) => _buildModernIngredientTile(ing, isDark)),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ratingColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('NEW SCAN'),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(analysis.brand.toUpperCase(),
                  style: AppTheme.caption(isDark).copyWith(
                    fontSize: 9,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.5),
                  )),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      analysis.productName,
                      style: AppTheme.h2(isDark).copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryBadge(analysis.category, isDark),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(LucideIcons.share2, size: 20),
          style: IconButton.styleFrom(
            backgroundColor:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.x, size: 20),
          style: IconButton.styleFrom(
            backgroundColor:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
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
        borderRadius: BorderRadius.circular(20),
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
        style: const TextStyle(
          color: Colors.white,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("SAFE", safeCount.toString(), AppTheme.safe, isDark),
        _buildStatDivider(isDark),
        _buildStatItem(
            "CAUTION", cautionCount.toString(), AppTheme.caution, isDark),
        _buildStatDivider(isDark),
        _buildStatItem("AVOID", avoidCount.toString(), AppTheme.avoid, isDark),
      ],
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.h2(isDark)
              .copyWith(color: color, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style:
              AppTheme.caption(isDark).copyWith(fontSize: 8, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
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
        final chipColor = isNegative ? AppTheme.avoid : AppTheme.safe;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNegative ? LucideIcons.alertCircle : LucideIcons.sparkles,
                size: 12,
                color: chipColor,
              ),
              const SizedBox(width: 8),
              Text(
                tag,
                style: AppTheme.bodySmall(isDark).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildSummaryCard(bool isDark, Color ratingColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ratingColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: ratingColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brainCircuit, color: ratingColor, size: 20),
              const SizedBox(width: 12),
              Text(
                "AI ANALYSIS",
                style: AppTheme.caption(isDark).copyWith(
                  color: ratingColor,
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
    final color = ing.rating == SafetyBadge.safe
        ? AppTheme.safe
        : (ing.rating == SafetyBadge.caution
            ? AppTheme.caution
            : AppTheme.avoid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
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
                      color.withValues(alpha: 0.04),
                      color.withValues(alpha: 0.01),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ing.rating.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(ing.name,
                            style: AppTheme.h3(isDark).copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            )),
                      ),
                      _buildFunctionalTag(ing.function, isDark),
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info, size: 14, color: color),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        function.toUpperCase(),
        style: AppTheme.caption(isDark).copyWith(
          fontSize: 8,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
        ),
      ),
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
