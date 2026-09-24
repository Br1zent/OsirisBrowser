import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/presentation/screens/browser/anti_fingerprint_js.dart';

void main() {
  group('AntiFingerprintJS.buildUserScript', () {
    test('runs at document start in all frames', () {
      final script = AntiFingerprintJS.buildUserScript();

      expect(script.injectionTime, UserScriptInjectionTime.AT_DOCUMENT_START);
      expect(script.forMainFrameOnly, isFalse);
      expect(script.groupName, 'osiris-privacy');
    });

    test('includes cookie blocking only when cookies are disabled', () {
      final enabled = AntiFingerprintJS.buildUserScript(cookiesEnabled: true);
      final disabled = AntiFingerprintJS.buildUserScript(cookiesEnabled: false);

      expect(enabled.source, isNot(contains("defineProperty(document, 'cookie'")));
      expect(disabled.source, contains("defineProperty(document, 'cookie'"));
    });
  });
}
