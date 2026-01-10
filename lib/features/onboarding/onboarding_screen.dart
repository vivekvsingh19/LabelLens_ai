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
          "Instantly analyze food labels. Identify additives, allergens, and nutritional secrets with one scan.",
      icon: LucideIcons.scanLine,
      lottiePath: 'assets/animations/scan.json',
      accentColor: const Color(0xFF42A5F5), // Blue
    ),
    OnboardingItem(
      title: "Stay Safe",
      description:
          "Detect harmful chemicals and hidden dangers. Protect yourself and your family with AI-powered safety ratings.",
      icon: LucideIcons.shieldCheck,
      lottiePath: 'assets/animations/shield.json',
      accentColor: const Color(0xFF66BB6A), // Green
    ),
    OnboardingItem(
      title: "Health Insights",
      description:
          "Get personalized recommendations based on your health goals. Eat smarter, live better.",
      icon: LucideIcons.sparkles,
      lottiePath: 'assets/animations/insights.json',
      accentColor: const Color(0xFFFFA726), // Orange
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

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Dynamic Background
          _buildBackground(isDark, activeItem),

          // Main Content
          Column(
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
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark, OnboardingItem activeItem) {
    return Stack(
      children: [
        // Base color
        Container(
          color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        ),
        // Animated coloured blob
        AnimatedPositioned(
          duration: 1000.ms,
          curve: Curves.easeInOut,
          top: -100,
          right: _currentPage.isEven ? -100 : null,
          left: _currentPage.isOdd ? -100 : null,
          child: AnimatedContainer(
            duration: 1000.ms,
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeItem.accentColor.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: activeItem.accentColor.withValues(alpha: 0.2),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 4.seconds),
        ),
        // Glass overlay for subtle texture
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Skip button
            if (_currentPage < _items.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                ),
                child: Text(
                  "SKIP",
                  style: AppTheme.caption(isDark).copyWith(fontSize: 12),
                ),
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingItem item, bool isDark, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Lottie / Image Area
        SizedBox(
          height: 320,
          width: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow behind
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accentColor.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: 0.2),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              item.lottiePath != null
                  ? Lottie.asset(
                      item.lottiePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildIconPlaceholder(item, isDark);
                      },
                    )
                  : _buildIconPlaceholder(item, isDark),
            ],
          ),
        )
            .animate(target: _currentPage == index ? 1 : 0)
            .fade(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
            .then()
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
                begin: 0,
                end: -10,
                duration: 2.seconds,
                curve: Curves.easeInOut), // Float effect

        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildBottomControls(
      BuildContext context, bool isDark, OnboardingItem item) {
    final isLastPage = _currentPage == _items.length - 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
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
                style: AppTheme.h1(isDark).copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            AnimatedSwitcher(
              duration: 400.ms,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: Text(
                item.description,
                key: ValueKey('desc_${_items.indexOf(item)}'),
                style: AppTheme.body(isDark)
                    .copyWith(color: isDark ? Colors.white70 : Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),

            // Indicator & Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.only(right: 6),
                      height: 6,
                      width: _currentPage == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? item.accentColor
                            : (isDark ? Colors.white24 : Colors.black12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),

                // FAB / Button
                GestureDetector(
                  onTap: _nextPage,
                  child: AnimatedContainer(
                    duration: 300.ms,
                    height: 64,
                    width: isLastPage ? 160 : 64,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arrow Icon
                        AnimatedOpacity(
                          duration: 200.ms,
                          opacity: isLastPage ? 0 : 1,
                          child: Icon(
                            LucideIcons.arrowRight,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                        // Get Started Text
                        AnimatedOpacity(
                          duration: 200.ms,
                          opacity: isLastPage ? 1 : 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Get Started",
                                style: TextStyle(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildIconPlaceholder(OnboardingItem item, bool isDark) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: item.accentColor.withValues(alpha: 0.1),
        border: Border.all(
          color: item.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: 64,
          color: item.accentColor,
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
  final Color accentColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.lottiePath,
  });
}
