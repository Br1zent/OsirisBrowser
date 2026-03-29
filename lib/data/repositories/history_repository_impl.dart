import '../../domain/entities/history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/app_database.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final AppDatabase _db;

  HistoryRepositoryImpl(this._db);

  HistoryEntry _fromMap(Map<String, dynamic> r) => HistoryEntry(
        id: r['id'] as String,
        title: r['title'] as String,
        url: r['url'] as String,
        faviconUrl: r['favicon_url'] as String?,
        visitedAt: DateTime.fromMillisecondsSinceEpoch(r['visited_at'] as int),
        visitCount: r['visit_count'] as int? ?? 1,
      );

  @override
  Future<List<HistoryEntry>> getAllHistory({int? limit, int? offset}) async {
    final rows = await _db.getAllHistory(limit: limit, offset: offset);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    await _db.insertHistory({
      'id': entry.id,
      'title': entry.title,
      'url': entry.url,
      'favicon_url': entry.faviconUrl,
      'visited_at': entry.visitedAt.millisecondsSinceEpoch,
      'visit_count': entry.visitCount,
    });
  }

  @override
  Future<void> deleteEntry(String id) => _db.deleteHistoryById(id);

  @override
  Future<void> clearAllHistory() => _db.clearAllHistory();

  @override
  Future<List<HistoryEntry>> searchHistory(String query) async {
    final rows = await _db.searchHistory(query);
    return rows.map(_fromMap).toList();
  }

  @override
  Future<int> getTotalCount() => _db.getHistoryCount();
}
