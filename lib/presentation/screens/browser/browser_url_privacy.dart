/// URL handling for the existing tracker check and history.
///
/// Dart's Uri parser lowercases hosts but does not perform IDNA conversion.
/// Therefore this ASCII ruleset does not equate Unicode and punycode labels.
class TrackerUrlPolicy {
  TrackerUrlPolicy._();

  static const Set<String> blockedHosts = {
    'google-analytics.com',
    'googletagmanager.com',
    'doubleclick.net',
    'connect.facebook.net',
    'analytics.twitter.com',
    'static.ads-twitter.com',
    'snap.licdn.com',
    'scorecardresearch.com',
    'quantserve.com',
    'adnxs.com',
    'adsrvr.org',
    'googlesyndication.com',
    'rubiconproject.com',
    'openx.net',
    'pubmatic.com',
    'advertising.com',
  };

  static bool isBlocked(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'\.+$'), '');
    if (blockedHosts.any(
        (domain) => host == domain || host.endsWith('.$domain'))) {
      return true;
    }

    final isFacebookHost =
        host == 'facebook.com' || host == 'www.facebook.com';
    final path = uri.path.toLowerCase();
    return isFacebookHost && (path == '/tr' || path.startsWith('/tr/'));
  }
}

class BrowserUrlPrivacy {
  BrowserUrlPrivacy._();

  static const Set<String> _sensitiveQueryNames = {
    'access_token',
    'auth',
    'authorization',
    'code',
    'id_token',
    'oauth_token',
    'password',
    'refresh_token',
    'reset_token',
    'token',
  };

  /// Drops fragments and replaces known credential parameters before history.
  static String forHistory(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return '';
    final query = uri.queryParametersAll;
    final sanitized = <String, List<String>>{};
    for (final entry in query.entries) {
      final sensitive = _sensitiveQueryNames.contains(entry.key.toLowerCase());
      sanitized[entry.key] = sensitive
          ? List<String>.filled(entry.value.length, '[REDACTED]')
          : entry.value;
    }
    return uri
        .replace(
          queryParameters: sanitized.isEmpty ? null : sanitized,
          fragment: '',
        )
        .toString();
  }
}
