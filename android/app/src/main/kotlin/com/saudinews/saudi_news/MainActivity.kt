package com.saudinews.saudi_news

import android.content.Intent
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val factory = ListTileNativeAdFactory(layoutInflater)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "listTile", factory)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }
}

class ListTileNativeAdFactory(private val layoutInflater: LayoutInflater) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val context = layoutInflater.context
        val adView = NativeAdView(context)
        
        adView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )

        val container = LinearLayout(context)
        container.orientation = LinearLayout.HORIZONTAL
        container.setPadding(40, 40, 40, 40)
        container.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        adView.addView(container)

        // Icon
        val iconView = ImageView(context)
        val iconParams = LinearLayout.LayoutParams(140, 140)
        iconView.layoutParams = iconParams
        iconView.scaleType = ImageView.ScaleType.CENTER_INSIDE
        container.addView(iconView)
        adView.iconView = iconView

        // Text Container
        val textContainer = LinearLayout(context)
        textContainer.orientation = LinearLayout.VERTICAL
        val textParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        textParams.marginStart = 30
        textContainer.layoutParams = textParams
        container.addView(textContainer)

        // Headline
        val headlineView = TextView(context)
        headlineView.textSize = 16f
        headlineView.setTextColor(Color.BLACK)
        headlineView.setTypeface(null, android.graphics.Typeface.BOLD)
        textContainer.addView(headlineView)
        adView.headlineView = headlineView

        // Body
        val bodyView = TextView(context)
        bodyView.textSize = 12f
        bodyView.setTextColor(Color.GRAY)
        bodyView.maxLines = 2
        textContainer.addView(bodyView)
        adView.bodyView = bodyView

        // Action Button
        val actionButton = Button(context)
        val actionParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        actionParams.marginStart = 20
        actionButton.layoutParams = actionParams
        actionButton.setBackgroundColor(Color.parseColor("#006C35")) // Saudi Green
        actionButton.setTextColor(Color.WHITE)
        actionButton.textSize = 12f
        container.addView(actionButton)
        adView.callToActionView = actionButton

        // Map data safely
        val headline = nativeAd.headline
        if (headline != null) {
            (adView.headlineView as TextView).text = headline
            adView.headlineView?.visibility = View.VISIBLE
        } else {
            adView.headlineView?.visibility = View.GONE
        }

        val body = nativeAd.body
        if (body != null) {
            (adView.bodyView as TextView).text = body
            adView.bodyView?.visibility = View.VISIBLE
        } else {
            adView.bodyView?.visibility = View.GONE
        }

        val callToAction = nativeAd.callToAction
        if (callToAction != null) {
            (adView.callToActionView as Button).text = callToAction
            adView.callToActionView?.visibility = View.VISIBLE
        } else {
            adView.callToActionView?.visibility = View.GONE
        }
        
        val icon = nativeAd.icon
        if (icon != null) {
            (adView.iconView as ImageView).setImageDrawable(icon.drawable)
            adView.iconView?.visibility = View.VISIBLE
        } else {
            adView.iconView?.visibility = View.GONE
        }

        adView.setNativeAd(nativeAd)
        return adView
    }
}
