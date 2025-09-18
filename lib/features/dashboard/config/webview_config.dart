import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Configuration class for InAppWebView settings
class WebViewConfig {
  /// Get default InAppWebView settings optimized for ERP application
  static InAppWebViewSettings get defaultSettings => InAppWebViewSettings(
    // Basic settings
    iframeAllow: "camera; microphone; geolocation;",
    javaScriptCanOpenWindowsAutomatically: true,
    useShouldOverrideUrlLoading: true,
    useShouldInterceptFetchRequest: true,
    supportZoom: false,
    transparentBackground: true,
    overScrollMode: OverScrollMode.ALWAYS,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    supportMultipleWindows: true,
    useShouldInterceptRequest: true,
    allowsInlineMediaPlayback: true,
    allowFileAccessFromFileURLs: true,
    allowsBackForwardNavigationGestures: true,

    // Prevent unnecessary reloads
    clearCache: false,
    cacheEnabled: true,

    // Handle file uploads properly
    mediaPlaybackRequiresUserGesture: false,
    allowsAirPlayForMediaPlayback: true,

    // Keep WebView state during app lifecycle changes
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    geolocationEnabled: true,

    // Security settings
    allowsLinkPreview: false,
    isFraudulentWebsiteWarningEnabled: false,

    // Performance settings
    minimumLogicalFontSize: 1,
    textZoom: 100,

    // User agent
    userAgent: _getUserAgent(),
  );

  /// Get optimized user agent for ERP application
  static String _getUserAgent() {
    return 'Mozilla/5.0 (Linux; Android 12; ${Platform.operatingSystem} Build/SP1A.210812.016; wv) '
        'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/140.0.7339.51 '
        'Mobile Safari/537.36 HybridERP/1.0';
  }
}
