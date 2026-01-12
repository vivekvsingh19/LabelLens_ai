// SUPABASE INTEGRATION EXAMPLES FOR HISTORY SCREEN
// 
// This file shows how to enhance the history screen to use Supabase data
// directly. The current implementation uses AnalysisRepository which 
// automatically syncs with Supabase.

// === OPTION 1: Keep Current Implementation (Recommended) ===
// The current setup automatically syncs with Supabase:
// 
// In history_screen.dart:
// final historyAsync = ref.watch(scanHistoryProvider);
// 
// This provider uses AnalysisRepository which:
// - Fetches from Supabase if user is logged in
// - Falls back to local storage
// - Automatically syncs local to cloud on login
// - No changes needed to UI!

// === OPTION 2: Use Supabase Provider Directly ===
// If you want to use Supabase data exclusively for logged-in users:
//
// Replace in history_screen.dart:
/*
@override
Widget build(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final location = GoRouterState.of(context).matchedLocation;
  final showTooltip = ref.watch(showScanTooltipProvider);
  final currentUser = ref.watch(currentUserProvider); // NEW

  // Use Supabase provider if logged in, otherwise local provider
  final historyAsync = currentUser != null 
    ? ref.watch(supabaseScanHistoryProvider) // NEW
    : ref.watch(scanHistoryProvider);        // EXISTING

  // Rest of the code remains the same...
}
*/

// === OPTION 3: Add Delete Functionality ===
// Add this method to delete scans:
//
/*
Future<void> _deleteScan(BuildContext context, WidgetRef ref, String scanId) async {
  try {
    // If user is logged in, delete from Supabase
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      await ref.read(deleteScanProvider(scanId).future);
    }
    
    // Also delete from local storage
    final repo = ref.read(analysisRepositoryProvider);
    // You'd need to add a delete method to AnalysisRepository
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan deleted')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
*/

// === OPTION 4: Add Clear History Functionality ===
// Add this method to clear all scans:
//
/*
Future<void> _clearAllHistory(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Clear All History?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        await ref.read(clearAllScansProvider.future);
      }
      
      final repo = ref.read(analysisRepositoryProvider);
      await repo.clearHistory();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All history cleared')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
*/

// === IMPORTS TO ADD IF USING SUPABASE ===
/*
import 'package:labelsafe_ai/core/providers/supabase_providers.dart';
*/

// === TESTING SUPABASE CONNECTION ===
// Add this to your main.dart or a test screen to verify connection:
//
/*
FutureBuilder<void>(
  future: Future.delayed(Duration.zero).then((_) async {
    final supabase = SupabaseService();
    final user = supabase.currentUser;
    print('Current user: ${user?.email}');
    if (user != null) {
      final history = await supabase.getScanHistory(userId: user.id, limit: 5);
      print('Scan history count: ${history.length}');
    }
  }),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox.shrink();
  },
)
*/
