import '../entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getAllHistory({int? limit, int? offset});
  Future<void> addEntry(HistoryEntry entry);
  Future<void> deleteEntry(String id);
  Future<void> clearAllHistory();
  Future<List<HistoryEntry>> searchHistory(String query);
  Future<int> getTotalCount();
}
