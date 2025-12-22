import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';

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
      title: "Scan Labels",
      description:
          "Decode ingredients and nutritional facts with AI-powered analysis in seconds.",
      icon: LucideIcons.scanLine,
      lottiePath: 'assets/animations/scan.json',
    ),
    OnboardingItem(
      title: "Stay Safe",
      description:
          "Identify hidden additives, allergens, and potentially harmful chemicals.",
      icon: LucideIcons.shieldCheck,
      lottiePath: 'assets/animations/shield.json',
    ),
    OnboardingItem(
      title: "Smart Insights",
      description:
          "Make informed consumption choices with personalized recommendations.",
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Background Gradient Blob
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 5.seconds),
          ),

          // Main Content
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
                      return _buildPage(_items[index], isDark, index);
                    },
                  ),
                ),
                _buildFooter(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            isDark ? 'assets/images/dark.png' : 'assets/images/light.png',
            height: 28,
            fit: BoxFit.contain,
          ),

          // Skip button
          TextButton(
            onPressed: () => context.go('/home'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Skip",
              style: AppTheme.bodySmall(isDark).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, bool isDark, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey(index), // Force animation replay on page change
        children: [
          const Spacer(flex: 2),

          // Icon / Lottie
          SizedBox(
            height: 280,
            width: 280,
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
              .animate()
              .fade(duration: 600.ms)
              .scale(delay: 200.ms, begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 48),

          // Title
          Text(
            item.title,
            style: AppTheme.h1(isDark).copyWith(
              fontSize: 32,
              letterSpacing: -1.0,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fade(duration: 600.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: AppTheme.body(isDark).copyWith(
              fontSize: 16,
              height: 1.5,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fade(duration: 600.ms, delay: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildIconPlaceholder(OnboardingItem item, bool isDark) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.accentPrimary.withOpacity(0.1),
            AppTheme.accentSecondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: 64,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => _buildProgressIndicator(index, isDark),
            ),
          ),

          const SizedBox(height: 32),

          // CTA Button
          _buildCTAButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int index, bool isDark) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 24 : 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isActive
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context, bool isDark) {
    final isLastPage = _currentPage == _items.length - 1;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (isLastPage) {
            await PreferencesService().setOnboardingComplete();
            if (context.mounted) context.go('/login');
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? "Get Started" : "Continue",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastPage ? LucideIcons.arrowRight : LucideIcons.chevronRight,
              size: 18,
            ),
          ],
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
