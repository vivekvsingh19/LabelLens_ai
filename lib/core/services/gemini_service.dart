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
Analyze this $category product label. Focus on INGREDIENTS safety (EU/WHO standards).

SCORING:
1. INGREDIENTS SAFETY (60%) - Harmful additives = major penalty
2. SUGAR CONTENT (20%) - High sugar = penalty
3. SODIUM CONTENT (10%) - High sodium = penalty
4. Fat & overall (10%)

JSON OUTPUT ONLY:
{
  "productName": "string",
  "brand": "string",
  "rating": "safe"|"caution"|"avoid",
  "category": "$category",
  "overview": "1 sentence, 15 words max",
  "score": 0-100,
  "highlights": ["3 items max, 4 words each"],
  "fatPercentage": 0-100,
  "sugarPercentage": 0-100,
  "sodiumPercentage": 0-100,
  "recommendation": "5 words max",
  "isIngredientsListComplete": true/false,
  "ingredients": [{"name":"string","technicalName":"E-number or chemical name","rating":"safe|caution|avoid","explanation":"Why good/bad for health in 8-12 words","function":"Sweetener|Preservative|Color|Emulsifier|etc"}]
}

INGREDIENT EXPLANATION EXAMPLES:
- "May cause hyperactivity in children, linked to allergies"
- "Natural thickener, safe for regular consumption"
- "Excess intake linked to obesity and diabetes"
- "Artificial preservative, may cause digestive issues"
- "Natural antioxidant, beneficial for health"

RULES:
- 1 "avoid" ingredient = max score 50
- 2+ "caution" = max score 65
- Sugar >20g/100g = "avoid"
- Artificial colors = always "avoid"
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
      sodiumPercentage: (json['sodiumPercentage'] ?? 0).toDouble(),
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
