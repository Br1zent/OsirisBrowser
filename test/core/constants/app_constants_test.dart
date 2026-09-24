import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/constants/app_constants.dart';

void main() {
  test('searchUrl uses the selected engine and encodes the query', () {
    expect(
      AppConstants.searchUrl('Brave Search', 'privacy browser'),
      'https://search.brave.com/search?q=privacy%20browser',
    );
  });

  test('searchUrl falls back to DuckDuckGo for an unknown engine', () {
    expect(
      AppConstants.searchUrl('unknown', 'privacy'),
      'https://duckduckgo.com/?q=privacy',
    );
  });
}
