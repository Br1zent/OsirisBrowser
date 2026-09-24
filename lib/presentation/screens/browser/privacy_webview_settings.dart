import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/privacy_settings.dart';

InAppWebViewSettings buildPrivacyWebViewSettings(PrivacySettings settings) {
  final userAgent = AppConstants.userAgents[settings.userAgent] ??
      AppConstants.userAgents['Chrome (Windows)']!;
  return InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: true,
    allowsInlineMediaPlayback: false,
    javaScriptEnabled: settings.javascriptEnabled,
    userAgent: userAgent,
    cacheEnabled: false,
    clearCache: true,
    thirdPartyCookiesEnabled: !settings.blockThirdPartyCookies,
    blockNetworkImage: false,
    disableHorizontalScroll: false,
    disableVerticalScroll: false,
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    allowContentAccess: false,
    allowFileAccess: false,
    allowFileAccessFromFileURLs: false,
    allowUniversalAccessFromFileURLs: false,
    geolocationEnabled: false,
    useHybridComposition: true,
    loadWithOverviewMode: true,
    useWideViewPort: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
    safeBrowsingEnabled: true,
  );
}

bool supportsThirdPartyCookieControl(TargetPlatform platform) =>
    platform == TargetPlatform.android;
