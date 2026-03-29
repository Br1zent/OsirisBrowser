import '../../domain/entities/bookmark.dart';

class BookmarkModel extends Bookmark {
  const BookmarkModel({
    required super.id,
    required super.title,
    required super.url,
    super.faviconUrl,
    super.folderId,
    required super.createdAt,
    required super.updatedAt,
    super.sortOrder,
  });

  factory BookmarkModel.fromEntity(Bookmark bookmark) {
    return BookmarkModel(
      id: bookmark.id,
      title: bookmark.title,
      url: bookmark.url,
      faviconUrl: bookmark.faviconUrl,
      folderId: bookmark.folderId,
      createdAt: bookmark.createdAt,
      updatedAt: bookmark.updatedAt,
      sortOrder: bookmark.sortOrder,
    );
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      faviconUrl: map['favicon_url'] as String?,
      folderId: map['folder_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'favicon_url': faviconUrl,
      'folder_id': folderId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sort_order': sortOrder,
    };
  }

  Bookmark toEntity() {
    return Bookmark(
      id: id,
      title: title,
      url: url,
      faviconUrl: faviconUrl,
      folderId: folderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sortOrder: sortOrder,
    );
  }
}
