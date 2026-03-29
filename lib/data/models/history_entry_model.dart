import '../../domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    required super.id,
    required super.title,
    required super.url,
    super.faviconUrl,
    required super.visitedAt,
    super.visitCount,
  });

  factory HistoryEntryModel.fromEntity(HistoryEntry entry) {
    return HistoryEntryModel(
      id: entry.id,
      title: entry.title,
      url: entry.url,
      faviconUrl: entry.faviconUrl,
      visitedAt: entry.visitedAt,
      visitCount: entry.visitCount,
    );
  }

  factory HistoryEntryModel.fromMap(Map<String, dynamic> map) {
    return HistoryEntryModel(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      faviconUrl: map['favicon_url'] as String?,
      visitedAt:
          DateTime.fromMillisecondsSinceEpoch(map['visited_at'] as int),
      visitCount: map['visit_count'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'favicon_url': faviconUrl,
      'visited_at': visitedAt.millisecondsSinceEpoch,
      'visit_count': visitCount,
    };
  }

  HistoryEntry toEntity() {
    return HistoryEntry(
      id: id,
      title: title,
      url: url,
      faviconUrl: faviconUrl,
      visitedAt: visitedAt,
      visitCount: visitCount,
    );
  }
}
