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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            analysis.productName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMinimalScoreHeader(isDark),
                    const SizedBox(height: 40),
                    _buildSectionTitle('Analysis Overview', isDark),
                    const SizedBox(height: 16),
                    _buildMinimalOverview(isDark),
                    const SizedBox(height: 40),
                    _buildSectionTitle('Ingredients', isDark),
                    const SizedBox(height: 16),
                    ...analysis.ingredients
                        .map((ing) => _buildMinimalIngredientTile(ing, isDark)),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('DISMISS'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMinimalScoreHeader(bool isDark) {
    final ratingColor = analysis.rating == SafetyBadge.safe
        ? AppTheme.safe
        : (analysis.rating == SafetyBadge.caution
            ? AppTheme.caution
            : AppTheme.avoid);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            '${analysis.score.toInt()}',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              height: 1,
              letterSpacing: -4,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ratingColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              analysis.rating == SafetyBadge.safe
                  ? 'SAFE'
                  : (analysis.rating == SafetyBadge.caution
                      ? 'CAUTION'
                      : 'AVOID'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: ratingColor,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMinimalOverview(bool isDark) {
    return Text(
      analysis.overview,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMinimalIngredientTile(IngredientDetail ing, bool isDark) {
    final ratingColor = ing.rating == SafetyBadge.safe
        ? AppTheme.safe
        : (ing.rating == SafetyBadge.caution
            ? AppTheme.caution
            : AppTheme.avoid);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ing.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.5),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: ratingColor, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ing.technicalName.toUpperCase(),
            style: TextStyle(
              color: isDark ? Colors.white24 : Colors.black26,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ing.explanation,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
