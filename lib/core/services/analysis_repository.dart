import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/models/enums.dart';
import 'package:labelsafe_ai/core/services/supabase_service.dart';

class AnalysisRepository {
  static const String _storageKey = 'product_scans';
  final SupabaseService _supabaseService;

  AnalysisRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<void> saveAnalysis(ProductAnalysis analysis) async {
    // Save to local storage
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentScans = prefs.getStringList(_storageKey) ?? [];

    currentScans.insert(0, jsonEncode(analysis.toJson()));

    // Keep only last 50 scans to save space locally
    if (currentScans.length > 50) {
      currentScans.removeLast();
    }

    await prefs.setStringList(_storageKey, currentScans);

    // Sync to Supabase if user is logged in
    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.saveScanHistory(
          userId: user.id,
          productName: analysis.productName,
          brand: analysis.brand,
          category: analysis.category,
          rating: analysis.rating.name,
          score: analysis.score,
          overview: analysis.overview,
          ingredients: analysis.ingredients
              .map((i) => {
                    'name': i.name,
                    'technicalName': i.technicalName,
                    'rating': i.rating.name,
                    'explanation': i.explanation,
                    'function': i.function,
                  })
              .toList(),
          highlights: analysis.highlights,
          fatPercentage: analysis.fatPercentage,
          sugarPercentage: analysis.sugarPercentage,
          sodiumPercentage: analysis.sodiumPercentage,
          recommendation: analysis.recommendation,
          isIngredientsListComplete: analysis.isIngredientsListComplete,
        );
      }
    } catch (e) {
      print('Warning: Could not sync to Supabase: $e');
      // Don't fail the save operation if Supabase sync fails
    }
  }

  Future<List<ProductAnalysis>> getHistory() async {
    // Try to get from Supabase first if user is logged in
    final user = _supabaseService.currentUser;
    if (user != null) {
      try {
        final supabaseHistory = await _supabaseService.getScanHistory(
          userId: user.id,
          limit: 100,
        );

        final analyses = supabaseHistory
            .map((item) => _convertSupabaseToProductAnalysis(item))
            .toList();

        // Also sync local history to Supabase if needed
        await _syncLocalToSupabase();

        return analyses;
      } catch (e) {
        print('Error fetching from Supabase: $e');
        // Fall back to local storage
      }
    }

    // Fall back to local storage
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentScans = prefs.getStringList(_storageKey) ?? [];

    return currentScans
        .map((s) => ProductAnalysis.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    // Clear from Supabase if user is logged in
    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        await _supabaseService.clearAllScanHistory(userId: user.id);
      }
    } catch (e) {
      print('Warning: Could not clear Supabase history: $e');
    }
  }

  Future<void> _syncLocalToSupabase() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final List<String> localScans = prefs.getStringList(_storageKey) ?? [];

      // Get existing Supabase history
      final supabaseHistory =
          await _supabaseService.getScanHistory(userId: user.id, limit: 1000);
      final supabaseProductNames = supabaseHistory
          .map((item) => '${item['product_name']}_${item['brand']}')
          .toSet();

      // Sync only new scans
      for (final scanJson in localScans) {
        try {
          final analysis = ProductAnalysis.fromJson(jsonDecode(scanJson));
          final key = '${analysis.productName}_${analysis.brand}';

          if (!supabaseProductNames.contains(key)) {
            await _supabaseService.saveScanHistory(
              userId: user.id,
              productName: analysis.productName,
              brand: analysis.brand,
              category: analysis.category,
              rating: analysis.rating.name,
              score: analysis.score,
              overview: analysis.overview,
              ingredients: analysis.ingredients
                  .map((i) => {
                        'name': i.name,
                        'technicalName': i.technicalName,
                        'rating': i.rating.name,
                        'explanation': i.explanation,
                        'function': i.function,
                      })
                  .toList(),
              highlights: analysis.highlights,
              fatPercentage: analysis.fatPercentage,
              sugarPercentage: analysis.sugarPercentage,
              sodiumPercentage: analysis.sodiumPercentage,
              recommendation: analysis.recommendation,
              isIngredientsListComplete: analysis.isIngredientsListComplete,
            );
          }
        } catch (e) {
          print('Error syncing individual scan: $e');
        }
      }
    } catch (e) {
      print('Error in sync process: $e');
    }
  }

  ProductAnalysis _convertSupabaseToProductAnalysis(Map<String, dynamic> data) {
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
            final itemMap = item is Map ? item : jsonDecode(item);
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
}
