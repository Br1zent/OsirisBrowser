import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../domain/repositories/browser_data_repository.dart';

class BrowserDataRepositoryImpl implements BrowserDataRepository {
  @override
  Future<void> clearAll() async {
    await InAppWebViewController.clearAllCache();
    await CookieManager.instance().deleteAllCookies();

    final storage = WebStorageManager.instance();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await storage.deleteAllData();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final records = await storage.fetchDataRecords(
        dataTypes: WebsiteDataType.values,
      );
      if (records.isNotEmpty) {
        await storage.removeDataFor(
          dataTypes: WebsiteDataType.values,
          dataRecords: records,
        );
      }
    }
  }
}
