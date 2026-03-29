class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Osiris Browser';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Browse Without a Trace';

  // Security
  static const int pbkdf2Iterations = 200000;
  static const int saltLength = 32;
  static const int ivLength = 16;
  static const int keyLength = 32; // 256 bits
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 64;
  static const String masterPasswordKey = 'osiris_master_password_hash';
  static const String encryptionSaltKey = 'osiris_encryption_salt';
  static const String dbEncryptionKeyKey = 'osiris_db_key';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Database
  static const String dbName = 'osiris_encrypted.db';
  static const int dbVersion = 1;

  // Default User Agents
  static const Map<String, String> userAgents = {
    'Chrome (Windows)':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Firefox (Windows)':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Safari (macOS)':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
    'Chrome (Android)':
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.144 Mobile Safari/537.36',
    'Generic Mobile':
        'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
  };

  // DNS over HTTPS Providers
  static const Map<String, String> dohProviders = {
    'Cloudflare': 'https://cloudflare-dns.com/dns-query',
    'Google': 'https://dns.google/dns-query',
    'Quad9': 'https://dns.quad9.net/dns-query',
    'NextDNS': 'https://dns.nextdns.io',
    'AdGuard': 'https://dns.adguard.com/dns-query',
  };

  // Auto-clear intervals
  static const Map<String, int> autoClearIntervals = {
    'Session only': 0,
    '1 Hour': 3600,
    '6 Hours': 21600,
    '24 Hours': 86400,
    'Never': -1,
  };

  // Quick Links (default)
  static const List<Map<String, String>> defaultQuickLinks = [
    {'title': 'DuckDuckGo', 'url': 'https://duckduckgo.com', 'icon': 'search'},
    {'title': 'ProtonMail', 'url': 'https://proton.me/mail', 'icon': 'email'},
    {'title': 'Wikipedia', 'url': 'https://wikipedia.org', 'icon': 'book'},
    {
      'title': 'Tor Project',
      'url': 'https://www.torproject.org',
      'icon': 'security'
    },
    {
      'title': 'Privacy Guides',
      'url': 'https://www.privacyguides.org',
      'icon': 'shield'
    },
    {
      'title': 'Signal',
      'url': 'https://signal.org',
      'icon': 'chat_bubble'
    },
  ];

  // Search Engines
  static const Map<String, String> searchEngines = {
    'DuckDuckGo': 'https://duckduckgo.com/?q=',
    'Brave Search': 'https://search.brave.com/search?q=',
    'Startpage': 'https://www.startpage.com/search?q=',
    'SearXNG': 'https://searx.be/search?q=',
    'Ecosia': 'https://www.ecosia.org/search?q=',
  };

  // SharedPreferences Keys
  static const String prefUserAgent = 'pref_user_agent';
  static const String prefSearchEngine = 'pref_search_engine';
  static const String prefWebRtcBlock = 'pref_webrtc_block';
  static const String prefCanvasBlock = 'pref_canvas_block';
  static const String prefAudioBlock = 'pref_audio_block';
  static const String prefWebGLBlock = 'pref_webgl_block';
  static const String prefDohEnabled = 'pref_doh_enabled';
  static const String prefDohProvider = 'pref_doh_provider';
  static const String prefAutoClearInterval = 'pref_auto_clear_interval';
  static const String prefClearOnExit = 'pref_clear_on_exit';
  static const String prefJavascriptEnabled = 'pref_javascript_enabled';
  static const String prefCookiesEnabled = 'pref_cookies_enabled';
  static const String prefThirdPartyCookies = 'pref_third_party_cookies';
  static const String prefOnboardingComplete = 'pref_onboarding_complete';
  static const String prefSelectedDohProvider = 'pref_selected_doh';
  static const String prefTimezoneSpoof = 'pref_timezone_spoof';
}
