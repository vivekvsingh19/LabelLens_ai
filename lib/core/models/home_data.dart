import 'package:labelsafe_ai/core/models/enums.dart';

class RecentScan {
  final String productName;
  final SafetyBadge rating;
  final DateTime scannedAt;

  RecentScan({
    required this.productName,
    required this.rating,
    required this.scannedAt,
  });
}

class DailyFoodSafetySummary {
  final String status; // "Low exposure", "Moderate exposure", "High exposure"
  final String detail; // e.g., "1 product high in added sugar"

  DailyFoodSafetySummary({
    required this.status,
    required this.detail,
  });
}

class FoodSafetyScore {
  final int score; // 0-100
  final String trend; // "↑", "↓", "→"
  final String period; // "This week"

  FoodSafetyScore({
    required this.score,
    required this.trend,
    required this.period,
  });
}

class HomeData {
  final List<RecentScan> recentScans;
  final DailyFoodSafetySummary dailySummary;
  final FoodSafetyScore safetyScore;
  final String dailyInsight;
  final bool isFirstTime;
  final bool showPremiumTease;
  final int scanCount;

  HomeData({
    required this.recentScans,
    required this.dailySummary,
    required this.safetyScore,
    required this.dailyInsight,
    required this.isFirstTime,
    required this.showPremiumTease,
    required this.scanCount,
  });

  static HomeData mock() {
    // Mock data for development
    final now = DateTime.now();
    return HomeData(
      recentScans: [
        RecentScan(
          productName: "Cornflakes",
          rating: SafetyBadge.caution,
          scannedAt: now.subtract(const Duration(hours: 2)),
        ),
        RecentScan(
          productName: "Protein Bar",
          rating: SafetyBadge.avoid,
          scannedAt: now.subtract(const Duration(days: 1)),
        ),
        RecentScan(
          productName: "Greek Yogurt",
          rating: SafetyBadge.safe,
          scannedAt: now.subtract(const Duration(days: 2)),
        ),
      ],
      dailySummary: DailyFoodSafetySummary(
        status: "Moderate exposure",
        detail: "1 product high in added sugar",
      ),
      safetyScore: FoodSafetyScore(
        score: 72,
        trend: "↑",
        period: "This week",
      ),
      dailyInsight: "Added sugars often appear under multiple names.",
      isFirstTime: false,
      showPremiumTease: true,
      scanCount: 5,
    );
  }

  static HomeData empty() {
    return HomeData(
      recentScans: [],
      dailySummary: DailyFoodSafetySummary(
        status: "",
        detail: "",
      ),
      safetyScore: FoodSafetyScore(
        score: 0,
        trend: "→",
        period: "",
      ),
      dailyInsight: "",
      isFirstTime: true,
      showPremiumTease: false,
      scanCount: 0,
    );
  }
}

class DailyInsights {
  static final List<String> insights = [
    "Added sugars often appear under multiple names.",
    "Preservatives extend shelf life but may cause sensitivities.",
    "Natural flavors can still contain synthetic compounds.",
    "Processed seed oils are high in omega-6 fatty acids.",
    "Artificial colors are linked to hyperactivity in children.",
    "Sodium benzoate can form benzene when combined with vitamin C.",
    "High-fructose corn syrup is metabolized differently than regular sugar.",
    "Carrageenan may cause digestive inflammation in sensitive individuals.",
  ];

  static String getTodayInsight() {
    // Rotate based on day of year
    final dayOfYear = DateTime.now()
        .difference(
          DateTime(DateTime.now().year, 1, 1),
        )
        .inDays;
    return insights[dayOfYear % insights.length];
  }
}

