import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/security/data_wipe_service.dart';
import 'package:osiris_browser/data/datasources/local/app_database.dart';
import 'package:osiris_browser/domain/repositories/bookmark_repository.dart';
import 'package:osiris_browser/domain/repositories/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NUKE cannot preserve bookmarks without an encrypted database rekey',
      () async {
    SharedPreferences.setMockInitialValues({});
    final service = DataWipeService(
      database: await AppDatabase.getInstance(),
      history: _History(),
      bookmarks: _Bookmarks(),
      preferences: await SharedPreferences.getInstance(),
    );
    var stopped = false;

    final report = await service.wipe(
      scope: WipeScope.nuke,
      clearBookmarks: false,
      stopWebViews: () async {
        stopped = true;
      },
    );

    expect(report.succeeded, isFalse);
    expect(report.failedComponents, contains('bookmarks'));
    expect(stopped, isFalse);
  });

  test('wipe report lists failed components without treating them as success',
      () {
    const report = WipeReport({'cookies': 'platform API failed', 'history': null});

    expect(report.succeeded, isFalse);
    expect(report.failedComponents, ['cookies']);
  });
}

class _History implements HistoryRepository {
  @override
  Future<void> clearAllHistory() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Bookmarks implements BookmarkRepository {
  @override
  Future<void> deleteAllBookmarks() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
