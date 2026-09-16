import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'iap_service.dart';

/// AdMob test ad configuration. Replace these IDs with production IDs before release.
class AdIds {
  static String get banner =>
      _isAndroid ? 'ca-app-pub-3940256099942544/6300978111' :
      'ca-app-pub-6520884181780729/1519042280';

  static String get directoryNative =>
      _isAndroid ? 'ca-app-pub-6520884181780729/6346102790' :
      'ca-app-pub-6520884181780729/1277608949';

  static String get interstitial =>
      _isAndroid ? 'ca-app-pub-3940256099942544/1033173712' :
      'ca-app-pub-6520884181780729/4340646741';
  static String get appOpen =>
      _isAndroid ? 'ca-app-pub-3940256099942544/925739592793755' :
      'ca-app-pub-6520884181780729/3027565075';

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}

class AdService with WidgetsBindingObserver {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  Timer? _appOpenTimer;
  bool _isShowingFullScreenAd = false;
  bool _initialized = false;
  bool _hasShownInitialAppOpen = false;
  bool _isAppInForeground = true;
  DateTime? _lastAppOpenShownAt;

  Future<void> initialize() async {
    if (_initialized) return;
    
    if (IAPService().isPro) return;

    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await MobileAds.instance.initialize();
    _loadAppOpenAd();
    _loadInterstitialAd();

    // App Open every 6 minutes
    _appOpenTimer = Timer.periodic(const Duration(minutes: 4), (_) {
      _showAppOpenAdInternal();
      _loadAppOpenAd();
    });

    IAPService().proStatusStream.listen((isPro) {
      if (isPro) dispose();
    });
  }

  void _loadAppOpenAd() {
    if (IAPService().isPro) return;
    if (_appOpenAd != null) return;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          if (!_hasShownInitialAppOpen) {
            Future<void>.delayed(const Duration(milliseconds: 1500), () {
              if (_isAppInForeground) _showAppOpenAdInternal();
            });
          }
        },
        onAdFailedToLoad: (_) => _appOpenAd = null,
      ),
    );
  }

  void _loadInterstitialAd() {
    if (IAPService().isPro) return;
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

  void _showAppOpenAdInternal() {
    if (IAPService().isPro || _isShowingFullScreenAd || _appOpenAd == null) return;
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

  /// Manually show an interstitial ad
  void showInterstitialAd() {
    if (IAPService().isPro || _isShowingFullScreenAd || _interstitialAd == null) return;
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
    if (IAPService().isPro) return;
    _isAppInForeground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      _loadAppOpenAd();
      if (!_hasShownInitialAppOpen ||
          _lastAppOpenShownAt == null ||
          DateTime.now().difference(_lastAppOpenShownAt!) >=
              const Duration(minutes: 6)) {
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (_isAppInForeground) _showAppOpenAdInternal();
        });
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenTimer?.cancel();
    _appOpenAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd = null;
    _interstitialAd = null;
    _initialized = false;
  }
}

class AdBanner extends StatefulWidget {
  final String? adUnitId;
  const AdBanner({super.key, this.adUnitId});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    if (!IAPService().isPro) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    _banner = BannerAd(
      adUnitId: widget.adUnitId ?? AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _banner = null;
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: IAPService().proStatusStream,
      initialData: IAPService().isPro,
      builder: (context, snapshot) {
        final isPro = snapshot.data ?? false;
        if (isPro || _banner == null) return const SizedBox.shrink();
        
        return Container(
          width: _banner!.size.width.toDouble(),
          height: _banner!.size.height.toDouble(),
          alignment: Alignment.center,
          child: AdWidget(ad: _banner!),
        );
      },
    );
  }
}

class AdNative extends StatefulWidget {
  final String? adUnitId;
  final String factoryId;

  const AdNative({
    super.key, 
    this.adUnitId,
    this.factoryId = 'listTile',
  });

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!IAPService().isPro) {
      _loadAd();
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId ?? AdIds.directoryNative,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NativeAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: IAPService().proStatusStream,
      initialData: IAPService().isPro,
      builder: (context, snapshot) {
        final isPro = snapshot.data ?? false;
        if (isPro || !_isAdLoaded || _nativeAd == null) return const SizedBox.shrink();

        return Container(
          height: 150,
          alignment: Alignment.center,
          child: AdWidget(ad: _nativeAd!),
        );
      },
    );
  }
}
