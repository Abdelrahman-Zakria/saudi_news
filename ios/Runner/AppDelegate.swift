import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)

    // Register Native Ad Factory with programmatic UI
    let listTileFactory = ListTileNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "listTile", nativeAdFactory: listTileFactory)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class ListTileNativeAdFactory : NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]?) -> UIView {
        let nativeAdView = GADNativeAdView()

        // Background
        nativeAdView.backgroundColor = .clear

        // Headline
        let headlineView = UILabel()
        headlineView.font = .boldSystemFont(ofSize: 16)
        headlineView.textColor = .black
        headlineView.text = nativeAd.headline
        nativeAdView.addSubview(headlineView)
        nativeAdView.headlineView = headlineView

        // Body
        let bodyView = UILabel()
        bodyView.font = .systemFont(ofSize: 12)
        bodyView.textColor = .gray
        bodyView.numberOfLines = 2
        bodyView.text = nativeAd.body
        nativeAdView.addSubview(bodyView)
        nativeAdView.bodyView = bodyView

        // Icon
        let iconView = UIImageView()
        iconView.image = nativeAd.icon?.image
        iconView.contentMode = .scaleAspectFit
        nativeAdView.addSubview(iconView)
        nativeAdView.iconView = iconView

        // Call to Action
        let callToActionView = UIButton(type: .system)
        callToActionView.setTitle(nativeAd.callToAction, for: .normal)
        callToActionView.titleLabel?.font = .boldSystemFont(ofSize: 14)
        callToActionView.backgroundColor = UIColor(red: 0.0, green: 0.42, blue: 0.21, alpha: 1.0) // Saudi Green
        callToActionView.setTitleColor(.white, for: .normal)
        callToActionView.layer.cornerRadius = 8
        nativeAdView.addSubview(callToActionView)
        nativeAdView.callToActionView = callToActionView

        // Layout constraints
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        callToActionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),

            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),

            bodyView.leadingAnchor.constraint(equalTo: headlineView.leadingAnchor),
            bodyView.trailingAnchor.constraint(equalTo: headlineView.trailingAnchor),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),

            callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            callToActionView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -16),
            callToActionView.widthAnchor.constraint(equalToConstant: 100),
            callToActionView.heightAnchor.constraint(equalToConstant: 36)
        ])

        nativeAdView.nativeAd = nativeAd
        return nativeAdView
    }
}
