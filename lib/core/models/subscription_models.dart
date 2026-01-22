import 'package:purchases_flutter/purchases_flutter.dart';

/// Subscription tier types
enum SubscriptionTier {
  free,
  premium,
  pro,
}

/// Subscription status model
class SubscriptionStatus {
  final bool isActive;
  final SubscriptionTier tier;
  final DateTime? expirationDate;
  final bool willRenew;
  final String? productIdentifier;
  final EntitlementInfo? entitlementInfo;

  const SubscriptionStatus({
    required this.isActive,
    required this.tier,
    this.expirationDate,
    this.willRenew = false,
    this.productIdentifier,
    this.entitlementInfo,
  });

  factory SubscriptionStatus.free() => const SubscriptionStatus(
        isActive: false,
        tier: SubscriptionTier.free,
      );

  factory SubscriptionStatus.fromEntitlement(EntitlementInfo? entitlement) {
    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionStatus.free();
    }

    final tier = _tierFromProductId(entitlement.productIdentifier);

    return SubscriptionStatus(
      isActive: entitlement.isActive,
      tier: tier,
      expirationDate: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      willRenew: entitlement.willRenew,
      productIdentifier: entitlement.productIdentifier,
      entitlementInfo: entitlement,
    );
  }

  static SubscriptionTier _tierFromProductId(String productId) {
    if (productId.contains('pro') || productId.contains('annual')) {
      return SubscriptionTier.pro;
    } else if (productId.contains('premium') || productId.contains('monthly')) {
      return SubscriptionTier.premium;
    }
    return SubscriptionTier.free;
  }

  bool get isPremiumOrAbove =>
      tier == SubscriptionTier.premium || tier == SubscriptionTier.pro;

  bool get isPro => tier == SubscriptionTier.pro;

  String get tierName {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  String get tierDescription {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Basic features with limited scans';
      case SubscriptionTier.premium:
        return 'Unlimited scans & advanced analysis';
      case SubscriptionTier.pro:
        return 'All features + priority support';
    }
  }
}

/// Package offering model for UI
class SubscriptionPackage {
  final String identifier;
  final String title;
  final String description;
  final String priceString;
  final double price;
  final String periodUnit;
  final int periodValue;
  final Package? rcPackage;
  final bool isBestValue;

  const SubscriptionPackage({
    required this.identifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.periodUnit,
    required this.periodValue,
    this.rcPackage,
    this.isBestValue = false,
  });

  factory SubscriptionPackage.fromRCPackage(Package package,
      {bool isBestValue = false}) {
    final product = package.storeProduct;

    String periodUnit = 'month';
    int periodValue = 1;

    if (package.packageType == PackageType.annual) {
      periodUnit = 'year';
      periodValue = 1;
    } else if (package.packageType == PackageType.sixMonth) {
      periodUnit = 'month';
      periodValue = 6;
    } else if (package.packageType == PackageType.threeMonth) {
      periodUnit = 'month';
      periodValue = 3;
    } else if (package.packageType == PackageType.weekly) {
      periodUnit = 'week';
      periodValue = 1;
    } else if (package.packageType == PackageType.lifetime) {
      periodUnit = 'lifetime';
      periodValue = 1;
    }

    return SubscriptionPackage(
      identifier: package.identifier,
      title: product.title,
      description: product.description,
      priceString: product.priceString,
      price: product.price,
      periodUnit: periodUnit,
      periodValue: periodValue,
      rcPackage: package,
      isBestValue: isBestValue,
    );
  }

  String get billingPeriod {
    if (periodUnit == 'lifetime') return 'One-time purchase';
    if (periodValue == 1) return 'per $periodUnit';
    return 'per $periodValue ${periodUnit}s';
  }
}

/// Free tier limits
class FreeTierLimits {
  static const int maxScansPerDay = 3;
  static const int maxHistoryItems = 10;
  static const bool canExportData = false;
  static const bool hasAdvancedAnalysis = false;
  static const bool hasPrioritySupport = false;
}

/// Premium tier features
class PremiumFeatures {
  static const int maxScansPerDay = -1; // Unlimited
  static const int maxHistoryItems = -1; // Unlimited
  static const bool canExportData = true;
  static const bool hasAdvancedAnalysis = true;
  static const bool hasPrioritySupport = false;
}

/// Pro tier features
class ProFeatures {
  static const int maxScansPerDay = -1; // Unlimited
  static const int maxHistoryItems = -1; // Unlimited
  static const bool canExportData = true;
  static const bool hasAdvancedAnalysis = true;
  static const bool hasPrioritySupport = true;
}
