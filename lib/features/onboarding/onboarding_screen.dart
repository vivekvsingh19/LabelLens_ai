import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Global Safety Standards',
      description:
          'We analyze products against FDA, EFSA, and UK regulations to keep you safe.',
      icon: Icons.public_outlined,
      image:
          'https://images.unsplash.com/photo-1576091160550-217359f5188c?auto=format&fit=crop&q=80&w=1000',
    ),
    OnboardingStep(
      title: 'Precision Personalization',
      description:
          'Tailored alerts for your allergies, skin type, and lifestyle goals.',
      icon: Icons.person_search_outlined,
      image:
          'https://images.unsplash.com/photo-1540555700478-4be289fbecee?auto=format&fit=crop&q=80&w=1000',
    ),
    OnboardingStep(
      title: 'Transparency First',
      description:
          'Decode complex chemical labels into plain, understandable language.',
      icon: Icons.biotech_outlined,
      image:
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=1000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Optional: Add a subtle overlay or background image here if needed
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.lightTextPrimary)
                                .withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _steps[index].icon,
                            size: 100,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.lightTextPrimary,
                          )
                              .animate(key: ValueKey(index))
                              .scale(
                                  duration: 600.ms, curve: Curves.easeOutBack)
                              .fadeIn(),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          _steps[index].title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.lightTextPrimary,
                              ),
                        )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        Text(
                          _steps[index].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        )
                            .animate(key: ValueKey('desc_$index'))
                            .fadeIn(delay: 400.ms)
                            .slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? (isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.lightTextPrimary)
                            : (isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _steps.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    } else {
                      context.go('/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.lightTextPrimary,
                    foregroundColor: isDark
                        ? AppTheme.darkBackground
                        : AppTheme.lightBackground,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentPage == _steps.length - 1
                        ? 'GET STARTED'
                        : 'CONTINUE',
                    style: const TextStyle(
                        letterSpacing: 1.5, fontWeight: FontWeight.w900),
                  ),
                ).animate().fadeIn(delay: 1.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final String image;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.image,
  });
}
