import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/constants/app_constants.dart';
import '../../../core/security/encryption_service.dart';

/// Local database using sqflite (plain, no code generation required).
/// All sensitive string values can be pre-encrypted with [EncryptionService]
/// before insertion, and decrypted after retrieval.
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _db;

  static Future<AppDatabase> getInstance() async {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _openDB();
    return _db!;
  }

  Future<Database> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmarks_table (
        id          TEXT PRIMARY KEY NOT NULL,
        title       TEXT NOT NULL,
        url         TEXT NOT NULL,
        favicon_url TEXT,
        folder_id   TEXT,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        sort_order  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS history_table (
        id          TEXT PRIMARY KEY NOT NULL,
        title       TEXT NOT NULL,
        url         TEXT NOT NULL,
        favicon_url TEXT,
        visited_at  INTEGER NOT NULL,
        visit_count INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings_table (
        key   TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // Indexes for common queries
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_visited ON history_table(visited_at DESC)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookmarks_sort ON bookmarks_table(sort_order, created_at DESC)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations
  }

  // ─── Bookmarks ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final db = await database;
    return db.query('bookmarks_table',
        orderBy: 'sort_order ASC, created_at DESC');
  }

  Future<Map<String, dynamic>?> getBookmarkById(String id) async {
    final db = await database;
    final rows = await db.query('bookmarks_table',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<bool> isBookmarked(String url) async {
    final db = await database;
    final rows = await db.query('bookmarks_table',
        where: 'url = ?', whereArgs: [url], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> insertBookmark(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('bookmarks_table', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBookmarkById(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('bookmarks_table', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteBookmarkById(String id) async {
    final db = await database;
    await db.delete('bookmarks_table', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllBookmarksData() async {
    final db = await database;
    await db.delete('bookmarks_table');
  }

  Future<List<Map<String, dynamic>>> searchBookmarks(String query) async {
    final db = await database;
    return db.query(
      'bookmarks_table',
      where: 'title LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'sort_order ASC, created_at DESC',
    );
  }

  // ─── History ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllHistory(
      {int? limit, int? offset}) async {
    final db = await database;
    return db.query(
      'history_table',
      orderBy: 'visited_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> insertHistory(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('history_table', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteHistoryById(String id) async {
    final db = await database;
    await db.delete('history_table', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllHistory() async {
    final db = await database;
    await db.delete('history_table');
  }

  Future<List<Map<String, dynamic>>> searchHistory(String query) async {
    final db = await database;
    return db.query(
      'history_table',
      where: 'title LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'visited_at DESC',
    );
  }

  Future<int> getHistoryCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM history_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Settings ──────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('settings_table',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings_table',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings_table', where: 'key = ?', whereArgs: [key]);
  }

  // ─── Encrypted helpers ─────────────────────────────────────────────────────

  Future<void> setEncryptedSetting(String key, String plainValue) async {
    final encrypted = EncryptionService.instance.encrypt(plainValue);
    await setSetting(key, encrypted);
  }

  Future<String?> getDecryptedSetting(String key) async {
    final raw = await getSetting(key);
    if (raw == null) return null;
    return EncryptionService.instance.decrypt(raw);
  }

  /// Close the database connection
  Future<void> close() async {
    final db = _db;
    if (db != null && db.isOpen) {
      await db.close();
      _db = null;
    }
  }
}
