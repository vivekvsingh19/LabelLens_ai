import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(
                  LucideIcons.shield,
                  size: 64,
                  color: isDark ? Colors.white : Colors.black,
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 24),
                Text(
                  "LABELSAFE AI",
                  style: AppTheme.h1(isDark).copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  "KNOW WHAT YOU CONSUME",
                  style: AppTheme.caption(isDark).copyWith(
                    letterSpacing: 4.0,
                    fontSize: 8,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
              ],
            ),
            const SizedBox(height: 60),
            _buildLoadingIndicator(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return SizedBox(
      width: 40,
      height: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          backgroundColor:
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }
}
