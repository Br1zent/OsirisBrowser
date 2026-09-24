import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/privacy_settings.dart';
import '../../../domain/repositories/privacy_settings_repository.dart';
import '../../../domain/repositories/history_repository.dart';
import '../../../domain/repositories/bookmark_repository.dart';
import '../../../core/security/data_wipe_service.dart';
import '../screens/browser/browser_session_controller.dart';

part 'privacy_event.dart';
part 'privacy_state.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  final PrivacySettingsRepository settingsRepository;
  final HistoryRepository historyRepository;
  final BookmarkRepository bookmarkRepository;
  final DataWipeService dataWipeService;

  PrivacyBloc({
    required this.settingsRepository,
    required this.historyRepository,
    required this.bookmarkRepository,
    required this.dataWipeService,
  }) : super(const PrivacyState()) {
    on<PrivacyLoadSettings>(_onLoadSettings);
    on<PrivacyUpdateSettings>(_onUpdateSettings);
    on<PrivacyNukeAllData>(_onNukeAllData);
    on<PrivacyClearHistory>(_onClearHistory);
    on<PrivacyResetToDefaults>(_onResetToDefaults);
  }

  Future<WipeReport> resetApp() => dataWipeService.wipe(
        scope: WipeScope.reset,
        clearBookmarks: true,
        // Reset runs on the welcome route, where BrowserScreen is unmounted.
        stopWebViews: () async {},
      );

  Future<WipeReport> clearSession() => dataWipeService.wipe(
        scope: WipeScope.session,
        stopWebViews: BrowserSessionController.instance.closeAll,
      );

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
    try {
      await settingsRepository.saveSettings(event.settings);
      emit(state.copyWith(
        status: PrivacyStatus.loaded,
        settings: event.settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PrivacyStatus.error,
        message: 'Failed to save settings',
      ));
    }
  }

  Future<void> _onNukeAllData(
      PrivacyNukeAllData event, Emitter<PrivacyState> emit) async {
    emit(state.copyWith(status: PrivacyStatus.nuking));
    try {
      final report = await dataWipeService.wipe(
        scope: WipeScope.nuke,
        clearBookmarks: event.clearBookmarks,
        stopWebViews: BrowserSessionController.instance.closeAll,
      );
      if (!report.succeeded) {
        throw StateError('Wipe incomplete: ${report.failedComponents.join(', ')}');
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
        message: 'Wipe incomplete. App remains locked; retry required.',
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
