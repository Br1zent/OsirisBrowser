import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/presentation/screens/browser/browser_url_privacy.dart';

void main() {
  group('TrackerUrlPolicy', () {
    test('matches canonical hostname boundaries, case and trailing dot', () {
      expect(TrackerUrlPolicy.isBlocked('https://DOUBLECLICK.NET./pixel'), isTrue);
      expect(TrackerUrlPolicy.isBlocked('https://a.doubleclick.net/pixel'), isTrue);
      expect(TrackerUrlPolicy.isBlocked('https://doubleclick.net.evil.test/'), isFalse);
    });

    test('does not match tracker text in the URL path or query', () {
      expect(TrackerUrlPolicy.isBlocked('https://example.test/?next=doubleclick.net'), isFalse);
      expect(TrackerUrlPolicy.isBlocked('https://example.test/doubleclick.net'), isFalse);
    });

    test('matches only Facebook pixel /tr endpoints', () {
      expect(
          TrackerUrlPolicy.isBlocked('https://facebook.com/tr?id=123'), isTrue);
      expect(
          TrackerUrlPolicy.isBlocked('https://www.facebook.com/tr/'), isTrue);
      expect(TrackerUrlPolicy.isBlocked('https://facebook.com/profile/tr'),
          isFalse);
      expect(
          TrackerUrlPolicy.isBlocked('https://facebook.com.evil.test/tr'),
          isFalse);
      expect(
          TrackerUrlPolicy.isBlocked('https://facebook.com/?next=/tr'), isFalse);
    });
  });

  test('removes fragments and redacts credential query values for history', () {
    final result = BrowserUrlPrivacy.forHistory(
      'https://login.example/callback?code=secret&state=ok&access_token=abc#id_token=def',
    );

    expect(result, contains('code=%5BREDACTED%5D'));
    expect(result, contains('access_token=%5BREDACTED%5D'));
    expect(result, contains('state=ok'));
    expect(result, isNot(contains('secret')));
    expect(result, isNot(contains('abc')));
    expect(result, isNot(contains('id_token')));
    expect(result, isNot(contains('#')));
  });
}
