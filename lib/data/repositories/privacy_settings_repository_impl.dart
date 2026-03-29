import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/privacy_settings.dart';
import '../../domain/repositories/privacy_settings_repository.dart';
import '../../core/constants/app_constants.dart';

class PrivacySettingsRepositoryImpl implements PrivacySettingsRepository {
  final SharedPreferences _prefs;

  PrivacySettingsRepositoryImpl(this._prefs);

  @override
  Future<PrivacySettings> getSettings() async {
    return PrivacySettings(
      blockWebRtc: _prefs.getBool(AppConstants.prefWebRtcBlock) ?? true,
      blockCanvasFingerprint:
          _prefs.getBool(AppConstants.prefCanvasBlock) ?? true,
      blockAudioFingerprint:
          _prefs.getBool(AppConstants.prefAudioBlock) ?? true,
      blockWebGLFingerprint:
          _prefs.getBool(AppConstants.prefWebGLBlock) ?? true,
      spoofTimezone: _prefs.getBool(AppConstants.prefTimezoneSpoof) ?? true,
      javascriptEnabled:
          _prefs.getBool(AppConstants.prefJavascriptEnabled) ?? true,
      cookiesEnabled: _prefs.getBool(AppConstants.prefCookiesEnabled) ?? true,
      blockThirdPartyCookies:
          _prefs.getBool(AppConstants.prefThirdPartyCookies) ?? true,
      dohEnabled: _prefs.getBool(AppConstants.prefDohEnabled) ?? true,
      dohProvider: _prefs.getString(AppConstants.prefSelectedDohProvider) ??
          'Cloudflare',
      userAgent:
          _prefs.getString(AppConstants.prefUserAgent) ?? 'Chrome (Windows)',
      searchEngine:
          _prefs.getString(AppConstants.prefSearchEngine) ?? 'DuckDuckGo',
      autoClearInterval:
          _prefs.getInt(AppConstants.prefAutoClearInterval) ?? 0,
      clearOnExit: _prefs.getBool(AppConstants.prefClearOnExit) ?? true,
    );
  }

  @override
  Future<void> saveSettings(PrivacySettings settings) async {
    await Future.wait([
      _prefs.setBool(AppConstants.prefWebRtcBlock, settings.blockWebRtc),
      _prefs.setBool(
          AppConstants.prefCanvasBlock, settings.blockCanvasFingerprint),
      _prefs.setBool(
          AppConstants.prefAudioBlock, settings.blockAudioFingerprint),
      _prefs.setBool(
          AppConstants.prefWebGLBlock, settings.blockWebGLFingerprint),
      _prefs.setBool(AppConstants.prefTimezoneSpoof, settings.spoofTimezone),
      _prefs.setBool(
          AppConstants.prefJavascriptEnabled, settings.javascriptEnabled),
      _prefs.setBool(
          AppConstants.prefCookiesEnabled, settings.cookiesEnabled),
      _prefs.setBool(
          AppConstants.prefThirdPartyCookies, settings.blockThirdPartyCookies),
      _prefs.setBool(AppConstants.prefDohEnabled, settings.dohEnabled),
      _prefs.setString(
          AppConstants.prefSelectedDohProvider, settings.dohProvider),
      _prefs.setString(AppConstants.prefUserAgent, settings.userAgent),
      _prefs.setString(AppConstants.prefSearchEngine, settings.searchEngine),
      _prefs.setInt(
          AppConstants.prefAutoClearInterval, settings.autoClearInterval),
      _prefs.setBool(AppConstants.prefClearOnExit, settings.clearOnExit),
    ]);
  }

  @override
  Future<void> resetToDefaults() async {
    await saveSettings(const PrivacySettings());
  }
}
