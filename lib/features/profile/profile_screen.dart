import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labelsafe_ai/core/theme/app_theme.dart';
import 'package:labelsafe_ai/core/providers/ui_providers.dart';
import 'package:labelsafe_ai/core/services/preferences_service.dart';
import 'package:labelsafe_ai/core/services/supabase_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);
    final user = SupabaseService().currentUser;

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go('/home');
        },
        child: Scaffold(
          backgroundColor:
              isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
          appBar: AppBar(
            title: Text('SETTINGS',
                style: AppTheme.h2(isDark).copyWith(
                    letterSpacing: -1,
                    fontWeight: FontWeight.w900,
                    fontSize: 24)),
            centerTitle: false,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildUserHero(isDark, user),
                const SizedBox(height: 32),
                _buildThemeSelector(context, ref, isDark, currentTheme),
                const SizedBox(height: 32),
                _buildSettingsGroup(
                  isDark,
                  "ACCOUNT",
                  [
                    _SettingAction(LucideIcons.user, "Personal Details", null,
                        color: const Color(0xFF42A5F5)), // Blue
                    _SettingAction(
                        LucideIcons.shield, "Security & Privacy", "LOCKED",
                        color: const Color(0xFF66BB6A)), // Green
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsGroup(
                  isDark,
                  "PREFERENCES",
                  [
                    _SettingAction(LucideIcons.bell, "Notifications", "ON",
                        color: const Color(0xFFFFA726)), // Orange
                    _SettingAction(LucideIcons.globe, "Analysis Language", "EN",
                        color: const Color(0xFFAB47BC)), // Purple
                    _SettingAction(
                        LucideIcons.cpu, "AI Model Performance", "PRO",
                        color: const Color(0xFF26A69A)), // Teal
                  ],
                ),
                const SizedBox(height: 48),
                _buildLogoutButton(context, isDark),
                const SizedBox(height: 32),
                Text(
                  "BUILD 2.4.0 (BETA)",
                  style: AppTheme.caption(isDark)
                      .copyWith(fontSize: 8, letterSpacing: 3),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ));
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                boxShadow: AppTheme.premiumShadow(isDark),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SIGN OUT?",
                    style: AppTheme.h3(isDark).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to sign out? You'll need to sign in again to access your account.",
                    style: AppTheme.body(isDark).copyWith(
                      height: 1.5,
                      color: isDark
                          ? AppTheme.darkText.withValues(alpha: 0.7)
                          : AppTheme.lightText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusMedium),
                            ),
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: AppTheme.caption(isDark).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            try {
                              await SupabaseService().signOut();
                              await PreferencesService().setLoggedIn(false);
                              if (context.mounted) {
                                context.go('/login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sign out failed: $e'),
                                    backgroundColor: AppTheme.avoidColor,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.avoidColor,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusMedium),
                            ),
                            child: Center(
                              child: Text(
                                "SIGN OUT",
                                style: AppTheme.caption(isDark).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.avoidColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Center(
          child: Text(
            "SIGN OUT",
            style: AppTheme.caption(isDark).copyWith(
                color: AppTheme.avoidColor, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, WidgetRef ref, bool isDark, ThemeMode mode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text("APPEARANCE", style: AppTheme.caption(isDark)),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: AppTheme.softShadow(isDark),
          ),
          child: Row(
            children: [
              _buildThemeOption(ref, "Light", LucideIcons.sun, ThemeMode.light,
                  mode == ThemeMode.light, isDark),
              _buildThemeOption(ref, "Dark", LucideIcons.moon, ThemeMode.dark,
                  mode == ThemeMode.dark, isDark),
              _buildThemeOption(ref, "Auto", LucideIcons.monitor,
                  ThemeMode.system, mode == ThemeMode.system, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(WidgetRef ref, String label, IconData icon,
      ThemeMode mode, bool isSelected, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeModeProvider.notifier).setTheme(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: AppTheme.caption(isDark).copyWith(
                    fontSize: 7,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black)
                        : (isDark ? Colors.white38 : Colors.black38)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHero(bool isDark, dynamic user) {
    // Extract user info from Supabase user
    final userName = user?.userMetadata?['full_name'] ??
        user?.email?.split('@').first.toUpperCase() ??
        'USER';
    final userProfilePic = user?.userMetadata?['picture'];
    final userEmail = user?.email ?? 'No email';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.premiumShadow(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: userProfilePic == null
                  ? LinearGradient(
                      colors: isDark
                          ? [Colors.white, const Color(0xFFE0E0E0)]
                          : [Colors.black, const Color(0xFF424242)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: userProfilePic != null
                ? ClipOval(
                    child: Image.network(
                      userProfilePic,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [Colors.white, const Color(0xFFE0E0E0)]
                                  : [Colors.black, const Color(0xFF424242)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(LucideIcons.user,
                                size: 32,
                                color: isDark ? Colors.black : Colors.white),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(LucideIcons.user,
                        size: 32, color: isDark ? Colors.black : Colors.white)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName.toUpperCase(),
                    style: AppTheme.h2(isDark).copyWith(fontSize: 22),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(userEmail,
                    style: AppTheme.caption(isDark).copyWith(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5)
                        .withValues(alpha: 0.1), // Blue tint
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text("LOGGED IN",
                      style: AppTheme.caption(isDark).copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF42A5F5))), // Blue
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05, end: 0);
  }

  Widget _buildSettingsGroup(
      bool isDark, String title, List<_SettingAction> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTheme.caption(isDark)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: AppTheme.softShadow(isDark),
          ),
          child: Column(
            children: actions.asMap().entries.map((entry) {
              final idx = entry.key;
              final action = entry.value;
              return Column(
                children: [
                  _buildSettingItem(action, isDark),
                  if (idx != actions.length - 1)
                    const Divider(
                        height: 1, indent: 60, color: Colors.transparent),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(_SettingAction action, bool isDark) {
    final iconColor = action.color ??
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7);

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color?.withValues(alpha: 0.1) ??
                    (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(action.icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(action.label,
                style: AppTheme.bodyLarge(isDark).copyWith(fontSize: 15)),
            const Spacer(),
            if (action.value != null)
              Text(
                action.value!,
                style: AppTheme.caption(isDark)
                    .copyWith(fontSize: 8, color: AppTheme.accentPrimary),
              ),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight,
                size: 16,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _SettingAction {
  final IconData icon;
  final String label;
  final String? value;
  final Color? color;
  _SettingAction(this.icon, this.label, this.value, {this.color});
}
