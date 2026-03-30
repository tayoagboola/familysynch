import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Entitlement identifier configured in the RevenueCat dashboard.
const _kProEntitlement = 'pro';

/// RevenueCat offering identifier (set in dashboard, or use 'default').
const _kDefaultOffering = 'default';

class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _initialised = false;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> init({
    required String appleApiKey,
    required String googleApiKey,
  }) async {
    if (_initialised) return;
    await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.error);

    final config = PurchasesConfiguration(
      Platform.isIOS ? appleApiKey : googleApiKey,
    );
    await Purchases.configure(config);
    _initialised = true;
  }

  /// Identify the user so purchases are tied to their account.
  Future<void> identifyUser(String userId) async {
    await Purchases.logIn(userId);
  }

  Future<void> resetUser() async {
    await Purchases.logOut();
  }

  /// Returns true if the user has an active Pro entitlement.
  Future<bool> isPro() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_kProEntitlement);
    } catch (_) {
      return false;
    }
  }

  /// Fetches the default offering from RevenueCat.
  Future<Offering?> getOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(_kDefaultOffering) ??
          offerings.current;
    } catch (e) {
      debugPrint('RevenueCat getOffering error: $e');
      return null;
    }
  }

  /// Purchase a package. Returns true on success.
  Future<bool> purchase(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      debugPrint('RevenueCat purchase error: $e');
      return false;
    } catch (e) {
      debugPrint('RevenueCat purchase error: $e');
      return false;
    }
  }

  /// Restore purchases (required by App Store guidelines).
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_kProEntitlement);
    } catch (e) {
      debugPrint('RevenueCat restore error: $e');
      return false;
    }
  }
}
