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

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(scanHistoryProvider);

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go('/home');
        },
        child: Scaffold(
          backgroundColor:
              isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: AppBar(
            title: Text('PROGRESS',
                style: AppTheme.h2(isDark).copyWith(
                    letterSpacing: -1,
                    fontWeight: FontWeight.w900,
                    fontSize: 24)),
            centerTitle: false,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () async {
                  await ref.read(analysisRepositoryProvider).clearHistory();
                  ref.invalidate(scanHistoryProvider);
                },
                icon: Icon(LucideIcons.trash2,
                    size: 20, color: isDark ? Colors.white : Colors.black),
              ),
            ],
          ),
          body: historyAsync.when(
            data: (history) => history.isEmpty
                ? _buildEmptyState(isDark)
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildStatGrid(isDark, history),
                        //const SizedBox(height: 20),
                        SectionHeader(title: "RECENT LOGS", isDark: isDark),
                        const SizedBox(height: 20),
                        _buildHistoryList(context, isDark, history),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ));
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history,
              size: 64,
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text("NO SCANS YET", style: AppTheme.h3(isDark)),
          const SizedBox(height: 8),
          Text("Your analyzed products will appear here",
              style: AppTheme.caption(isDark)),
        ],
      ),
    );
  }

  Widget _buildStatGrid(bool isDark, List<ProductAnalysis> history) {
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
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard("SCANNED", "$scannedCount", LucideIcons.scan,
            isDark ? Colors.white : Colors.black, isDark),
        _buildStatCard("AVG SCORE", "$avgScore", LucideIcons.activity,
            isDark ? Colors.white : Colors.black, isDark),
        _buildStatCard(
            "UNSAFE FOUND",
            "$unsafeIngredients",
            LucideIcons.shieldAlert,
            isDark ? Colors.white : Colors.black,
            isDark),
        _buildStatCard("STREAK", "02", LucideIcons.zap,
            isDark ? Colors.white : Colors.black, isDark),
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
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
              '/result/${Uri.encodeComponent(scan.category)}',
              extra: scan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getRatingIcon(scan.rating),
                      color: isDark ? Colors.white : Colors.black, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.productName.toUpperCase(),
                          style: AppTheme.h3(isDark).copyWith(fontSize: 14)),
                      Text(scan.brand.toUpperCase(),
                          style: AppTheme.caption(isDark)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${scan.score.toInt()}%",
                        style: AppTheme.h3(isDark).copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900)),
                    Text(_getFormattedDate(scan.date),
                        style: AppTheme.caption(isDark).copyWith(fontSize: 8)),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.05, end: 0),
        );
      },
    );
  }

  IconData _getRatingIcon(SafetyBadge rating) {
    switch (rating) {
      case SafetyBadge.safe:
        return LucideIcons.check;
      case SafetyBadge.caution:
        return LucideIcons.alertCircle;
      case SafetyBadge.avoid:
        return LucideIcons.x;
    }
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
