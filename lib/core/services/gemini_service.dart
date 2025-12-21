import 'dart:convert';
import 'dart:io';
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

  String _buildPrompt(String category) {
    return '''
    Act as an UNCOMPROMISING, STRICT International Food Safety Inspector & Toxicologist.

    TASK:
    1. Perform ultra-precise OCR on the provided image of a $category product label.
    2. Identify the Brand and Product Name.
    3. Extract EVERY single ingredient listed on the label. Do not skip any.
    4. For each ingredient:
       - Identify its common name and technical/INCI name.
       - Determine its function using standard categories: "Stabilizer", "Preservative", "Sweetener", "Emulsifier", "Colorant", "Flavor enhancer", "Thickener", "Surfactant", "Antioxidant", or "Nutrient".
       - Evaluate safety based on the STRICTEST international standards (specifically EU EFSA, WHO, and California Prop 65).
       - If an ingredient is banned or restricted in Europe/Japan but allowed locally, mark it as "CAUTION" or "AVOID".
       - Rate its safety ("safe", "caution", "avoid").
       - Provide a brutal, truth-telling ONE-LINE explanation (max 80 characters). If it's carcinogenic, say "Carcinogenic - linked to cancer". If it's an endocrine disruptor, say "Disrupts hormones - long-term reproductive harm". Be direct and mention the specific long-term health impact.
    5. Calculate a strict Safety Score (0-100). Penalize heavily for harmful additives.
    6. Generate a 2-3 sentence overview. Be direct about long-term health risks.
    7. Identify key highlights (e.g., "Contains Banned Dyes", "High Sugar", "Paraben-Free").

    CRITICAL RULES:
    - BE STRICT. Do not sugarcoat. If a product has 1% harmful ingredient, it is NOT safe.
    - Flag "Avoid" ingredients like Parabens, Phthalates, BHA/BHT, High Fructose Corn Syrup, Artificial Dyes, and hidden sugars immediately.
    - Be transparent about percentage if inferred context suggests high quantity (e.g. first 3 ingredients).
    - Respond ONLY in valid JSON.

    JSON STRUCTURE:
    {
      "productName": "string",
      "brand": "string",
      "rating": "safe" | "caution" | "avoid",
      "category": "string",
      "overview": "string",
      "score": 85,
      "highlights": ["string"],
      "ingredients": [
        {
          "name": "Common Name",
          "technicalName": "Technical/INCI Name",
          "rating": "safe" | "caution" | "avoid",
          "explanation": "Strict explanation referencing EU/WHO if applicable",
          "function": "Ingredient function"
        }
      ]
    }
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
