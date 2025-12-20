import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:labelsafe_ai/features/splash/splash_screen.dart';
import 'package:labelsafe_ai/features/onboarding/onboarding_screen.dart';
import 'package:labelsafe_ai/features/home/home_screen.dart';
import 'package:labelsafe_ai/features/scan/camera_screen.dart';
import 'package:labelsafe_ai/features/result/result_screen.dart';
import 'package:labelsafe_ai/core/mock/mock_data.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavbar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'History'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),
      GoRoute(
        path: '/camera/:type',
        builder: (context, state) =>
            CameraScreen(scanType: state.pathParameters['type'] ?? 'food'),
      ),
      GoRoute(
        path: '/result/:type',
        pageBuilder: (context, state) {
          final type = state.pathParameters['type'] ?? 'food';
          final analysis = (type == 'food')
              ? MockData.getFoodAnalysis()
              : MockData.getCosmeticAnalysis();
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResultScreen(analysis: analysis),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                    Tween(begin: const Offset(0, 1), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutCubic))),
                child: child,
              );
            },
            opaque: false,
            barrierColor: Colors.black54,
            barrierDismissible: true,
          );
        },
      ),
    ],
  );
}

class ScaffoldWithNavbar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: LucideIcons.home,
                  label: 'Home',
                  isSelected: location == '/home',
                  onTap: () => context.go('/home'),
                ),
                _NavButton(
                  icon: LucideIcons.history,
                  label: 'History',
                  isSelected: location == '/history',
                  onTap: () => context.go('/history'),
                ),
                _NavButton(
                  icon: LucideIcons.user,
                  label: 'Profile',
                  isSelected: location == '/profile',
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    final selectedColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final unselectedColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    final color = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(title)));
}
