import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';
import 'package:labelsafe_ai/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final response =
            await SupabaseService().signUp(email: email, password: password);
        if (response.session != null) {
          if (mounted) {
            await PreferencesService().setLoggedIn(true);
            if (mounted) context.go('/home');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Account created! Please check your email to confirm if required.')),
            );
            setState(() {
              _isSignUp = false;
            });
          }
        }
      } else {
        await SupabaseService().signIn(email: email, password: password);
        if (mounted) {
          await PreferencesService().setLoggedIn(true);
          if (mounted) context.go('/home');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // Use Supabase's native OAuth flow for more reliable Google Sign-In
      final result = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.labelsafe.ai://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!result) {
        throw Exception('Failed to launch Google Sign-In');
      }

      // Listen for auth state changes
      final subscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && mounted) {
          debugPrint('Google Sign-In successful via OAuth');
          await PreferencesService().setLoggedIn(true);
          if (mounted) context.go('/home');
        }
      });

      // Clean up subscription after a delay
      Future.delayed(const Duration(seconds: 30), () {
        subscription.cancel();
      });
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.05),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 4.seconds),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.chevronLeft,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ).animate().fade().slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 40),

                    // Title Section
                    Text(
                      _isSignUp ? "Create\nAccount" : "Welcome\nBack",
                      style: AppTheme.h1(isDark).copyWith(
                        fontSize: 42,
                        height: 1.1,
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    Text(
                      _isSignUp
                          ? "Sign up to start tracking your consumption."
                          : "Login to sync your scan history and preferences.",
                      style: AppTheme.body(isDark).copyWith(
                        fontSize: 16,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.6),
                      ),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 40),

                    // Form
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: LucideIcons.mail,
                      isDark: isDark,
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: LucideIcons.lock,
                      isPassword: true,
                      isDark: isDark,
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Auth Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isSignUp ? "Sign Up" : "Sign In",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ).animate().fade(delay: 700.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: AppTheme.bodySmall(isDark).copyWith(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 750.ms),

                    const SizedBox(height: 16),

                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.mail,
                              size: 20,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign in with Google',
                              style: AppTheme.body(isDark).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 800.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Toggle Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp
                              ? "Already have an account? Sign In"
                              : "Don't have an account? Sign Up",
                          style: AppTheme.bodySmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 800.ms),

                    const SizedBox(height: 8),

                    // Skip Button
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          // Allow anonymous access, but don't set 'loggedIn' to true
                          // Maybe set 'onboardingComplete' though
                          await PreferencesService().setLoggedIn(false);
                          if (context.mounted) context.go('/home');
                        },
                        child: Text(
                          "Skip for now",
                          style: AppTheme.bodySmall(isDark).copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 900.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: AppTheme.body(isDark),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTheme.body(isDark).copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            icon,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
