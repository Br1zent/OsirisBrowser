import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/app_database.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../../domain/repositories/history_repository.dart';
import 'master_password_service.dart';

enum WipeScope { nuke, reset }

class WipeReport {
  final Map<String, String?> components;

  const WipeReport(this.components);

  bool get succeeded => components.values.every((failure) => failure == null);
  List<String> get failedComponents => components.entries
      .where((entry) => entry.value != null)
      .map((entry) => entry.key)
      .toList(growable: false);
}

/// Coordinates app and native WebView cleanup. A durable marker makes an
/// interrupted operation retry before the app exposes its normal routes.
class DataWipeService {
  static const _markerName = 'osiris_pending_wipe';

  final AppDatabase database;
  final HistoryRepository history;
  final BookmarkRepository bookmarks;
  final SharedPreferences preferences;

  DataWipeService({
    required this.database,
    required this.history,
    required this.bookmarks,
    required this.preferences,
  });

  Future<WipeReport> wipe({
    required WipeScope scope,
    required Future<void> Function() stopWebViews,
    bool clearBookmarks = false,
  }) async {
    if (scope == WipeScope.nuke && !clearBookmarks) {
      return const WipeReport({
        'bookmarks': 'preserving bookmarks is not supported during a full nuke',
      });
    }
    final results = <String, String?>{};
    final marker = await _markerFile();
    try {
      await _persistMarker(marker, scope, clearBookmarks);
      results['pendingMarker'] = null;
    } catch (_) {
      return WipeReport({'pendingMarker': 'could not persist pending wipe'});
    }

    await _step(results, 'stopWebViews', stopWebViews);
    if (results['stopWebViews'] != null) return WipeReport(results);
    await _step(results, 'webViewData', _clearWebViewData);
    await _step(results, 'history', history.clearAllHistory);
    if (clearBookmarks || scope == WipeScope.reset) {
      await _step(results, 'bookmarks', bookmarks.deleteAllBookmarks);
    }

    final fullReset = scope == WipeScope.reset || scope == WipeScope.nuke;
    if (fullReset) {
      await _step(results, 'databaseFiles', database.closeAndDeleteFiles);
      await _step(results, 'settings', () async { await preferences.clear(); });
      if (results.values.every((failure) => failure == null)) {
        await _step(results, 'credentials',
            MasterPasswordService.instance.deleteAllCredentials);
      } else {
        results['credentials'] = 'deferred until other components are cleared';
      }
    }

    if (results.values.every((failure) => failure == null)) {
      try {
        await marker.delete();
        results['pendingMarker'] = null;
      } catch (_) {
        results['pendingMarker'] = 'could not remove pending wipe marker';
      }
    }
    return WipeReport(results);
  }

  Future<bool> resumePendingAfterUnlock({
    required Future<void> Function() stopWebViews,
  }) async {
    final marker = await _markerFile();
    if (!await marker.exists()) return true;
    final parts = (await marker.readAsString()).split(':');
    if (parts.length != 2 ||
        parts[0] != 'nuke' ||
        !{'true', 'false'}.contains(parts[1])) {
      throw StateError('Invalid pending wipe marker');
    }
    final report = await wipe(
      scope: WipeScope.nuke,
      clearBookmarks: parts[1] == 'true',
      stopWebViews: stopWebViews,
    );
    if (!report.succeeded) {
      throw StateError('Pending wipe incomplete: ${report.failedComponents.join(', ')}');
    }
    return false;
  }

  static Future<File> _markerFile() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File(p.join(directory.path, _markerName));
  }

  static Future<void> _persistMarker(
      File marker, WipeScope scope, bool clearBookmarks) async {
    final contents = '${scope.name}:$clearBookmarks';
    if (await marker.exists()) {
      if (await marker.readAsString() == contents) return;
      throw StateError('A different wipe is already pending');
    }
    final temp = File('${marker.path}.tmp');
    await temp.writeAsString(contents, flush: true);
    await temp.rename(marker.path);
  }

  static Future<void> completePendingWipeBeforeUnlock({
    required SharedPreferences preferences,
  }) async {
    final marker = await _markerFile();
    if (!await marker.exists()) return;
    final parts = (await marker.readAsString()).split(':');
    if (parts.length != 2 ||
        !{'nuke', 'reset'}.contains(parts[0]) ||
        !{'true', 'false'}.contains(parts[1])) {
      throw StateError('Invalid pending wipe marker');
    }
    if (parts[0] == 'nuke' && parts[1] != 'true') {
      throw StateError('Pending NUKE cannot retain bookmarks safely');
    }
    if (parts[0] != 'reset' && parts[0] != 'nuke') return;
    await _clearWebViewData();
    await AppDatabase.deleteFiles();
    await preferences.clear();
    await MasterPasswordService.instance.deleteAllCredentials();
    await marker.delete();
  }

  static Future<void> _clearWebViewData() async {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.iOS &&
        platform != TargetPlatform.macOS) {
      throw UnsupportedError('Native WebView data wipe is unavailable on $platform');
    }
    await InAppWebViewController.clearAllCache();
    await CookieManager.instance().deleteAllCookies();
    final storage = WebStorageManager.instance();
    if (platform == TargetPlatform.android) {
      await storage.deleteAllData();
      return;
    }
    final records = await storage.fetchDataRecords(dataTypes: WebsiteDataType.values);
    if (records.isNotEmpty) {
      await storage.removeDataFor(
        dataTypes: WebsiteDataType.values,
        dataRecords: records,
      );
    }
  }

  static Future<void> _step(
      Map<String, String?> report, String name, Future<void> Function() action) async {
    try {
      await action();
      report[name] = null;
    } catch (error) {
      report[name] = error is UnsupportedError ? error.message : 'operation failed';
    }
  }
}
