import 'package:equatable/equatable.dart';

class Bookmark extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? faviconUrl;
  final String? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.faviconUrl,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  Bookmark copyWith({
    String? id,
    String? title,
    String? url,
    String? faviconUrl,
    String? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Bookmark(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, url, faviconUrl, folderId, createdAt, updatedAt, sortOrder];
}
