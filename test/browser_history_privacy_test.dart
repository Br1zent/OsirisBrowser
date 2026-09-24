import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../lib/domain/entities/bookmark.dart';
import '../lib/domain/entities/history_entry.dart';
import '../lib/domain/repositories/bookmark_repository.dart';
import '../lib/domain/repositories/history_repository.dart';
import '../lib/presentation/bloc/browser/browser_bloc.dart';

void main() {
  test('private tab visits are not persisted in history', () async {
    final history = _FakeHistoryRepository();
    final bloc = BrowserBloc(
      bookmarkRepository: _FakeBookmarkRepository(),
      historyRepository: history,
    );
    await bloc.stream.firstWhere((state) => state.tabs.isNotEmpty);

    bloc.add(const BrowserAddToHistory(
      'https://private.example',
      'Private page',
      isPrivate: true,
    ));
    await bloc.close();
    expect(history.entries, isEmpty);
  });

  test('non-private visits can be persisted in history', () async {
    final history = _FakeHistoryRepository();
    final bloc = BrowserBloc(
      bookmarkRepository: _FakeBookmarkRepository(),
      historyRepository: history,
    );
    await bloc.stream.firstWhere((state) => state.tabs.isNotEmpty);

    bloc.add(const BrowserAddToHistory(
      'https://public.example',
      'Public page',
      isPrivate: false,
    ));
    await history.added;
    await bloc.close();

    expect(history.entries, hasLength(1));
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  final entries = <HistoryEntry>[];
  final _added = Completer<void>();

  Future<void> get added => _added.future;

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    entries.add(entry);
    if (!_added.isCompleted) _added.complete();
  }

  @override
  Future<void> clearAllHistory() async => entries.clear();

  @override
  Future<void> deleteEntry(String id) async =>
      entries.removeWhere((entry) => entry.id == id);

  @override
  Future<List<HistoryEntry>> getAllHistory({int? limit, int? offset}) async =>
      entries;

  @override
  Future<List<HistoryEntry>> searchHistory(String query) async => entries;

  @override
  Future<int> getTotalCount() async => entries.length;
}

class _FakeBookmarkRepository implements BookmarkRepository {
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
