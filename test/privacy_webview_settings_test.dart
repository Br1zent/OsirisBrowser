import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/constants/app_constants.dart';
import 'package:osiris_browser/domain/entities/privacy_settings.dart';
import 'package:osiris_browser/presentation/screens/browser/privacy_webview_settings.dart';

void main() {
  test('browser settings reflect JavaScript, UA, and cookie choices', () {
    final settings = buildPrivacyWebViewSettings(const PrivacySettings(
      javascriptEnabled: false,
      userAgent: 'Firefox (Windows)',
      blockThirdPartyCookies: true,
    ));

    expect(settings.javaScriptEnabled, isFalse);
    expect(settings.userAgent, AppConstants.userAgents['Firefox (Windows)']);
    expect(settings.thirdPartyCookiesEnabled, isFalse);
    expect(settings.clearCache, isTrue);

    final liveUpdate = buildPrivacyWebViewSettings(
      const PrivacySettings(javascriptEnabled: false),
      clearCache: false,
    );
    expect(liveUpdate.clearCache, isFalse);
  });

  test('third-party cookie control is exposed only on Android', () {
    expect(
      supportsThirdPartyCookieControl(TargetPlatform.android),
      isTrue,
    );
    expect(supportsThirdPartyCookieControl(TargetPlatform.iOS), isFalse);
    expect(supportsThirdPartyCookieControl(TargetPlatform.macOS), isFalse);
  });
}
