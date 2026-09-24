import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../domain/repositories/browser_data_repository.dart';

class BrowserDataRepositoryImpl implements BrowserDataRepository {
  @override
  Future<void> clearAll() async {
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android &&
        platform != TargetPlatform.iOS &&
        platform != TargetPlatform.macOS) {
      throw UnsupportedError('Web data clearing is unsupported on $platform');
    }

    await InAppWebViewController.clearAllCache();
    await CookieManager.instance().deleteAllCookies();

    final storage = WebStorageManager.instance();
    if (platform == TargetPlatform.android) {
      await storage.deleteAllData();
    } else {
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
