import 'package:equatable/equatable.dart';

class PrivacySettings extends Equatable {
  final bool blockWebRtc;
  final bool blockCanvasFingerprint;
  final bool blockAudioFingerprint;
  final bool blockWebGLFingerprint;
  final bool spoofTimezone;
  final bool javascriptEnabled;
  final bool cookiesEnabled;
  final bool blockThirdPartyCookies;
  final bool dohEnabled;
  final String dohProvider;
  final String userAgent;
  final String searchEngine;
  final int autoClearInterval; // seconds, 0 = session, -1 = never
  final bool clearOnExit;
  final bool saveHistory;
  final bool adBlockEnabled;

  const PrivacySettings({
    this.blockWebRtc = true,
    this.blockCanvasFingerprint = true,
    this.blockAudioFingerprint = true,
    this.blockWebGLFingerprint = true,
    this.spoofTimezone = true,
    this.javascriptEnabled = true,
    this.cookiesEnabled = true,
    this.blockThirdPartyCookies = true,
    this.dohEnabled = true,
    this.dohProvider = 'Cloudflare',
    this.userAgent = 'Chrome (Windows)',
    this.searchEngine = 'DuckDuckGo',
    this.autoClearInterval = 0,
    this.clearOnExit = true,
    this.saveHistory = false,
    this.adBlockEnabled = true,
  });

  PrivacySettings copyWith({
    bool? blockWebRtc,
    bool? blockCanvasFingerprint,
    bool? blockAudioFingerprint,
    bool? blockWebGLFingerprint,
    bool? spoofTimezone,
    bool? javascriptEnabled,
    bool? cookiesEnabled,
    bool? blockThirdPartyCookies,
    bool? dohEnabled,
    String? dohProvider,
    String? userAgent,
    String? searchEngine,
    int? autoClearInterval,
    bool? clearOnExit,
    bool? saveHistory,
    bool? adBlockEnabled,
  }) {
    return PrivacySettings(
      blockWebRtc: blockWebRtc ?? this.blockWebRtc,
      blockCanvasFingerprint:
          blockCanvasFingerprint ?? this.blockCanvasFingerprint,
      blockAudioFingerprint:
          blockAudioFingerprint ?? this.blockAudioFingerprint,
      blockWebGLFingerprint:
          blockWebGLFingerprint ?? this.blockWebGLFingerprint,
      spoofTimezone: spoofTimezone ?? this.spoofTimezone,
      javascriptEnabled: javascriptEnabled ?? this.javascriptEnabled,
      cookiesEnabled: cookiesEnabled ?? this.cookiesEnabled,
      blockThirdPartyCookies:
          blockThirdPartyCookies ?? this.blockThirdPartyCookies,
      dohEnabled: dohEnabled ?? this.dohEnabled,
      dohProvider: dohProvider ?? this.dohProvider,
      userAgent: userAgent ?? this.userAgent,
      searchEngine: searchEngine ?? this.searchEngine,
      autoClearInterval: autoClearInterval ?? this.autoClearInterval,
      clearOnExit: clearOnExit ?? this.clearOnExit,
      saveHistory: saveHistory ?? this.saveHistory,
      adBlockEnabled: adBlockEnabled ?? this.adBlockEnabled,
    );
  }

  @override
  List<Object?> get props => [
        blockWebRtc,
        blockCanvasFingerprint,
        blockAudioFingerprint,
        blockWebGLFingerprint,
        spoofTimezone,
        javascriptEnabled,
        cookiesEnabled,
        blockThirdPartyCookies,
        dohEnabled,
        dohProvider,
        userAgent,
        searchEngine,
        autoClearInterval,
        clearOnExit,
        saveHistory,
        adBlockEnabled,
      ];
}
