import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/presentation/screens/browser/navigation_policy.dart';

void main() {
  group('isAllowedBrowserNavigationUrl', () {
    test('allows HTTP and HTTPS URLs with hosts', () {
      expect(isAllowedBrowserNavigationUrl('http://example.com'), isTrue);
      expect(isAllowedBrowserNavigationUrl('https://example.com/path?q=1'), isTrue);
    });

    test('allows only the blank about page', () {
      expect(isAllowedBrowserNavigationUrl('about:blank'), isTrue);
      expect(isAllowedBrowserNavigationUrl('about:blank?x=1'), isFalse);
    });

    test('rejects executable, local, and native application schemes', () {
      expect(isAllowedBrowserNavigationUrl('javascript:alert(1)'), isFalse);
      expect(isAllowedBrowserNavigationUrl('file:///etc/passwd'), isFalse);
      expect(isAllowedBrowserNavigationUrl('data:text/html,<script>1</script>'), isFalse);
      expect(isAllowedBrowserNavigationUrl('intent://example.com/#Intent;end'), isFalse);
      expect(isAllowedBrowserNavigationUrl('mailto:test@example.com'), isFalse);
    });

    test('rejects malformed web URLs and embedded credentials', () {
      expect(isAllowedBrowserNavigationUrl('https:///missing-host'), isFalse);
      expect(isAllowedBrowserNavigationUrl('https://user:pass@example.com'), isFalse);
      expect(isAllowedBrowserNavigationUrl('not a url'), isFalse);
    });
  });
}
