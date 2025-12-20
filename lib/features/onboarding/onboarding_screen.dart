import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "SCAN LABELS",
      description: "INSTANTLY DECODE INGREDIENTS AND NUTRITIONAL FACTS.",
      icon: LucideIcons.camera,
    ),
    OnboardingItem(
      title: "STAY SAFE",
      description: "IDENTIFY HIDDEN ADDITIVES AND POTENTIAL HARMFUL CHEMICALS.",
      icon: LucideIcons.shieldCheck,
    ),
    OnboardingItem(
      title: "HI-LEVEL INSIGHTS",
      description: "PARTNER WITH AI TO MAKE INFORMED CONSUMPTION CHOICES.",
      icon: LucideIcons.zap,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(context, isDark),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _items.length,
                itemBuilder: (context, index) =>
                    _buildPage(_items[index], isDark),
              ),
            ),
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "LABELSAFE",
                style: AppTheme.caption(isDark).copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              "SKIP",
              style: AppTheme.caption(isDark).copyWith(
                fontSize: 10,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 80,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 60),
          Text(
            item.title,
            style: AppTheme.h1(isDark).copyWith(
              fontSize: 32,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: AppTheme.body(isDark).copyWith(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.6,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _items.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              } else {
                context.go('/home');
              }
            },
            child: Text(
              _currentPage < _items.length - 1 ? "CONTINUE" : "GET STARTED",
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
