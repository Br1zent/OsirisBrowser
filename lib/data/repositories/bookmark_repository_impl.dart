import 'package:uuid/uuid.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/local/app_database.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  BookmarkRepositoryImpl(this._db);

  Bookmark _fromMap(Map<String, dynamic> r) => Bookmark(
        id: r['id'] as String,
        title: r['title'] as String,
        url: r['url'] as String,
        faviconUrl: r['favicon_url'] as String?,
        folderId: r['folder_id'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int),
        sortOrder: r['sort_order'] as int? ?? 0,
      );

  @override
  Future<List<Bookmark>> getAllBookmarks() async {
    final rows = await _db.getAllBookmarks();
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Bookmark?> getBookmarkById(String id) async {
    final row = await _db.getBookmarkById(id);
    return row != null ? _fromMap(row) : null;
  }

  @override
  Future<bool> isBookmarked(String url) => _db.isBookmarked(url);

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.insertBookmark({
      'id': bookmark.id.isEmpty ? _uuid.v4() : bookmark.id,
      'title': bookmark.title,
      'url': bookmark.url,
      'favicon_url': bookmark.faviconUrl,
      'folder_id': bookmark.folderId,
      'created_at': now,
      'updated_at': now,
      'sort_order': bookmark.sortOrder,
    });
  }

  @override
  Future<void> updateBookmark(Bookmark bookmark) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.updateBookmarkById(bookmark.id, {
      'title': bookmark.title,
      'url': bookmark.url,
      'favicon_url': bookmark.faviconUrl,
      'folder_id': bookmark.folderId,
      'updated_at': now,
      'sort_order': bookmark.sortOrder,
    });
  }

  @override
  Future<void> deleteBookmark(String id) => _db.deleteBookmarkById(id);

  @override
  Future<void> deleteAllBookmarks() => _db.deleteAllBookmarksData();

  @override
  Future<List<Bookmark>> searchBookmarks(String query) async {
    final rows = await _db.searchBookmarks(query);
    return rows.map(_fromMap).toList();
  }
}
