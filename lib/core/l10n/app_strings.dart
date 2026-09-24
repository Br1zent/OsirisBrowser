import 'package:flutter/material.dart';

/// Manual localization — no code generation required.
/// Add a Provider/InheritedWidget lookup via [AppStrings.of(context)].
class AppStrings {
  const AppStrings._(this._lang);

  final String _lang;
  bool get _ru => _lang == 'ru';

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(locale.languageCode);
  }

  static AppStrings forLocale(Locale locale) =>
      AppStrings._(locale.languageCode);

  // ── Navigation ──────────────────────────────────────────────────────────────
  String get navHome     => _ru ? 'Главная'    : 'Home';
  String get navPrivacy  => _ru ? 'Защита'     : 'Privacy';
  String get navSaved    => _ru ? 'Закладки'   : 'Saved';
  String get navSettings => _ru ? 'Настройки'  : 'Settings';

  // ── Common ──────────────────────────────────────────────────────────────────
  String get cancel  => _ru ? 'Отмена'     : 'Cancel';
  String get save    => _ru ? 'Сохранить'  : 'Save';
  String get done    => _ru ? 'Готово'     : 'Done';
  String get reset   => _ru ? 'Сбросить'   : 'Reset';
  String get close   => _ru ? 'Закрыть'    : 'Close';
  String get confirm => _ru ? 'Подтвердить': 'Confirm';
  String get enabled => _ru ? 'Включено'   : 'Enabled';
  String get disabled=> _ru ? 'Выключено'  : 'Disabled';
  String get on      => _ru ? 'Вкл'        : 'On';
  String get off     => _ru ? 'Выкл'       : 'Off';

  // ── Settings Screen ─────────────────────────────────────────────────────────
  String get settings           => _ru ? 'Настройки'        : 'Settings';
  String get sectionAppearance  => _ru ? 'Внешний вид'       : 'Appearance';
  String get sectionBrowser     => _ru ? 'Браузер'           : 'Browser';
  String get sectionAbout       => _ru ? 'О приложении'      : 'About';

  String get accentColor        => _ru ? 'Цвет акцента'      : 'Accent Color';
  String get accentColorDesc    => _ru ? 'Основной цвет интерфейса'
                                       : 'Main interface color';
  String get language           => _ru ? 'Язык'              : 'Language';
  String get languageDesc       => _ru ? 'Язык интерфейса'   : 'Interface language';

  String get privacyHubLink     => _ru ? 'Центр приватности' : 'Privacy Hub';
  String get privacyHubDesc     => _ru ? 'Защита отпечатка, WebRTC, история'
                                       : 'Fingerprint protection, WebRTC, history';

  String get appVersion         => _ru ? 'Версия'            : 'Version';
  String get author             => _ru ? 'Автор'             : 'Author';
  String get openTelegram       => _ru ? 'Открыть в Telegram': 'Open in Telegram';
  String get osirisDesc         => _ru
      ? 'Анонимный браузер с защитой от отслеживания и шифрованием данных'
      : 'Anonymous browser with tracking protection and data encryption';

  // ── Browser / Home ──────────────────────────────────────────────────────────
  String get searchOrEnterUrl   => _ru ? 'Поиск или адрес сайта'
                                       : 'Search or enter URL';
  String get newTab             => _ru ? 'Новая вкладка'     : 'New Tab';
  String get noTabs             => _ru ? 'Нет открытых вкладок' : 'No open tabs';
  String get quickAccess        => _ru ? 'Быстрый доступ'    : 'Quick Access';
  String get openTabs           => _ru ? 'Открытые вкладки'  : 'Open Tabs';

  // ── Privacy Hub ─────────────────────────────────────────────────────────────
  String get privacyHub         => _ru ? 'Центр приватности' : 'Privacy Hub';
  String get fingerprinting     => _ru ? 'Защита от отслеживания' : 'Fingerprint Protection';
  String get fingerprintDesc    => _ru ? 'Блокировка методов идентификации браузера'
                                       : 'Block browser fingerprinting methods';
  String get networkPrivacy     => _ru ? 'Сетевая приватность' : 'Network Privacy';
  String get networkPrivacyDesc => _ru ? 'Защита на уровне сети и DNS'
                                       : 'Network-level and DNS protection';
  String get browsingSettings   => _ru ? 'Настройки браузера'  : 'Browsing Settings';
  String get autoClean          => _ru ? 'Автоочистка'          : 'Auto-Clean';
  String get autoCleanDesc      => _ru ? 'Автоматически удалять данные'
                                       : 'Automatically delete browsing data';
  String get identityMasking    => _ru ? 'Маскировка личности' : 'Identity Masking';
  String get identityDesc       => _ru ? 'Изменение User-Agent и системных данных'
                                       : 'Spoof User-Agent and system data';
  String get dangerZone         => _ru ? 'Опасная зона'        : 'Danger Zone';

  // Canvas, WebRTC и прочие техназвания остаются как есть (не локализуются)
  String get canvasDesc         => _ru ? 'Блокировать идентификацию через Canvas API'
                                       : 'Block identification via Canvas API';
  String get audioDesc          => _ru ? 'Блокировать AudioContext fingerprint'
                                       : 'Block AudioContext fingerprint';
  String get webglDesc          => _ru ? 'Скрывать характеристики GPU/WebGL'
                                       : 'Hide GPU/WebGL characteristics';
  String get timezoneDesc       => _ru ? 'Скрывать реальный часовой пояс'
                                       : 'Spoof real timezone';
  String get webrtcDesc         => _ru ? 'Предотвращать утечку реального IP через WebRTC'
                                       : 'Prevent real IP leaks via WebRTC';
  String get javascriptDesc     => _ru ? 'Разрешить выполнение JavaScript'
                                       : 'Allow JavaScript execution';
  String get cookiesDesc        => _ru ? 'Разрешить сохранение cookies'
                                       : 'Allow cookies to be saved';
  String get historyDesc        => _ru ? 'Сохранять историю посещений'
                                       : 'Save browsing history';
  String get clearOnExitDesc    => _ru ? 'Удалять все данные при закрытии'
                                       : 'Delete all data when closing';

  // ── Home screen extra ───────────────────────────────────────────────────────
  String get closeAll        => _ru ? 'Закрыть все'        : 'Close All';
  String get privacyShield   => _ru ? 'Щит приватности'    : 'Privacy Shield';
  String get tabsCount       => _ru ? 'Вкладки'            : 'Tabs';
  String get allTracesWiped  => _ru ? 'Все следы уничтожены.' : 'All traces obliterated.';

  // ── Privacy Hub extra ───────────────────────────────────────────────────────
  String get dohDesc         => _ru ? 'Шифрует DNS-запросы'
                                    : 'Encrypts DNS queries';
  String get thirdPartyCookiesDesc => _ru ? 'Предотвращает межсайтовое отслеживание'
                                          : 'Prevents cross-site tracking';
  String get userAgentDesc   => _ru ? 'Выглядеть как другой браузер или устройство'
                                    : 'Appear as a different browser/device';
  String get autoResetDesc   => _ru ? 'Автоматически очищать данные сессии'
                                    : 'Automatically clear session data';
  String get nukeWarning     => _ru
      ? 'Удаляет все cookies, сессии,\nисторию и localStorage'
      : 'Clears ALL cookies, sessions,\nhistory & localStorage';
  String get nukeConfirmTitle  => _ru ? 'Подтвердить удаление' : 'Confirm Nuke';
  String get nukeWillDelete    => _ru ? 'Это безвозвратно удалит:'  : 'This will permanently delete:';
  String get nukeHistory       => _ru ? 'Всю историю посещений'     : 'All browsing history';
  String get nukeCookies       => _ru ? 'Все cookies и сессии'      : 'All cookies & sessions';
  String get nukeLocalStorage  => _ru ? 'Все данные localStorage'   : 'All localStorage data';
  String get nukeCache         => _ru ? 'Все кэшированные данные'   : 'All cached data';
  String get nukeClearBookmarks => _ru ? 'Также удалить закладки'   : 'Also clear bookmarks';
  String get nukeCannotUndo    => _ru ? 'Это действие нельзя отменить.' : 'This action cannot be undone.';
  String get nukeNow           => _ru ? 'УНИЧТОЖИТЬ'                : 'NUKE NOW';
  String get resetSettings     => _ru ? 'Сбросить настройки'        : 'Reset Settings';
  String get resetSettingsMsg  => _ru ? 'Сбросить все настройки приватности по умолчанию?'
                                     : 'Reset all privacy settings to defaults?';
  String get clearHistory      => _ru ? 'Очистить историю'          : 'Clear History';
  String get clearHistoryMsg   => _ru ? 'Удалить всю историю посещений?'
                                     : 'Delete all browsing history?';
  String get doHProvider       => _ru ? 'Провайдер DoH'             : 'DoH Provider';
  String get searchEngine      => _ru ? 'Поисковая система'         : 'Search Engine';
  String get userAgentString   => _ru ? 'User-Agent строка'         : 'User-Agent String';
  String get autoResetTimer    => _ru ? 'Таймер автосброса'         : 'Auto-Reset Timer';
  String get encryptionActive  => _ru ? 'Статус шифрования не подтверждён'
                                     : 'Encryption status unverified';
  String get encryptionInactive => _ru ? 'Статус шифрования не подтверждён'
                                      : 'Encryption status unverified';
  String get runtimeProtectionUnavailable => _ru
      ? 'Защита от fingerprinting и утечек WebRTC отключена: реализация не подтверждена.'
      : 'Fingerprinting and WebRTC protection are unavailable because their implementation is unverified.';
  String get wiping            => _ru ? 'ОЧИСТКА...'   : 'WIPING...';
  String get tapToWipe         => _ru ? 'НАЖМИ ДЛЯ ОЧИСТКИ' : 'TAP TO WIPE';
  String get emergencyWipe     => _ru ? 'ЭКСТРЕННАЯ ОЧИСТКА' : 'EMERGENCY WIPE';
  String get openTabsCount     => _ru ? 'Открытых вкладок' : 'Open Tabs';
  String get done2             => _ru ? 'Готово' : 'Done';

  // ── Welcome / Auth ──────────────────────────────────────────────────────────
  String get welcomeTitle       => _ru ? 'Добро пожаловать'   : 'Welcome';
  String get createPassword     => _ru ? 'Создать пароль'     : 'Create Password';
  String get enterPassword      => _ru ? 'Введите пароль'     : 'Enter Password';
  String get masterPasswordHint => _ru ? 'Мастер-пароль'      : 'Master Password';
  String get biometricLogin     => _ru ? 'Войти по биометрии' : 'Login with Biometrics';
  String get unlockApp          => _ru ? 'Разблокировать'     : 'Unlock';
}
