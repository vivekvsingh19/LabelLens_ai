import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/ui_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  print("ENV LOADED ROOT: GEMINI_MODEL=${dotenv.env['GEMINI_MODEL']}");

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  runApp(const ProviderScope(child: LabelSafeAIApp()));
}

class LabelSafeAIApp extends ConsumerWidget {
  const LabelSafeAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LabelSafe AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return UpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: Duration.zero),
          showIgnore: false,
          showLater: false,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
