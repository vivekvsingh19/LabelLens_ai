import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define palette colors
  static const Color coralAccent = Color(0xFFCF7556);

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Scan Labels",
      description:
          "Instantly scan food labels with your camera to get instant safety analysis.",
      icon: LucideIcons.scanLine,
      color: Colors.blue,
      accentColor: Colors.blue,
    ),
    OnboardingItem(
      title: "Check Safety",
      description:
          "Get AI-powered safety ratings and detect harmful chemicals & allergens.",
      icon: LucideIcons.shieldAlert,
      color: coralAccent,
      accentColor: Colors.orange,
    ),
    OnboardingItem(
      title: "Stay Healthy",
      description:
          "Get personalized health recommendations and track your eating habits.",
      icon: LucideIcons.heart,
      color: Colors.red,
      accentColor: coralAccent,
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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
          // Animated background gradient
          _buildAnimatedBackground(isDark, activeItem),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDark),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _items.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildPageContent(_items[index], isDark, index);
                    },
                  ),
                ),

                // Bottom controls
                _buildBottomControls(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark, OnboardingItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withValues(alpha: 0.08),
            (isDark ? AppTheme.darkBackground : AppTheme.lightBackground),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo with coral accent
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  coralAccent.withValues(alpha: 0.2),
                  coralAccent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: coralAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.shield,
                size: 24,
                color: coralAccent,
              ),
            ),
          ),

          // Progress indicator with coral accent
          if (_currentPage < _items.length - 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: coralAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: coralAccent.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                "${_currentPage + 1}/${_items.length}",
                style: AppTheme.bodySmall(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: coralAccent,
                ),
              ),
            ),

          // Skip button with coral
          if (_currentPage < _items.length - 1)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _completeOnboarding,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "Skip",
                    style: AppTheme.bodySmall(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: coralAccent,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingItem item, bool isDark, int pageIndex) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          item.color.withValues(alpha: 0.2),
                          item.color.withValues(alpha: 0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        size: 70,
                        color: item.color,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),

            // Title with slide animation
            TweenAnimationBuilder<Offset>(
              tween: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ),
              duration: const Duration(milliseconds: 700),
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(0, offset.dy * 20),
                  child: Opacity(
                    opacity: 1 - (offset.dy.abs() * 0.5),
                    child: child,
                  ),
                );
              },
              child: Text(
                item.title,
                style: AppTheme.h1(isDark).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Description with fade animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  item.description,
                  style: AppTheme.body(isDark).copyWith(
                    fontSize: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.7),
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    final isLastPage = _currentPage == _items.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => GestureDetector(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _items[index].color
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Primary action button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                decoration: BoxDecoration(
                  color: _items[_currentPage].color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _items[_currentPage].color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _nextPage,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Text(
                        isLastPage ? "Get Started" : "Continue",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
  final Color color;
  final Color accentColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}
