import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:labelsafe_ai/core/services/supabase_service.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/models/enums.dart';

/// Provides access to the Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Streams the current authentication state
final authStateStreamProvider =
    StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.authStateChanges;
});

/// Provides the current logged-in user
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.currentUser;
});

/// Fetches all scan history from Supabase for the current user
final supabaseScanHistoryProvider =
    FutureProvider<List<ProductAnalysis>>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return [];
  }

  try {
    final historyData = await supabase.getScanHistory(
      userId: user.id,
      limit: 100,
    );

    return historyData
        .map((item) => _convertSupabaseToProductAnalysis(item))
        .toList();
  } catch (e) {
    print('Error fetching Supabase scan history: $e');
    rethrow;
  }
});

/// Deletes a specific scan from Supabase
final deleteScanProvider = FutureProvider.family<void, String>((ref, scanId) async {
  final supabase = ref.watch(supabaseServiceProvider);
  await supabase.deleteScanHistory(scanId: scanId);
  // Invalidate the cache to refresh
  ref.invalidate(supabaseScanHistoryProvider);
});

/// Clears all scans for the current user from Supabase
final clearAllScansProvider = FutureProvider<void>((ref) async {
  final supabase = ref.watch(supabaseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return;

  await supabase.clearAllScanHistory(userId: user.id);
  ref.invalidate(supabaseScanHistoryProvider);
});

/// Helper function to convert Supabase data to ProductAnalysis
ProductAnalysis _convertSupabaseToProductAnalysis(
    Map<String, dynamic> data) {
  return ProductAnalysis(
    productName: data['product_name'] ?? '',
    brand: data['brand'] ?? '',
    rating: _parseRating(data['rating']),
    category: data['category'] ?? '',
    overview: data['overview'] ?? '',
    score: (data['score'] ?? 0).toDouble(),
    ingredients: _parseIngredients(data['ingredients']),
    highlights: List<String>.from(data['highlights'] ?? []),
    fatPercentage: (data['fat_percentage'] ?? 0).toDouble(),
    sugarPercentage: (data['sugar_percentage'] ?? 0).toDouble(),
    sodiumPercentage: (data['sodium_percentage'] ?? 0).toDouble(),
    recommendation: data['recommendation'] ?? 'No recommendation available',
    isIngredientsListComplete: data['is_ingredients_list_complete'] ?? true,
    date: DateTime.parse(data['created_at']),
  );
}

SafetyBadge _parseRating(dynamic rating) {
  try {
    if (rating is String) {
      return SafetyBadge.values.byName(rating);
    }
    return SafetyBadge.safe;
  } catch (e) {
    return SafetyBadge.safe;
  }
}

List<IngredientDetail> _parseIngredients(dynamic ingredients) {
  if (ingredients is! List) return [];
  return ingredients
      .map((item) {
        try {
          final itemMap = item is Map ? item : item;
          return IngredientDetail(
            name: itemMap['name'] ?? '',
            technicalName: itemMap['technicalName'] ?? '',
            rating: _parseRating(itemMap['rating']),
            explanation: itemMap['explanation'] ?? '',
            function: itemMap['function'] ?? '',
          );
        } catch (e) {
          return null;
        }
      })
      .whereType<IngredientDetail>()
      .toList();
}
