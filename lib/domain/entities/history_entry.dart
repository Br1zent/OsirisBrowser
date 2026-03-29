import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final DateTime visitedAt;
  final int visitCount;

  const HistoryEntry({
    required this.id,
    required this.title,
    required this.url,
    this.faviconUrl,
    required this.visitedAt,
    this.visitCount = 1,
  });

  HistoryEntry copyWith({
    String? id,
    String? title,
    String? url,
    String? faviconUrl,
    DateTime? visitedAt,
    int? visitCount,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      visitedAt: visitedAt ?? this.visitedAt,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, url, faviconUrl, visitedAt, visitCount];
}
