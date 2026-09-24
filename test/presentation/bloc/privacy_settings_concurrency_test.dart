import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/domain/entities/bookmark.dart';
import 'package:osiris_browser/domain/entities/history_entry.dart';
import 'package:osiris_browser/domain/entities/privacy_settings.dart';
import 'package:osiris_browser/domain/repositories/bookmark_repository.dart';
import 'package:osiris_browser/domain/repositories/history_repository.dart';
import 'package:osiris_browser/domain/repositories/privacy_settings_repository.dart';
import 'package:osiris_browser/presentation/bloc/privacy/privacy_bloc.dart';

void main() {
  test('rapid setting updates preserve both changes in order', () async {
    final settingsRepository = _SettingsRepository();
    final bloc = PrivacyBloc(
      settingsRepository: settingsRepository,
      historyRepository: _HistoryRepository(),
      bookmarkRepository: _BookmarkRepository(),
    );
    addTearDown(bloc.close);

    final matchingState = bloc.stream.firstWhere(
      (state) =>
          state.settings.blockCanvasFingerprint == false &&
          state.settings.blockAudioFingerprint == false,
    );
    bloc.add(const PrivacyUpdateSettings('blockCanvasFingerprint', false));
    bloc.add(const PrivacyUpdateSettings('blockAudioFingerprint', false));
    final state = await matchingState;

    expect(state.settings.blockCanvasFingerprint, isFalse);
    expect(state.settings.blockAudioFingerprint, isFalse);
    expect(settingsRepository.saved.last.blockCanvasFingerprint, isFalse);
    expect(settingsRepository.saved.last.blockAudioFingerprint, isFalse);
  });
}

class _SettingsRepository implements PrivacySettingsRepository {
  final List<PrivacySettings> saved = [];

  @override
  Future<PrivacySettings> getSettings() async => const PrivacySettings();

  @override
  Future<void> saveSettings(PrivacySettings settings) async {
    saved.add(settings);
  }

  @override
  Future<void> resetToDefaults() async {}
}

class _HistoryRepository implements HistoryRepository {
  @override
  Future<List<HistoryEntry>> getAllHistory({int? limit, int? offset}) async =>
      [];
  @override
  Future<void> addEntry(HistoryEntry entry) async {}
  @override
  Future<void> deleteEntry(String id) async {}
  @override
  Future<void> clearAllHistory() async {}
  @override
  Future<List<HistoryEntry>> searchHistory(String query) async => [];
  @override
  Future<int> getTotalCount() async => 0;
}

class _BookmarkRepository implements BookmarkRepository {
  @override
  Future<List<Bookmark>> getAllBookmarks() async => [];
  @override
  Future<Bookmark?> getBookmarkById(String id) async => null;
  @override
  Future<bool> isBookmarked(String url) async => false;
  @override
  Future<void> addBookmark(Bookmark bookmark) async {}
  @override
  Future<void> updateBookmark(Bookmark bookmark) async {}
  @override
  Future<void> deleteBookmark(String id) async {}
  @override
  Future<void> deleteAllBookmarks() async {}
  @override
  Future<List<Bookmark>> searchBookmarks(String query) async => [];
}
