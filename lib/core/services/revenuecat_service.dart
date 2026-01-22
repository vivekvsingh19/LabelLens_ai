import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:labelsafe_ai/core/models/subscription_models.dart';

/// RevenueCat service for managing subscriptions
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;

  /// Entitlement identifier for premium access
  static const String entitlementId = 'LabelSafe AI Pro';

  /// Product identifiers
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';
  static const String lifetimeProductId = 'lifetime';

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get API key from environment or use the provided one
      final apiKey = dotenv.env['REVENUECAT_API_KEY'] ??
          'test_mrkbeeTHSnKjVhwRxKRYweRfTIG';

      // Configure based on platform
      late PurchasesConfiguration configuration;

      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(apiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(apiKey);
      } else {
        // For other platforms, use default configuration
        configuration = PurchasesConfiguration(apiKey);
      }

      // Enable debug logs in development
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('RevenueCat initialization failed: $e');
      rethrow;
    }
  }

  /// Login user with their app user ID (e.g., Supabase user ID)
  Future<CustomerInfo> login(String appUserId) async {
    try {
      final result = await Purchases.logIn(appUserId);
      return result.customerInfo;
    } on PlatformException catch (e) {
      debugPrint('RevenueCat login failed: ${e.message}');
      rethrow;
    }
  }

  /// Logout user and reset to anonymous
  Future<CustomerInfo> logout() async {
    try {
      return await Purchases.logOut();
    } on PlatformException catch (e) {
      debugPrint('RevenueCat logout failed: ${e.message}');
      rethrow;
    }
  }

  /// Get current customer info
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      debugPrint('Failed to get customer info: ${e.message}');
      rethrow;
    }
  }

  /// Check if user has active subscription
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.active[entitlementId];
      return SubscriptionStatus.fromEntitlement(entitlement);
    } on PlatformException catch (e) {
      debugPrint('Failed to get subscription status: ${e.message}');
      return SubscriptionStatus.free();
    }
  }

  /// Check if user has premium entitlement
  Future<bool> hasPremiumAccess() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } on PlatformException catch (e) {
      debugPrint('Failed to check premium access: ${e.message}');
      return false;
    }
  }

  /// Get available offerings/packages
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      debugPrint('Failed to get offerings: ${e.message}');
      return null;
    }
  }

  /// Get subscription packages for display
  Future<List<SubscriptionPackage>> getSubscriptionPackages() async {
    try {
      final offerings = await getOfferings();
      final currentOffering = offerings?.current;

      if (currentOffering == null) {
        return [];
      }

      final packages = <SubscriptionPackage>[];

      // Add packages in preferred order: yearly (best value), monthly, lifetime
      final yearlyPackage = currentOffering.annual;
      final monthlyPackage = currentOffering.monthly;
      final lifetimePackage = currentOffering.lifetime;

      if (yearlyPackage != null) {
        packages.add(SubscriptionPackage.fromRCPackage(yearlyPackage,
            isBestValue: true));
      }

      if (monthlyPackage != null) {
        packages.add(SubscriptionPackage.fromRCPackage(monthlyPackage));
      }

      if (lifetimePackage != null) {
        packages.add(SubscriptionPackage.fromRCPackage(lifetimePackage));
      }

      // Also check for custom packages
      for (final package in currentOffering.availablePackages) {
        final isAlreadyAdded =
            packages.any((p) => p.identifier == package.identifier);
        if (!isAlreadyAdded) {
          packages.add(SubscriptionPackage.fromRCPackage(package));
        }
      }

      return packages;
    } catch (e) {
      debugPrint('Failed to get subscription packages: $e');
      return [];
    }
  }

  /// Purchase a package
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final hasPremium =
          customerInfo.entitlements.active.containsKey(entitlementId);

      return PurchaseResult(
        success: hasPremium,
        customerInfo: customerInfo,
        message: hasPremium ? 'Purchase successful!' : 'Purchase completed',
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      String message;
      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          message = 'Purchase was cancelled';
          break;
        case PurchasesErrorCode.paymentPendingError:
          message = 'Payment is pending. Please wait for confirmation.';
          break;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          message = 'You already own this product';
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          message = 'Purchase not allowed on this device';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          message = 'Invalid purchase. Please try again.';
          break;
        case PurchasesErrorCode.networkError:
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'Purchase failed: ${e.message}';
      }

      return PurchaseResult(
        success: false,
        message: message,
        errorCode: errorCode,
      );
    }
  }

  /// Restore purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasPremium =
          customerInfo.entitlements.active.containsKey(entitlementId);

      return RestoreResult(
        success: true,
        hasPremium: hasPremium,
        customerInfo: customerInfo,
        message: hasPremium
            ? 'Purchases restored successfully!'
            : 'No previous purchases found',
      );
    } on PlatformException catch (e) {
      debugPrint('Restore purchases failed: ${e.message}');
      return RestoreResult(
        success: false,
        hasPremium: false,
        message: 'Failed to restore purchases: ${e.message}',
      );
    }
  }

  /// Present RevenueCat Paywall
  Future<PaywallResult> presentPaywall() async {
    try {
      final paywallResult = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );
      return paywallResult;
    } on PlatformException catch (e) {
      debugPrint('Failed to present paywall: ${e.message}');
      rethrow;
    }
  }

  /// Present RevenueCat Paywall if needed (only if user doesn't have entitlement)
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        displayCloseButton: true,
      );
      return paywallResult;
    } on PlatformException catch (e) {
      debugPrint('Failed to present paywall: ${e.message}');
      rethrow;
    }
  }

  /// Present Customer Center for subscription management
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } on PlatformException catch (e) {
      debugPrint('Failed to present customer center: ${e.message}');
      rethrow;
    }
  }

  /// Listen to customer info updates
  Stream<CustomerInfo> get customerInfoStream {
    // Create a stream controller to handle customer info updates
    final controller = StreamController<CustomerInfo>.broadcast();

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      controller.add(customerInfo);
    });

    return controller.stream;
  }

  /// Set user attributes for analytics
  Future<void> setUserAttributes({
    String? email,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      if (email != null) {
        await Purchases.setEmail(email);
      }
      if (displayName != null) {
        await Purchases.setDisplayName(displayName);
      }
      if (phoneNumber != null) {
        await Purchases.setPhoneNumber(phoneNumber);
      }
    } catch (e) {
      debugPrint('Failed to set user attributes: $e');
    }
  }

  /// Set custom attributes
  Future<void> setCustomAttribute(String key, String value) async {
    try {
      await Purchases.setAttributes({key: value});
    } catch (e) {
      debugPrint('Failed to set custom attribute: $e');
    }
  }

  /// Sync purchases (useful for cross-platform)
  Future<CustomerInfo> syncPurchases() async {
    try {
      await Purchases.syncPurchases();
      return await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      debugPrint('Failed to sync purchases: ${e.message}');
      rethrow;
    }
  }

  /// Check if configured
  bool get isConfigured => _isInitialized;
}

/// Result of a purchase attempt
class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String message;
  final PurchasesErrorCode? errorCode;

  PurchaseResult({
    required this.success,
    this.customerInfo,
    required this.message,
    this.errorCode,
  });

  bool get wasCancelled =>
      errorCode == PurchasesErrorCode.purchaseCancelledError;
}

/// Result of a restore attempt
class RestoreResult {
  final bool success;
  final bool hasPremium;
  final CustomerInfo? customerInfo;
  final String message;

  RestoreResult({
    required this.success,
    required this.hasPremium,
    this.customerInfo,
    required this.message,
  });
}
