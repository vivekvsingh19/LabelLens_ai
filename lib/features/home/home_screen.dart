import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/models/enums.dart';
import 'package:labelsafe_ai/core/providers/ui_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/widgets/section_header.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(scanHistoryProvider);
    final streak = ref.watch(streakProvider);

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
                  _buildHeader(isDark, streak),
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

  Widget _buildHeader(bool isDark, int streak) {
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
                  Text("LABELSAFE AI",
                      style: AppTheme.caption(isDark).copyWith(
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text("YOUR\nSAFETY INDEX",
                      style: AppTheme.h1(isDark).copyWith(
                          fontSize: 32,
                          height: 0.9,
                          letterSpacing: -1.5,
                          color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildStreakIndicator(isDark, streak),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(bool isDark, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 24,
            color: Color(0xFFFF7043), // Orange accent
          ),
          const SizedBox(height: 4),
          Text(
            '$streak DAYS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildMainHeroCard(bool isDark, List<ProductAnalysis> history) {
    if (history.isEmpty) {
      return _buildEmptyHero(isDark);
    }

    // Calculate Impact
    int risksAvoided = history
        .expand((p) => p.ingredients)
        .where((i) => i.rating == SafetyBadge.avoid)
        .length;

    int safeScans = history.where((p) => p.rating == SafetyBadge.safe).length;

    // Theme: "Health Guard" - Teal/Mint for medical/safety trust
    Color primaryColor = const Color(0xFF00BFA5); // Teal Accent

    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF004D40),
                  const Color(0xFF00695C),
                ]
              : [
                  const Color(0xFFE0F2F1),
                  const Color(0xFFB2DFDB),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Pulse Visualization
            Positioned.fill(
              child: CustomPaint(
                painter: _HealthPulsePainter(
                  color: primaryColor,
                  isDark: isDark,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : primaryColor)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.heartPulse,
                            size: 18,
                            color: isDark ? Colors.white : primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Text("YOUR HEALTH GUARD",
                          style: AppTheme.caption(isDark).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.6))),
                    ],
                  ),

                  const Spacer(),

                  // Main Impact Statement
                  Text(
                    risksAvoided > 0
                        ? "$risksAvoided Potential\nRisks Prevented"
                        : "Active Protection\nEnabled",
                    style: AppTheme.h1(isDark).copyWith(
                        fontSize: 32,
                        height: 1.1,
                        color: isDark ? Colors.white : const Color(0xFF004D40)),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Every harmful ingredient you avoid is a victory for your long-term health.",
                    style: AppTheme.bodySmall(isDark).copyWith(
                        fontSize: 13,
                        height: 1.4,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.6)),
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      _buildImpactBadge(isDark, "$safeScans", "Clean Choices",
                          LucideIcons.check),
                      const SizedBox(width: 12),
                      _buildImpactBadge(isDark, "${history.length}",
                          "Labels Analyzed", LucideIcons.scanLine),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildImpactBadge(
      bool isDark, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  )),
              Text(label,
                  style: TextStyle(
                    fontSize: 10,
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.5),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHero(bool isDark) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.premiumShadow(isDark),
        border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.scanLine,
                size: 48,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text("Start scanning to build your profile",
                style: AppTheme.bodySmall(isDark).copyWith(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, List<ProductAnalysis> history) {
    int sugarCount = 0;
    int fatCount = 0;
    int harmfulCount = 0;

    for (var scan in history) {
      for (var ing in scan.ingredients) {
        final name = ing.name.toLowerCase();

        // Sugar detection
        if (name.contains('sugar') ||
            name.contains('syrup') ||
            name.contains('glucose') ||
            name.contains('fructose') ||
            name.contains('sucrose') ||
            name.contains('sweetener')) {
          sugarCount++;
        }

        // Fat detection
        if (name.contains('fat') ||
            name.contains('oil') ||
            name.contains('butter') ||
            name.contains('cream') ||
            name.contains('lipid') ||
            name.contains('shortening')) {
          fatCount++;
        }

        // Harmful (Avoid/Caution)
        if (ing.rating == SafetyBadge.avoid ||
            ing.rating == SafetyBadge.caution) {
          harmfulCount++;
        }
      }
    }

    return Row(
      children: [
        Expanded(
            child: _buildActionTile(
                "SUGAR\nDETECTED", "$sugarCount", Icons.cookie, isDark,
                accentColor: const Color(0xFFFFA726))), // Orange
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile(
                "FAT & OILS\nDETECTED", "$fatCount", Icons.water_drop, isDark,
                accentColor: const Color(0xFFFDD835))), // Yellow
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("HARMFUL\nINGREDIENTS",
                harmfulCount.toString(), Icons.warning, isDark,
                accentColor: const Color(0xFFEF5350))), // Red
      ],
    );
  }

  Widget _buildActionTile(
      String label, String value, IconData icon, bool isDark,
      {Color? accentColor}) {
    final effectiveColor =
        accentColor ?? (isDark ? Colors.white : Colors.black);

    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: effectiveColor.withValues(alpha: 0.8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    maxLines: 1,
                    style: AppTheme.h2(isDark).copyWith(
                        fontSize: 28,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: effectiveColor)),
              ),
              const SizedBox(height: 4),
              Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption(isDark).copyWith(
                      fontSize: 9,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildModernScansList(
      BuildContext context, bool isDark, List<ProductAnalysis> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.qr_code_scanner,
                  size: 32,
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text("NO SCANS YET",
                  style: AppTheme.caption(isDark).copyWith(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.4))),
            ],
          ),
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

        // Determine colors based on data
        final scoreColor = scan.score > 70
            ? const Color(0xFF66BB6A) // Green
            : scan.score > 40
                ? const Color(0xFFFFA726) // Orange
                : const Color(0xFFEF5350); // Red

        final categoryColor = scan.category.toLowerCase() == 'food'
            ? const Color(0xFF66BB6A) // Green
            : const Color(0xFFAB47BC); // Purple

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.push(
              '/result/${Uri.encodeComponent(scan.category)}',
              extra: scan),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow(isDark),
              border: Border.all(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.03)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      scan.score.toInt().toString(),
                      style: AppTheme.h3(isDark).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: scoreColor),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scan.productName.toUpperCase(),
                          style: AppTheme.h3(isDark).copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            scan.category.toLowerCase() == 'food'
                                ? Icons.restaurant
                                : Icons.auto_awesome,
                            size: 12,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeAgo,
                            style: AppTheme.caption(isDark).copyWith(
                                fontSize: 9,
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.arrow_forward,
                      size: 16,
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.5)),
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

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "${diff.inDays}D AGO";
    if (diff.inHours > 0) return "${diff.inHours}H AGO";
    if (diff.inMinutes > 0) return "${diff.inMinutes}M AGO";
    return "JUST NOW";
  }
}

class _HealthPulsePainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _HealthPulsePainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height * 0.6;

    path.moveTo(0, midY);

    // Draw a stylized "heartbeat" pulse
    path.lineTo(width * 0.3, midY);
    path.lineTo(width * 0.35, midY - 20);
    path.lineTo(width * 0.4, midY + 20);
    path.lineTo(width * 0.45, midY - 40); // Peak
    path.lineTo(width * 0.5, midY + 40); // Trough
    path.lineTo(width * 0.55, midY - 15);
    path.lineTo(width * 0.6, midY + 10);
    path.lineTo(width * 0.65, midY);
    path.lineTo(width, midY);

    // Draw Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw subtle grid background
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double i = 0; i < width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HealthPulsePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
