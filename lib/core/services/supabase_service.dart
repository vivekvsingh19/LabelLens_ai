import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  // Auth helper methods
  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: 'io.labelsafe.ai://login-callback',
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Product scan history methods
  Future<String?> saveScanHistory({
    required String userId,
    required String productName,
    required String brand,
    required String category,
    required String rating,
    required double score,
    required String overview,
    required List<Map<String, dynamic>> ingredients,
    required List<String> highlights,
    required double fatPercentage,
    required double sugarPercentage,
    required double sodiumPercentage,
    required String recommendation,
    required bool isIngredientsListComplete,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'product_name': productName,
        'brand': brand,
        'category': category,
        'rating': rating,
        'score': score,
        'overview': overview,
        'ingredients': ingredients,
        'highlights': highlights,
        'fat_percentage': fatPercentage,
        'sugar_percentage': sugarPercentage,
        'sodium_percentage': sodiumPercentage,
        'recommendation': recommendation,
        'is_ingredients_list_complete': isIngredientsListComplete,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await client.from('scan_history').insert(data).select();
      return response[0]['id'].toString();
    } catch (e) {
      print('Error saving scan history: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScanHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('scan_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching scan history: $e');
      rethrow;
    }
  }

  Future<void> deleteScanHistory({required String scanId}) async {
    try {
      await client.from('scan_history').delete().eq('id', scanId);
    } catch (e) {
      print('Error deleting scan history: $e');
      rethrow;
    }
  }

  Future<void> clearAllScanHistory({required String userId}) async {
    try {
      await client.from('scan_history').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing all scan history: $e');
      rethrow;
    }
  }
}
