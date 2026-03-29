import '../entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<List<Bookmark>> getAllBookmarks();
  Future<Bookmark?> getBookmarkById(String id);
  Future<bool> isBookmarked(String url);
  Future<void> addBookmark(Bookmark bookmark);
  Future<void> updateBookmark(Bookmark bookmark);
  Future<void> deleteBookmark(String id);
  Future<void> deleteAllBookmarks();
  Future<List<Bookmark>> searchBookmarks(String query);
}
