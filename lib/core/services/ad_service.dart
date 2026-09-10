import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob test ad configuration. Replace these IDs with production IDs before release.
class AdIds {
  static String get banner =>
      _isAndroid ? 'ca-app-pub-3940256099942544/6300978111' :
      'ca-app-pub-6520884181780729/1519042280';
  static String get interstitial =>
      _isAndroid ? 'ca-app-pub-3940256099942544/1033173712' :
      'ca-app-pub-6520884181780729/4340646741';
  static String get appOpen =>
      _isAndroid ? 'ca-app-pub-3940256099942544/925739592793755' :
      'ca-app-pub-6520884181780729/3027565075';

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}

class AdService with WidgetsBindingObserver {
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  Timer? _appOpenTimer;
  Timer? _interstitialTimer;
  bool _isShowingFullScreenAd = false;
  bool _initialized = false;
  bool _hasShownInitialAppOpen = false;
  bool _isAppInForeground = true;
  DateTime? _lastAppOpenShownAt;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await MobileAds.instance.initialize();
    _loadAppOpenAd();
    _loadInterstitialAd();

    // App Open on launch, then once every minute.
    _appOpenTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _showAppOpenAd();
      _loadAppOpenAd();
    });
    // Interstitial once every 30 seconds.
    _interstitialTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _showInterstitialAd();
      _loadInterstitialAd();
    });
  }

  void _loadAppOpenAd() {
    if (_appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (!_hasShownInitialAppOpen) {
            // Wait until the first Flutter frame is visible before presenting.
            Future<void>.delayed(const Duration(milliseconds: 800), () {
              if (_isAppInForeground) _showAppOpenAd();
            });
          }
        },
        onAdFailedToLoad: (_) => _appOpenAd = null,
      ),
    );
  }

  void _loadInterstitialAd() {
    if (_interstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _showAppOpenAd() {
    if (_isShowingFullScreenAd || _appOpenAd == null) return;
    final ad = _appOpenAd!;
    _appOpenAd = null;
    _hasShownInitialAppOpen = true;
    _lastAppOpenShownAt = DateTime.now();
    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _loadAppOpenAd();
      },
    );
    ad.show();
  }

  void _showInterstitialAd() {
    if (_isShowingFullScreenAd || _interstitialAd == null) return;
    final ad = _interstitialAd!;
    _interstitialAd = null;
    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    ad.show();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      _loadAppOpenAd();
      if (!_hasShownInitialAppOpen ||
          _lastAppOpenShownAt == null ||
          DateTime.now().difference(_lastAppOpenShownAt!) >=
              const Duration(minutes: 1)) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (_isAppInForeground) _showAppOpenAd();
        });
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenTimer?.cancel();
    _interstitialTimer?.cancel();
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
  }
}

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  late final BannerAd _banner;

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  @override
  void dispose() {
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _banner.size.width.toDouble(),
      height: _banner.size.height.toDouble(),
      child: AdWidget(ad: _banner),
    );
  }
}
