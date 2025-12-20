import 'package:labelsafe_ai/core/models/enums.dart';

class ProductAnalysis {
  final String productName;
  final String brand;
  final SafetyBadge rating;
  final String category;
  final String overview;
  final double score; // 0-100
  final List<IngredientDetail> ingredients;
  final List<String> highlights; // positive or negative points

  ProductAnalysis({
    required this.productName,
    required this.brand,
    required this.rating,
    required this.category,
    required this.overview,
    required this.score,
    required this.ingredients,
    required this.highlights,
  });
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
}
