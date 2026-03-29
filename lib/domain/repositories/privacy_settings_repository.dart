import '../entities/privacy_settings.dart';

abstract class PrivacySettingsRepository {
  Future<PrivacySettings> getSettings();
  Future<void> saveSettings(PrivacySettings settings);
  Future<void> resetToDefaults();
}
