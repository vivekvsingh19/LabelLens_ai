import 'package:labelsafe_ai/core/models/enums.dart';

class ProductAnalysis {
  final String productName;
  final String brand;
  final SafetyBadge rating;
  final String category;
  final String overview;
  final double score; // 0-100
  final List<IngredientDetail> ingredients;
  final List<String> highlights;
  final DateTime date;
  final double fatPercentage;
  final double sugarPercentage;
  final double sodiumPercentage;
  final String recommendation;
  final bool isIngredientsListComplete;

  ProductAnalysis({
    required this.productName,
    required this.brand,
    required this.rating,
    required this.category,
    required this.overview,
    required this.score,
    required this.ingredients,
    required this.highlights,
    this.fatPercentage = 0.0,
    this.sugarPercentage = 0.0,
    this.sodiumPercentage = 0.0,
    this.recommendation = 'No recommendation available',
    this.isIngredientsListComplete = true,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'brand': brand,
        'rating': rating.name,
        'category': category,
        'overview': overview,
        'score': score,
        'highlights': highlights,
        'date': date.toIso8601String(),
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'fatPercentage': fatPercentage,
        'sugarPercentage': sugarPercentage,
        'sodiumPercentage': sodiumPercentage,
        'recommendation': recommendation,
        'isIngredientsListComplete': isIngredientsListComplete,
      };

  factory ProductAnalysis.fromJson(Map<String, dynamic> json) =>
      ProductAnalysis(
        productName: json['productName'],
        brand: json['brand'],
        rating: SafetyBadge.values.byName(json['rating']),
        category: json['category'],
        overview: json['overview'],
        score: json['score'].toDouble(),
        highlights: List<String>.from(json['highlights']),
        date: DateTime.parse(json['date']),
        ingredients: (json['ingredients'] as List)
            .map((i) => IngredientDetail.fromJson(i))
            .toList(),
        fatPercentage: (json['fatPercentage'] ?? 0).toDouble(),
        sugarPercentage: (json['sugarPercentage'] ?? 0).toDouble(),
        sodiumPercentage: (json['sodiumPercentage'] ?? 0).toDouble(),
        recommendation: json['recommendation'] ?? 'No recommendation available',
        isIngredientsListComplete: json['isIngredientsListComplete'] ?? true,
      );
}

class IngredientDetail {
  final String name;
  final String technicalName;
  final SafetyBadge rating;
  final String explanation;
  final String function;

  IngredientDetail({
    required this.name,
    required this.technicalName,
    required this.rating,
    required this.explanation,
    required this.function,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'technicalName': technicalName,
        'rating': rating.name,
        'explanation': explanation,
        'function': function,
      };

  factory IngredientDetail.fromJson(Map<String, dynamic> json) =>
      IngredientDetail(
        name: json['name'],
        technicalName: json['technicalName'],
        rating: SafetyBadge.values.byName(json['rating']),
        explanation: json['explanation'],
        function: json['function'],
      );
}
