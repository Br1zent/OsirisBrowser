import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/privacy_settings.dart';
import '../../../domain/repositories/privacy_settings_repository.dart';
import '../../../domain/repositories/history_repository.dart';
import '../../../domain/repositories/bookmark_repository.dart';

part 'privacy_event.dart';
part 'privacy_state.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  final PrivacySettingsRepository settingsRepository;
  final HistoryRepository historyRepository;
  final BookmarkRepository bookmarkRepository;
  Future<void> _settingsUpdateQueue = Future<void>.value();

  PrivacyBloc({
    required this.settingsRepository,
    required this.historyRepository,
    required this.bookmarkRepository,
  }) : super(const PrivacyState()) {
    on<PrivacyLoadSettings>(_onLoadSettings);
    on<PrivacyUpdateSettings>(_onUpdateSettings);
    on<PrivacyNukeAllData>(_onNukeAllData);
    on<PrivacyClearHistory>(_onClearHistory);
    on<PrivacyResetToDefaults>(_onResetToDefaults);
  }

  Future<void> _onLoadSettings(
      PrivacyLoadSettings event, Emitter<PrivacyState> emit) async {
    emit(state.copyWith(status: PrivacyStatus.loading));
    try {
      final settings = await settingsRepository.getSettings();
      emit(state.copyWith(
        status: PrivacyStatus.loaded,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacyStatus.error,
        message: 'Failed to load settings',
      ));
    }
  }

  Future<void> _onUpdateSettings(
      PrivacyUpdateSettings event, Emitter<PrivacyState> emit) async {
    final update = _settingsUpdateQueue.then((_) async {
      final settings = _applySetting(state.settings, event.key, event.value);
      try {
        await settingsRepository.saveSettings(settings);
        emit(state.copyWith(
          status: PrivacyStatus.loaded,
          settings: settings,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: PrivacyStatus.error,
          message: 'Failed to save settings',
        ));
      }
    });
    _settingsUpdateQueue = update;
    await update;
  }

  PrivacySettings _applySetting(
      PrivacySettings settings, String key, Object value) {
    switch (key) {
      case 'blockWebRtc':
        return settings.copyWith(blockWebRtc: value as bool);
      case 'blockCanvasFingerprint':
        return settings.copyWith(blockCanvasFingerprint: value as bool);
      case 'blockAudioFingerprint':
        return settings.copyWith(blockAudioFingerprint: value as bool);
      case 'blockWebGLFingerprint':
        return settings.copyWith(blockWebGLFingerprint: value as bool);
      case 'spoofTimezone':
        return settings.copyWith(spoofTimezone: value as bool);
      case 'javascriptEnabled':
        return settings.copyWith(javascriptEnabled: value as bool);
      case 'cookiesEnabled':
        return settings.copyWith(cookiesEnabled: value as bool);
      case 'blockThirdPartyCookies':
        return settings.copyWith(blockThirdPartyCookies: value as bool);
      case 'dohEnabled':
        return settings.copyWith(dohEnabled: value as bool);
      case 'dohProvider':
        return settings.copyWith(dohProvider: value as String);
      case 'userAgent':
        return settings.copyWith(userAgent: value as String);
      case 'searchEngine':
        return settings.copyWith(searchEngine: value as String);
      case 'autoClearInterval':
        return settings.copyWith(autoClearInterval: value as int);
      case 'clearOnExit':
        return settings.copyWith(clearOnExit: value as bool);
      case 'saveHistory':
        return settings.copyWith(saveHistory: value as bool);
      case 'adBlockEnabled':
        return settings.copyWith(adBlockEnabled: value as bool);
      default:
        throw ArgumentError.value(key, 'key', 'Unknown privacy setting');
    }
  }

  Future<void> _onNukeAllData(
      PrivacyNukeAllData event, Emitter<PrivacyState> emit) async {
    emit(state.copyWith(status: PrivacyStatus.nuking));
    try {
      await historyRepository.clearAllHistory();
      if (event.clearBookmarks) {
        await bookmarkRepository.deleteAllBookmarks();
      }
      emit(state.copyWith(
        status: PrivacyStatus.nuked,
        message: 'All data obliterated',
      ));
      // Return to loaded state after brief moment
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: PrivacyStatus.loaded, message: null));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacyStatus.error,
        message: 'Failed to clear data',
      ));
    }
  }

  Future<void> _onClearHistory(
      PrivacyClearHistory event, Emitter<PrivacyState> emit) async {
    try {
      await historyRepository.clearAllHistory();
      emit(state.copyWith(message: 'History cleared'));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacyStatus.error,
        message: 'Failed to clear history',
      ));
    }
  }

  Future<void> _onResetToDefaults(
      PrivacyResetToDefaults event, Emitter<PrivacyState> emit) async {
    try {
      await settingsRepository.resetToDefaults();
      emit(state.copyWith(
        settings: const PrivacySettings(),
        status: PrivacyStatus.loaded,
        message: 'Settings reset to defaults',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacyStatus.error,
        message: 'Failed to reset settings',
      ));
    }
  }
}
