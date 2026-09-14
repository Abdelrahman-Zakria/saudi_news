import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  static const String removeAdsId = 'remove_ads_pro';
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  bool _isPro = false;
  bool get isPro => _isPro;

  final _proStatusController = StreamController<bool>.broadcast();
  Stream<bool> get proStatusStream => _proStatusController.stream;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro_user') ?? false;
    _proStatusController.add(_isPro);

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => dev.log("IAP Error: $error"),
    );

    // Try to restore purchases quietly on startup to handle re-installs
    if (await _iap.isAvailable()) {
      await _iap.restorePurchases();
    }
  }

  Future<void> buyRemoveAds() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails({removeAdsId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      dev.log("Product not found");
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == removeAdsId) {
          _verifyAndEnablePro();
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _verifyAndEnablePro() async {
    _isPro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro_user', true);
    _proStatusController.add(true);
    dev.log("PRO status enabled and saved");
  }

  void dispose() {
    _subscription.cancel();
    _proStatusController.close();
  }
}
