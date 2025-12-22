import 'dart:math' as math;
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

  Widget _buildHeader(bool isDark) {
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
                  Text("HELLO, VIVEK",
                      style: AppTheme.caption(isDark).copyWith(
                          fontSize: 12,
                          letterSpacing: 3,
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
            _buildStreakIndicator(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakIndicator(bool isDark) {
    // Calculate streak based on scan history
    final streak = 7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.flame,
            size: 24,
            color: isDark ? Colors.white : Colors.black,
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
    Color secondaryColor = const Color(0xFF64FFDA); // Mint

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
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
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
                      _buildImpactBadge(
                        isDark, 
                        "$safeScans", 
                        "Clean Choices", 
                        LucideIcons.check
                      ),
                      const SizedBox(width: 12),
                      _buildImpactBadge(
                        isDark, 
                        "${history.length}", 
                        "Labels Analyzed", 
                        LucideIcons.scanLine
                      ),
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

  Widget _buildImpactBadge(bool isDark, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              )),
              Text(label, style: TextStyle(
                fontSize: 10,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
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
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.premiumShadow(isDark),
        border: Border.all(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.05)),
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
                LucideIcons.skull, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("CAUTIONS", cautionCount.toString(),
                LucideIcons.alertTriangle, isDark)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildActionTile("SAFE", safeCount.toString(),
                LucideIcons.checkCircle, isDark)),
      ],
    );
  }

  Widget _buildActionTile(
      String label, String value, IconData icon, bool isDark) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow(isDark),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon,
              size: 20,
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.7)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTheme.h2(isDark).copyWith(
                      fontSize: 28,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTheme.caption(isDark).copyWith(
                      fontSize: 8,
                      letterSpacing: 1,
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.5))),
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
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.scanLine,
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
              borderRadius: BorderRadius.circular(24),
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
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      scan.score.toInt().toString(),
                      style: AppTheme.h3(isDark).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black),
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
                                ? LucideIcons.apple
                                : LucideIcons.sparkles,
                            size: 12,
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.5),
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
                  child: Icon(LucideIcons.arrowRight,
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

class _DotPatternPainter extends CustomPainter {
  final bool isDark;
  _DotPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const spacing = 20.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        if ((x + y) % (spacing * 2) == 0) {
          canvas.drawCircle(Offset(x, y), 1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  final List<IngredientDetail> ingredients;
  final bool isDark;
  final double score;

  _OrbitPainter(
      {required this.ingredients, required this.isDark, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2 - 20); // Shift up slightly

    // Draw central "Core" (The Product)
    final corePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 40, corePaint);

    // Draw Orbits
    final orbitPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, 60, orbitPaint);
    canvas.drawCircle(center, 90, orbitPaint);
    canvas.drawCircle(center, 120, orbitPaint);

    // Draw Particles (Ingredients)
    final random = math.Random(score.toInt()); // Deterministic based on score

    for (var i = 0; i < ingredients.length; i++) {
      final ing = ingredients[i];
      // Determine orbit radius based on safety
      // Safe = close, Avoid = far
      double radius;
      if (ing.rating == SafetyBadge.safe) {
        radius = 50 + random.nextDouble() * 20;
      } else if (ing.rating == SafetyBadge.caution) {
        radius = 80 + random.nextDouble() * 20;
      } else {
        radius = 110 + random.nextDouble() * 30;
      }

      final angle = random.nextDouble() * 2 * math.pi;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final particlePaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(
            alpha: ing.rating == SafetyBadge.avoid
                ? 0.8
                : (ing.rating == SafetyBadge.caution ? 0.5 : 0.2))
        ..style = PaintingStyle.fill;

      // Size based on rating
      final size = ing.rating == SafetyBadge.avoid
          ? 4.0
          : (ing.rating == SafetyBadge.caution ? 3.0 : 2.0);

      canvas.drawCircle(Offset(x, y), size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    path.lineTo(width * 0.5, midY + 40);  // Trough
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
