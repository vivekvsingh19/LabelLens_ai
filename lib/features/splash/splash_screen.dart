import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';

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
    final minSplashTime = Future.delayed(const Duration(milliseconds: 2500));
    final prefs = PreferencesService();

    // Run checks in parallel with splash timer
    final results = await Future.wait([
      minSplashTime,
      prefs.isOnboardingComplete(),
      prefs.isLoggedIn(),
    ]);

    if (!mounted) return;

    final onboardingComplete = results[1] as bool;
    final isLoggedIn = results[2] as bool;

    if (!onboardingComplete) {
      context.go('/onboarding');
    } else if (!isLoggedIn) {
      context.go('/login');
    } else {
      context.go('/home');
    }
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
                Image.asset(
                  isDark ? 'assets/images/dark.png' : 'assets/images/light.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 16),
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
