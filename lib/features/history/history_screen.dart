import 'package:flutter/material.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: Text('PROGRESS',
            style: AppTheme.h2(isDark).copyWith(
                letterSpacing: -1, fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatGrid(isDark),
            const SizedBox(height: 32),
            _buildAnalysisInsights(isDark),
            const SizedBox(height: 32),
            _buildModernSectionHeader("CONSUMPTION TRENDS", isDark),
            const SizedBox(height: 16),
            _buildChartMock(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassStat(
            "STREAK",
            "12D",
            LucideIcons.flame,
            AppTheme.cautionColor,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassStat(
            "SAFETY",
            "88%",
            LucideIcons.shieldCheck,
            AppTheme.safeColor,
            isDark,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildGlassStat(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.premiumShadow(isDark),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 20),
          Text(value,
              style: AppTheme.h1(isDark)
                  .copyWith(fontSize: 32, letterSpacing: -1)),
          Text(label,
              style: AppTheme.caption(isDark)
                  .copyWith(fontSize: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildAnalysisInsights(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF0D1117)]
              : [Colors.black, const Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.premiumShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap,
                  color: AppTheme.accentPrimary, size: 20),
              const SizedBox(width: 12),
              Text("AI INSIGHT",
                  style: AppTheme.caption(true)
                      .copyWith(color: AppTheme.accentPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Based on your last 10 scans, your sodium intake is peaking on weekends. Consider low-salt alternatives.",
            style: AppTheme.body(true).copyWith(height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildModernSectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Text(title,
            style: AppTheme.caption(isDark)
                .copyWith(letterSpacing: 2, fontWeight: FontWeight.w900)),
        const SizedBox(width: 12),
        Expanded(
            child: Container(
                height: 1,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05))),
      ],
    );
  }

  Widget _buildChartMock(bool isDark) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final heights = [60.0, 40.0, 90.0, 110.0, 80.0, 130.0, 100.0];
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 28,
                height: heights[index],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentPrimary.withValues(alpha: 0.8),
                      AppTheme.accentPrimary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ).animate().scaleY(
                  delay: (100 * index).ms,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                  begin: 0),
              const SizedBox(height: 8),
              Text(["M", "T", "W", "T", "F", "S", "S"][index],
                  style: AppTheme.caption(isDark).copyWith(fontSize: 8)),
            ],
          );
        }),
      ),
    );
  }
}
