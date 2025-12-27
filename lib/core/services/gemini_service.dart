import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:labelsafe_ai/core/models/analysis_result.dart';
import 'package:labelsafe_ai/core/models/enums.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _modelName = dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

  GeminiService() {
    final keyLength = _apiKey.length;
    final maskedKey = keyLength > 8
        ? '${_apiKey.substring(0, 4)}...${_apiKey.substring(keyLength - 4)}'
        : 'INVALID';

    // Clean model name - some SDKs/configs prefix with models/
    final cleanModelName = _modelName.replaceAll('models/', '');

    print(
        'Initializing Gemini with model: $cleanModelName and key: $maskedKey');
    _model = GenerativeModel(
      model: cleanModelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    _debugListModels();
  }

  Future<void> _debugListModels() async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('--- AVAILABLE MODELS FOR THIS KEY ---');
        for (var m in data['models']) {
          print('Model: ${m['name']}');
        }
        print('-------------------------------------');
      } else {
        print(
            'Failed to list models: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Diagnostic Error (listing models): $e');
    }
  }

  Future<ProductAnalysis?> analyzeProductImage(
      File imageFile, String category) async {
    final imageBytes = await imageFile.readAsBytes();

    final prompt = _buildPrompt(category);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    try {
      if (_apiKey.isEmpty) {
        throw Exception(
            'Gemini API Key is missing. Please check your .env file.');
      }

      GenerateContentResponse response;
      try {
        response = await _model.generateContent(content);
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('not supported')) {
          print(
              'PRIMARY MODEL FAILED, TRYING STABLE FALLBACK (gemini-flash-latest)...');
          final fallbackModel = GenerativeModel(
            model: 'gemini-flash-latest',
            apiKey: _apiKey,
          );
          response = await fallbackModel.generateContent(content);
        } else {
          rethrow;
        }
      }

      var text = response.text;
      print('GEMINI RAW: $text');

      if (text == null || text.isEmpty) {
        print('Gemini returned an empty response.');
        return null;
      }

      // Sometimes Gemini wraps JSON in markdown blocks
      if (text.contains('```')) {
        text = text.replaceAll(RegExp(r'```json|```'), '').trim();
      }

      final jsonResponse = jsonDecode(text);
      return _parseAnalysis(jsonResponse);
    } catch (e) {
      print('CRITICAL: Gemini Analysis Error: $e');
      return null;
    }
  }

  // For web platform - accepts bytes directly
  Future<ProductAnalysis?> analyzeProductImageFromBytes(
      Uint8List imageBytes, String category) async {
    final prompt = _buildPrompt(category);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    try {
      if (_apiKey.isEmpty) {
        throw Exception(
            'Gemini API Key is missing. Please check your .env file.');
      }

      GenerateContentResponse response;
      try {
        response = await _model.generateContent(content);
      } catch (e) {
        if (e.toString().contains('not found') ||
            e.toString().contains('not supported')) {
          print(
              'PRIMARY MODEL FAILED, TRYING STABLE FALLBACK (gemini-flash-latest)...');
          final fallbackModel = GenerativeModel(
            model: 'gemini-flash-latest',
            apiKey: _apiKey,
          );
          response = await fallbackModel.generateContent(content);
        } else {
          rethrow;
        }
      }

      var text = response.text;
      print('GEMINI RAW: $text');

      if (text == null || text.isEmpty) {
        print('Gemini returned an empty response.');
        return null;
      }

      if (text.contains('```')) {
        text = text.replaceAll(RegExp(r'```json|```'), '').trim();
      }

      final jsonResponse = jsonDecode(text);
      return _parseAnalysis(jsonResponse);
    } catch (e) {
      print('CRITICAL: Gemini Analysis Error: $e');
      return null;
    }
  }

  String _buildPrompt(String category) {
    return '''
Analyze this $category product label. Focus PRIMARILY on INGREDIENTS safety (EU/WHO standards).

SCORING PRIORITY (in order):
1. INGREDIENTS SAFETY (60% weight) - Harmful additives = major penalty
2. SUGAR CONTENT (25% weight) - High sugar = major penalty
3. Fat content & overall (15% weight)

CRITICAL PENALTIES:
- ANY harmful ingredient (artificial colors, HFCS, BHA/BHT, parabens, MSG, sodium nitrite, artificial sweeteners) = score below 50
- HIGH SUGAR (>15g/100g or sugar in top 3 ingredients) = score below 60, rating "caution" or "avoid"
- VERY HIGH SUGAR (>25g/100g or sugar is #1 ingredient) = score below 40, rating "avoid"

JSON OUTPUT ONLY:
{
  "productName": "string",
  "brand": "string",
  "rating": "safe"|"caution"|"avoid",
  "category": "$category",
  "overview": "2 sentences focusing on ingredient/sugar concerns",
  "score": 0-100,
  "highlights": ["max 4 items - prioritize ingredient & sugar warnings"],
  "fatPercentage": 0-100,
  "sugarPercentage": 0-100,
  "recommendation": "Buy/Avoid/Limit - reason based on ingredients & sugar",
  "isIngredientsListComplete": true/false,
  "ingredients": [{"name":"string","technicalName":"string","rating":"safe|caution|avoid","explanation":"max 60 chars","function":"string"}]
}

STRICT RULES:
- 1 "avoid" ingredient = max score 50, rating "avoid"
- 2+ "caution" ingredients = max score 65, rating "caution"
- Sugar >20g/100g = rating "avoid" (highlight "Very High Sugar")
- Sugar 10-20g/100g = rating "caution" (highlight "High Sugar")
- Good nutrition does NOT offset bad ingredients or high sugar
- Artificial colors (Red 40, Yellow 5/6, Blue 1) = always "avoid"
- Added sugars (HFCS, dextrose, maltose, sucrose) in top 5 = "caution"
- Score 100 only if ALL ingredients natural AND sugar <5g/100g
''';
  }

  ProductAnalysis _parseAnalysis(Map<String, dynamic> json) {
    return ProductAnalysis(
      productName: json['productName'] ?? 'Unknown Product',
      brand: json['brand'] ?? 'Unknown Brand',
      rating: _parseSafetyBadge(json['rating']),
      category: json['category'] ?? 'General',
      overview: json['overview'] ?? 'No overview available.',
      score: (json['score'] ?? 0).toDouble(),
      highlights: List<String>.from(json['highlights'] ?? []),
      fatPercentage: (json['fatPercentage'] ?? 0).toDouble(),
      sugarPercentage: (json['sugarPercentage'] ?? 0).toDouble(),
      recommendation: json['recommendation'] ?? 'No recommendation available',
      isIngredientsListComplete: json['isIngredientsListComplete'] ?? true,
      ingredients: (json['ingredients'] as List? ?? [])
          .map((i) => IngredientDetail(
                name: i['name'] ?? 'Unknown',
                technicalName: i['technicalName'] ?? '',
                rating: _parseSafetyBadge(i['rating']),
                explanation: i['explanation'] ?? '',
                function: i['function'] ?? '',
              ))
          .toList(),
    );
  }

  SafetyBadge _parseSafetyBadge(String? rating) {
    switch (rating?.toLowerCase()) {
      case 'safe':
        return SafetyBadge.safe;
      case 'caution':
        return SafetyBadge.caution;
      case 'avoid':
        return SafetyBadge.avoid;
      default:
        return SafetyBadge.caution;
    }
  }
}
