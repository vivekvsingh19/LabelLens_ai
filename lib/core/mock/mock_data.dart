enum SafetyBadge { safe, caution, avoid }

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

class MockData {
  static ProductAnalysis getFoodAnalysis() {
    return ProductAnalysis(
      productName: "Premium Oat Milk",
      brand: "Earthly Harvest",
      rating: SafetyBadge.caution,
      category: "Food",
      score: 68,
      overview:
          "While high in fiber, this product contains acidity regulators and seed oils that may cause digestive discomfort.",
      highlights: [
        "High in Dietary Fiber",
        "Contains Processed Seed Oil",
        "Contains E340 Acidity Regulator"
      ],
      ingredients: [
        IngredientDetail(
          name: "Organic Oats",
          technicalName: "Avena Sativa",
          rating: SafetyBadge.safe,
          explanation:
              "Whole-grain ingredient, excellent source of beta-glucans.",
          function: "Main Base",
        ),
        IngredientDetail(
          name: "Canola Oil",
          technicalName: "Rapeseed Oil",
          rating: SafetyBadge.caution,
          explanation:
              "Highly processed oil; can be inflammatory for sensitive individuals.",
          function: "Emulsifier",
        ),
        IngredientDetail(
          name: "Dipotassium Phosphate",
          technicalName: "E340",
          rating: SafetyBadge.avoid,
          explanation:
              "Excessive consumption linked to calcium imbalance and kidney stress.",
          function: "Stabilizer",
        ),
      ],
    );
  }

  static ProductAnalysis getCosmeticAnalysis() {
    return ProductAnalysis(
      productName: "Glow Radiance Cleanser",
      brand: "Skin Luxe",
      rating: SafetyBadge.safe,
      category: "Cosmetics",
      score: 92,
      overview:
          "A very clean formulation free from sulfates and parabens. Highly suitable for sensitive skin.",
      highlights: [
        "Free from Sulfates",
        "Fragrance-Free",
        "Dermatologically Tested"
      ],
      ingredients: [
        IngredientDetail(
          name: "Hyaluronic Acid",
          technicalName: "Sodium Hyaluronate",
          rating: SafetyBadge.safe,
          explanation: "Superior hydrator that restores moisture levels.",
          function: "Humectant",
        ),
        IngredientDetail(
          name: "Glycerin",
          technicalName: "Glycerol",
          rating: SafetyBadge.safe,
          explanation:
              "Natural moisturizer that helps strengthen the skin barrier.",
          function: "Moisturizer",
        ),
        IngredientDetail(
          name: "Phenoxyethanol",
          technicalName: "Preservative",
          rating: SafetyBadge.caution,
          explanation:
              "Effective preservative; can cause mild irritation in high doses.",
          function: "Preservative",
        ),
      ],
    );
  }
}

// Minimalist class structure to fix previous import issues
class IngredientAnalysis extends IngredientDetail {
  IngredientAnalysis({
    required super.name,
    required super.technicalName,
    required super.rating,
    required super.explanation,
    required super.function,
  });
}
