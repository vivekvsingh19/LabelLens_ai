import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:labelsafe_ai/core/models/subscription_models.dart';
import 'package:labelsafe_ai/core/services/revenuecat_service.dart';
import 'package:labelsafe_ai/core/providers/supabase_providers.dart';

/// Provides access to the RevenueCat service
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Stream provider for customer info updates
final customerInfoStreamProvider = StreamProvider<CustomerInfo>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.customerInfoStream;
});

/// Provider for current subscription status
final subscriptionStatusProvider =
    StateNotifierProvider<SubscriptionStatusNotifier, AsyncValue<SubscriptionStatus>>(
        (ref) {
  return SubscriptionStatusNotifier(ref);
});

class SubscriptionStatusNotifier
    extends StateNotifier<AsyncValue<SubscriptionStatus>> {
  final Ref _ref;
  StreamSubscription<CustomerInfo>? _subscription;

  SubscriptionStatusNotifier(this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final service = _ref.read(revenueCatServiceProvider);
      final status = await service.getSubscriptionStatus();
      state = AsyncValue.data(status);

      // Listen to customer info changes
      _subscription = service.customerInfoStream.listen((customerInfo) {
        final entitlement =
            customerInfo.entitlements.active[RevenueCatService.entitlementId];
        state = AsyncValue.data(SubscriptionStatus.fromEntitlement(entitlement));
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(revenueCatServiceProvider);
      final status = await service.getSubscriptionStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider to check if user has premium access
final hasPremiumAccessProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(subscriptionStatusProvider);
  return statusAsync.when(
    data: (status) => status.isActive,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for available subscription packages
final subscriptionPackagesProvider =
    FutureProvider<List<SubscriptionPackage>>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getSubscriptionPackages();
});

/// Provider for offerings
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

/// Purchase state notifier for handling purchases
final purchaseStateProvider =
    StateNotifierProvider<PurchaseStateNotifier, PurchaseState>((ref) {
  return PurchaseStateNotifier(ref);
});

enum PurchaseStatus { idle, loading, success, error, cancelled }

class PurchaseState {
  final PurchaseStatus status;
  final String? message;
  final PurchaseResult? result;

  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.message,
    this.result,
  });

  PurchaseState copyWith({
    PurchaseStatus? status,
    String? message,
    PurchaseResult? result,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      message: message ?? this.message,
      result: result ?? this.result,
    );
  }
}

class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;

  PurchaseStateNotifier(this._ref) : super(const PurchaseState());

  Future<bool> purchase(Package package) async {
    state = const PurchaseState(status: PurchaseStatus.loading);

    try {
      final service = _ref.read(revenueCatServiceProvider);
      final result = await service.purchasePackage(package);

      if (result.success) {
        state = PurchaseState(
          status: PurchaseStatus.success,
          message: result.message,
          result: result,
        );
        // Refresh subscription status
        _ref.read(subscriptionStatusProvider.notifier).refresh();
        return true;
      } else if (result.wasCancelled) {
        state = PurchaseState(
          status: PurchaseStatus.cancelled,
          message: result.message,
          result: result,
        );
        return false;
      } else {
        state = PurchaseState(
          status: PurchaseStatus.error,
          message: result.message,
          result: result,
        );
        return false;
      }
    } catch (e) {
      state = PurchaseState(
        status: PurchaseStatus.error,
        message: 'Purchase failed: $e',
      );
      return false;
    }
  }

  Future<RestoreResult> restorePurchases() async {
    state = const PurchaseState(status: PurchaseStatus.loading);

    try {
      final service = _ref.read(revenueCatServiceProvider);
      final result = await service.restorePurchases();

      if (result.success) {
        state = PurchaseState(
          status: result.hasPremium ? PurchaseStatus.success : PurchaseStatus.idle,
          message: result.message,
        );
        // Refresh subscription status
        _ref.read(subscriptionStatusProvider.notifier).refresh();
      } else {
        state = PurchaseState(
          status: PurchaseStatus.error,
          message: result.message,
        );
      }

      return result;
    } catch (e) {
      state = PurchaseState(
        status: PurchaseStatus.error,
        message: 'Restore failed: $e',
      );
      return RestoreResult(
        success: false,
        hasPremium: false,
        message: 'Restore failed: $e',
      );
    }
  }

  void reset() {
    state = const PurchaseState();
  }
}

/// Provider to sync RevenueCat with Supabase user
final revenueCatUserSyncProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    try {
      await service.login(user.id);

      // Set user attributes
      await service.setUserAttributes(
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
      );

      debugPrint('RevenueCat synced with user: ${user.id}');
    } catch (e) {
      debugPrint('Failed to sync RevenueCat with user: $e');
    }
  }
});

/// Provider for checking feature access
final featureAccessProvider =
    Provider.family<bool, String>((ref, featureId) {
  final statusAsync = ref.watch(subscriptionStatusProvider);

  return statusAsync.when(
    data: (status) {
      switch (featureId) {
        case 'unlimited_scans':
        case 'advanced_analysis':
        case 'export_data':
          return status.isPremiumOrAbove;
        case 'priority_support':
          return status.isPro;
        default:
          return true; // Free features
      }
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for remaining free scans (for free tier limits)
final remainingFreeScansProvider =
    StateNotifierProvider<RemainingScansNotifier, int>((ref) {
  return RemainingScansNotifier();
});

class RemainingScansNotifier extends StateNotifier<int> {
  RemainingScansNotifier() : super(FreeTierLimits.maxScansPerDay);

  void decrementScan() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void resetDaily() {
    state = FreeTierLimits.maxScansPerDay;
  }

  bool get canScan => state > 0;
}

/// Provider to check if user can perform a scan
final canPerformScanProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(subscriptionStatusProvider);
  final remainingScans = ref.watch(remainingFreeScansProvider);

  return statusAsync.when(
    data: (status) {
      if (status.isPremiumOrAbove) {
        return true; // Unlimited for premium
      }
      return remainingScans > 0;
    },
    loading: () => true, // Allow while loading
    error: (_, __) => remainingScans > 0,
  );
});
