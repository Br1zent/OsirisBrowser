import 'package:flutter_test/flutter_test.dart';

import '../lib/domain/entities/bookmark.dart';
import '../lib/domain/entities/history_entry.dart';
import '../lib/domain/entities/privacy_settings.dart';
import '../lib/domain/repositories/bookmark_repository.dart';
import '../lib/domain/repositories/browser_data_repository.dart';
import '../lib/domain/repositories/history_repository.dart';
import '../lib/domain/repositories/privacy_settings_repository.dart';
import '../lib/presentation/bloc/privacy/privacy_bloc.dart';

void main() {
  test('privacy nuke clears web data as well as browsing history', () async {
    final history = _HistoryRepository();
    final browserData = _BrowserDataRepository();
    final bloc = PrivacyBloc(
      settingsRepository: _SettingsRepository(),
      historyRepository: history,
      bookmarkRepository: _BookmarkRepository(),
      browserDataRepository: browserData,
    );

    bloc.add(const PrivacyNukeAllData());
    await bloc.stream.firstWhere((state) => state.status == PrivacyStatus.nuked);

    expect(history.cleared, isTrue);
    expect(browserData.cleared, isTrue);
    await bloc.close();
  });
}

class _BrowserDataRepository implements BrowserDataRepository {
  bool cleared = false;

  @override
  Future<void> clearAll() async {
    cleared = true;
  }
}

class _HistoryRepository implements HistoryRepository {
  bool cleared = false;

  @override
  Future<void> clearAllHistory() async {
    cleared = true;
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<List<HistoryEntry>> getAllHistory({int? limit, int? offset}) async => [];

  @override
  Future<List<HistoryEntry>> searchHistory(String query) async => [];

  @override
  Future<int> getTotalCount() async => 0;
}

class _BookmarkRepository implements BookmarkRepository {
  @override
  Future<void> addBookmark(Bookmark bookmark) async {}

  @override
  Future<void> deleteAllBookmarks() async {}

  @override
  Future<void> deleteBookmark(String id) async {}

  @override
  Future<List<Bookmark>> getAllBookmarks() async => [];

  @override
  Future<Bookmark?> getBookmarkById(String id) async => null;

  @override
  Future<bool> isBookmarked(String url) async => false;

  @override
  Future<List<Bookmark>> searchBookmarks(String query) async => [];

  @override
  Future<void> updateBookmark(Bookmark bookmark) async {}
}

class _SettingsRepository implements PrivacySettingsRepository {
  @override
  Future<PrivacySettings> getSettings() async => const PrivacySettings();

  @override
  Future<void> resetToDefaults() async {}

  @override
  Future<void> saveSettings(PrivacySettings settings) async {}
}
