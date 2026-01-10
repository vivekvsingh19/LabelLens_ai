import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/features/splash/splash_screen.dart';
import 'package:labelsafe_ai/features/onboarding/onboarding_screen.dart';
import 'package:labelsafe_ai/features/onboarding/login_screen.dart';
import 'package:labelsafe_ai/features/home/home_screen.dart';
import 'package:labelsafe_ai/features/scan/camera_screen.dart';
import 'package:labelsafe_ai/features/result/result_screen.dart';
import 'package:labelsafe_ai/features/history/history_screen.dart';
import 'package:labelsafe_ai/features/profile/profile_screen.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/widgets/scaffold_with_navbar.dart';

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
      // Hidden for now - keep for future use
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
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
          final analysis = state.extra as ProductAnalysis?;
          final type = state.pathParameters['type'] ?? 'unknown';

          if (analysis == null) {
            debugPrint(
                'ROUTER ERROR: ResultScreen opened without ProductAnalysis extra. Path type: $type');
            // In production, if we lost the state, go back home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/home');
            });
            return const NoTransitionPage(child: SizedBox());
          }

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
