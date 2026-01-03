import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/providers/ui_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:labelsafe_ai/core/services/gemini_service.dart';
import 'dart:io';

class ScaffoldWithNavbar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavbar({super.key, required this.child});

  void _showScanOptions(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ScanOptionsSheet(
        isDark: isDark,
        onCameraSelected: () {
          Navigator.pop(ctx);
          context.push('/camera/food');
        },
        onGallerySelected: () async {
          Navigator.pop(ctx);
          await _pickAndAnalyzeImage(context, ref, isDark);
        },
      ),
    );
  }

  Future<void> _pickAndAnalyzeImage(
      BuildContext context, WidgetRef ref, bool isDark) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null || !context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AnalyzingDialog(isDark: isDark),
    );

    try {
      final gemini = GeminiService();
      final analysis =
          await gemini.analyzeProductImage(File(picked.path), 'food');

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (analysis != null) {
        // Save to history
        await ref.read(analysisRepositoryProvider).saveAnalysis(analysis);
        ref.invalidate(scanHistoryProvider);

        // Navigate to result
        if (context.mounted) {
          context.push('/result/food', extra: analysis);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not analyze image')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;
    final showTooltip = ref.watch(showScanTooltipProvider);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Row(
          children: [
            // Floating Navigation Capsule
            Expanded(
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkCard.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: isDark ? Colors.white : Colors.black, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavButton(
                      icon: LucideIcons.home,
                      label: 'Home',
                      isSelected: location == '/home',
                      onTap: () => context.go('/home'),
                    ),
                    _NavButton(
                      icon: LucideIcons.barChart,
                      label: 'History',
                      isSelected: location == '/history',
                      onTap: () => context.go('/history'),
                    ),
                    // _NavButton(
                    //   icon: LucideIcons.settings,
                    //   label: 'Settings',
                    //   isSelected: location == '/profile',
                    //   onTap: () => context.go('/profile'),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Separate Floating Scan Button
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    if (showTooltip) {
                      ref.read(showScanTooltipProvider.notifier).state = false;
                    }
                    _showScanOptions(context, ref, isDark);
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.accentPrimary : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.scanLine,
                      color: isDark ? Colors.black : Colors.white,
                      size: 38,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                      ),
                ),
                if (showTooltip)
                  Positioned(
                    top: -65,
                    child: _ScanTooltip(
                      onTap: () => ref
                          .read(showScanTooltipProvider.notifier)
                          .state = false,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanTooltip extends ConsumerWidget {
  final VoidCallback onTap;
  const _ScanTooltip({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Text(
              'START SCANNING',
              style: AppTheme.caption(isDark).copyWith(
                color: textColor,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          CustomPaint(
            painter: _TrianglePainter(color: bgColor),
            size: const Size(12, 6),
          ),
        ],
      ),
    )
        .animate(onComplete: (c) {
          ref.read(showScanTooltipProvider.notifier).state = false;
        })
        .fadeIn()
        .slideY(begin: 0.2, end: 0)
        .then(delay: 4.seconds)
        .fadeOut();
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppTheme.accentPrimary : Colors.black;
    final inactiveColor =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3);
    final color = isSelected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: AppTheme.caption(isDark).copyWith(
              color: color,
              fontSize: 7,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionsSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const _ScanOptionsSheet({
    required this.isDark,
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "SCAN LABEL",
            style: AppTheme.h3(isDark).copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose how to scan your product",
            style: AppTheme.caption(isDark),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _ScanOptionButton(
                  icon: LucideIcons.camera,
                  label: "CAMERA",
                  subtitle: "Take a photo",
                  isDark: isDark,
                  onTap: onCameraSelected,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ScanOptionButton(
                  icon: LucideIcons.image,
                  label: "GALLERY",
                  subtitle: "Upload image",
                  isDark: isDark,
                  onTap: onGallerySelected,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 28, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTheme.h3(isDark).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.caption(isDark).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyzingDialog extends StatelessWidget {
  final bool isDark;

  const _AnalyzingDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "ANALYZING",
              style: AppTheme.h3(isDark).copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Scanning ingredients...",
              style: AppTheme.caption(isDark),
            ),
          ],
        ),
      ),
    );
  }
}
