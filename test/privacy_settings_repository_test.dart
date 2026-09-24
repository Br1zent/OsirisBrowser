import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:osiris_browser/data/repositories/privacy_settings_repository_impl.dart';
import 'package:osiris_browser/domain/entities/privacy_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists history and ad-block settings', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PrivacySettingsRepositoryImpl(preferences);

    await repository.saveSettings(
      const PrivacySettings(saveHistory: true, adBlockEnabled: false),
    );

    final restored = await repository.getSettings();
    expect(restored.saveHistory, isTrue);
    expect(restored.adBlockEnabled, isFalse);
  });
}
