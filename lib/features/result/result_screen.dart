import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/mock/mock_data.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

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
                      const SizedBox(height: 32),
                      _buildHighlightChips(isDark, ratingColor),
                      const SizedBox(height: 48),
                      _buildSectionHeader("AI SUMMARY", isDark),
                      const SizedBox(height: 16),
                      _buildSummaryCard(isDark),
                      const SizedBox(height: 48),
                      _buildSectionHeader("INGREDIENT ANALYSIS", isDark),
                      const SizedBox(height: 24),
                      ...analysis.ingredients.map(
                          (ing) => _buildModernIngredientTile(ing, isDark)),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => context.pop(),
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
                  style: AppTheme.caption(isDark).copyWith(fontSize: 9)),
              const SizedBox(height: 4),
              Text(
                analysis.productName,
                style: AppTheme.h2(isDark).copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.x, size: 20),
          style: IconButton.styleFrom(
            backgroundColor:
                (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary)
                    .withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildImmersiveHero(bool isDark, Color ratingColor) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background accent bloom
          Positioned(
            top: 0,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ratingColor.withValues(alpha: 0.15),
                    ratingColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),
          ),
          // Progress Ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: analysis.score / 100,
              strokeWidth: 4,
              backgroundColor: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05),
              color: ratingColor,
              strokeCap: StrokeCap.round,
            ),
          ).animate().rotate(duration: 1.seconds, curve: Curves.easeOutBack),
          // Score Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                analysis.score.toInt().toString(),
                style: AppTheme.score(isDark).copyWith(fontSize: 80, height: 1),
              ),
              Text(
                "SAFETY SCORE",
                style: AppTheme.caption(isDark).copyWith(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.4),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .scale(begin: const Offset(0.9, 0.9)),
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
            tag.toLowerCase().contains("processed");
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (isNegative ? AppTheme.avoid : AppTheme.safe)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: (isNegative ? AppTheme.avoid : AppTheme.safe)
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNegative
                    ? LucideIcons.alertTriangle
                    : LucideIcons.checkCircle2,
                size: 14,
                color: isNegative ? AppTheme.avoid : AppTheme.safe,
              ),
              const SizedBox(width: 8),
              Text(
                tag.toUpperCase(),
                style: AppTheme.caption(isDark).copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isNegative ? AppTheme.avoid : AppTheme.safe,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Text(
        analysis.overview,
        style: AppTheme.bodyLarge(isDark).copyWith(
          height: 1.8,
          fontSize: 15,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.8),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Text(title,
            style: AppTheme.caption(isDark).copyWith(letterSpacing: 1.5)),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildModernIngredientTile(IngredientDetail ing, bool isDark) {
    final color = ing.rating == SafetyBadge.safe
        ? AppTheme.safe
        : (ing.rating == SafetyBadge.caution
            ? AppTheme.caution
            : AppTheme.avoid);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ing.rating.name.toUpperCase(),
                  style: AppTheme.caption(isDark).copyWith(
                    color: color,
                    fontSize: 8,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Spacer(),
              _buildFunctionalTag(ing.function, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(ing.name,
              style: AppTheme.h3(isDark)
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            ing.technicalName.toUpperCase(),
            style: AppTheme.caption(isDark).copyWith(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ing.explanation,
            style: AppTheme.body(isDark).copyWith(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.02, end: 0);
  }

  Widget _buildFunctionalTag(String function, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
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
