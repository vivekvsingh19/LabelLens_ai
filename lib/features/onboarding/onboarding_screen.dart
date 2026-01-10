import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';
import 'dart:ui'; // For ImageFilter

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
      title: "Scan & Decode",
      description:
          "Instantly analyze food labels to reveal hidden additives and nutritional secrets.",
      icon: LucideIcons.scanLine,
      lottiePath: 'assets/animations/scan.json',
    ),
    OnboardingItem(
      title: "Stay Safe",
      description:
          "Detect harmful chemicals and allergens with AI-powered safety ratings.",
      icon: LucideIcons.shieldCheck,
      lottiePath: 'assets/animations/shield.json',
    ),
    OnboardingItem(
      title: "Eat Smarter",
      description:
          "Get personalized recommendations based on your health goals and lifestyle.",
      icon: LucideIcons.sparkles,
      lottiePath: 'assets/animations/insights.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: 600.ms,
        curve: Curves.easeOutQuint,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await PreferencesService().setOnboardingComplete();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeItem = _items[_currentPage];

    // Minimal background color transition
    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          // 1. Subtle Background Elements
          _buildMinimalBackground(isDark, activeItem),

          // 2. Main content area
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_items[index], isDark, index);
                    },
                  ),
                ),
                _buildBottomControls(context, isDark, activeItem),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalBackground(bool isDark, OnboardingItem activeItem) {
    final accentColor = isDark ? Colors.white : Colors.black;
    return AnimatedContainer(
      duration: 1000.ms,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      ),
      child: Stack(
        children: [
          // Very subtle large glow ball
          AnimatedPositioned(
            duration: 1000.ms,
            curve: Curves.easeInOut,
            top: -150,
            right: _currentPage.isEven ? -100 : -200,
            child: AnimatedContainer(
              duration: 1000.ms,
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.03),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.02),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPage < _items.length - 1)
            TextButton(
              onPressed: _completeOnboarding,
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white54 : Colors.black45,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                "Skip",
                style: AppTheme.bodySmall(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingItem item, bool isDark, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Animation container
        SizedBox(
          height: 300,
          width: 300,
          child: item.lottiePath != null
              ? Lottie.asset(
                  item.lottiePath!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildIconPlaceholder(item, isDark);
                  },
                )
              : _buildIconPlaceholder(item, isDark),
        )
            .animate(target: _currentPage == index ? 1 : 0)
            .fade(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),

        const Spacer(),
      ],
    );
  }

  Widget _buildBottomControls(
      BuildContext context, bool isDark, OnboardingItem item) {
    final isLastPage = _currentPage == _items.length - 1;
    final accentColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text Content with crossfade
          SizedBox(
            height: 120, // Fixed height to prevent layout jumps
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: 400.ms,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.2), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    item.title,
                    key: ValueKey('title_${_items.indexOf(item)}'),
                    style: AppTheme.h1(isDark).copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: 400.ms,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    item.description,
                    key: ValueKey('desc_${_items.indexOf(item)}'),
                    style: AppTheme.body(isDark).copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Footer Row: Indicators left, Button right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minimal Indicators
              Row(
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.only(right: 8),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? accentColor
                          : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              // Action Button
              GestureDetector(
                onTap: _nextPage,
                child: AnimatedContainer(
                  duration: 300.ms,
                  // Button grows significantly on last page
                  width: isLastPage ? 160 : 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arrow for non-last pages
                      AnimatedOpacity(
                        duration: 200.ms,
                        opacity: isLastPage ? 0 : 1,
                        child: Icon(
                          LucideIcons.arrowRight,
                          color: isDark ? Colors.black : Colors.white,
                          size: 24,
                        ),
                      ),
                      // "Get Started" for last page
                      AnimatedOpacity(
                        duration: 200.ms,
                        opacity: isLastPage ? 1 : 0,
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder(OnboardingItem item, bool isDark) {
    final accentColor = isDark ? Colors.white : Colors.black;
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.05),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: 64,
          color: accentColor,
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final String? lottiePath;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    this.lottiePath,
  });
}
