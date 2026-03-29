import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

/// Holds runtime app-wide state: accent color + locale.
/// Consumed via [ChangeNotifierProvider] in main.dart.
class AppStateService extends ChangeNotifier {
  static const _keyAccent = 'accent_color';
  static const _keyLocale = 'app_locale';

  final SharedPreferences _prefs;

  Color _accent;
  Locale _locale;

  AppStateService(this._prefs)
      : _accent = Color(
            _prefs.getInt(_keyAccent) ?? AppColors.defaultAccent.value),
        _locale = Locale(_prefs.getString(_keyLocale) ?? 'en');

  Color get accent => _accent;
  Locale get locale => _locale;

  void setAccent(Color color) {
    if (_accent == color) return;
    _accent = color;
    _prefs.setInt(_keyAccent, color.value);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _prefs.setString(_keyLocale, locale.languageCode);
    notifyListeners();
  }
}
