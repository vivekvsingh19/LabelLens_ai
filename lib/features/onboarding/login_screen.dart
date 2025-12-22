import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - MediaQuery.of(context).padding.vertical,
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.06),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.chevronLeft,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "Sign In",
                        style: AppTheme.h3(isDark).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Icon
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0, 0.4),
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0, 0.4),
                              ),
                              child: Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentPrimary.withOpacity(0.2),
                                        AppTheme.accentSecondary
                                            .withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.accentPrimary
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      LucideIcons.lock,
                                      size: 36,
                                      color: AppTheme.accentPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Title & Subtitle
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.1, 0.5),
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.1, 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome Back",
                                    style: AppTheme.h2(isDark).copyWith(
                                      fontSize: 32,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Sign in to your account to continue scanning and analyzing products",
                                    style: AppTheme.body(isDark).copyWith(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email Field
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 0.6),
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.2, 0.6),
                              ),
                              child: _buildTextField(
                                controller: _emailController,
                                label: "Email Address",
                                placeholder: "your@email.com",
                                icon: LucideIcons.mail,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.3, 0.7),
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.3, 0.7),
                              ),
                              child: _buildPasswordField(isDark),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Remember Me & Forgot Password
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.4, 0.8),
                            )),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.4, 0.8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _rememberMe = !_rememberMe);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _rememberMe
                                                  ? AppTheme.accentPrimary
                                                  : (isDark
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : Colors.black
                                                          .withOpacity(0.2)),
                                              width: _rememberMe ? 2 : 1,
                                            ),
                                            color: _rememberMe
                                                ? AppTheme.accentPrimary
                                                    .withOpacity(0.1)
                                                : Colors.transparent,
                                          ),
                                          child: _rememberMe
                                              ? const Center(
                                                  child: Icon(
                                                    LucideIcons.check,
                                                    size: 12,
                                                    color:
                                                        AppTheme.accentPrimary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Remember me",
                                          style: AppTheme.bodySmall(isDark)
                                              .copyWith(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to forgot password
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style:
                                          AppTheme.bodySmall(isDark).copyWith(
                                        fontSize: 13,
                                        color: AppTheme.accentPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.5, 0.9),
                  )),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 0.9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 24),
                      child: Column(
                        children: [
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentPrimary,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                disabledBackgroundColor:
                                    AppTheme.accentPrimary.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          isDark
                                              ? AppTheme.darkText
                                              : AppTheme.lightText,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          LucideIcons.arrowRight,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider with "or"
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "or continue with",
                                  style: AppTheme.bodySmall(isDark).copyWith(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Login Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildSocialButton(
                                  icon: LucideIcons.chrome,
                                  label: "Google",
                                  isDark: isDark,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSocialButton(
                                  icon: LucideIcons.apple,
                                  label: "Apple",
                                  isDark: isDark,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTheme.bodySmall(isDark).copyWith(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to sign up
                                },
                                child: Text(
                                  "Sign Up",
                                  style: AppTheme.bodySmall(isDark).copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.accentPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall(isDark).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            style: AppTheme.body(isDark).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTheme.body(isDark).copyWith(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.4),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppTheme.accentPrimary,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: AppTheme.bodySmall(isDark).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTheme.body(isDark).copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: AppTheme.body(isDark).copyWith(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.4),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  LucideIcons.key,
                  size: 20,
                  color: AppTheme.accentPrimary,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 20,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.12),
            width: 1,
          ),
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodySmall(isDark).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
