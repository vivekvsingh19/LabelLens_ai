import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';

class AnalysisRepository {
  static const String _storageKey = 'product_scans';

  Future<void> saveAnalysis(ProductAnalysis analysis) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentScans = prefs.getStringList(_storageKey) ?? [];

    currentScans.insert(0, jsonEncode(analysis.toJson()));

    // Keep only last 50 scans to save space
    if (currentScans.length > 50) {
      currentScans.removeLast();
    }

    await prefs.setStringList(_storageKey, currentScans);
  }

  Future<List<ProductAnalysis>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentScans = prefs.getStringList(_storageKey) ?? [];

    return currentScans
        .map((s) => ProductAnalysis.fromJson(jsonDecode(s)))
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
