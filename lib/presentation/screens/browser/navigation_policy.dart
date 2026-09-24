/// Returns whether a URL is safe to load inside the browser WebView.
bool isAllowedBrowserNavigationUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;

  if (uri.scheme == 'about') {
    return uri.toString() == 'about:blank';
  }

  return (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty;
}
