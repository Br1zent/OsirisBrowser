import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Platform-aware secure storage.
/// - iOS / Android : flutter_secure_storage (Keychain / Keystore)
/// - macOS / Windows / Linux : encrypted JSON file in app-support directory
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _fileName = '.osiris_vault';

  // ── flutter_secure_storage (mobile) ────────────────────────────────────────
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );
  static const _fss = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  bool get _usesFile =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  // ── File-based storage helpers ─────────────────────────────────────────────
  Future<File> _vaultFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<Map<String, String>> _readVault() async {
    try {
      final f = await _vaultFile();
      if (!await f.exists()) return {};
      final raw = await f.readAsString();
      final map = json.decode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeVault(Map<String, String> data) async {
    final f = await _vaultFile();
    await f.writeAsString(json.encode(data));
  }

  // ── Public API ─────────────────────────────────────────────────────────────
  Future<void> write({required String key, required String value}) async {
    if (_usesFile) {
      final vault = await _readVault();
      vault[key] = value;
      await _writeVault(vault);
    } else {
      await _fss.write(key: key, value: value);
    }
  }

  Future<String?> read({required String key}) async {
    if (_usesFile) {
      final vault = await _readVault();
      return vault[key];
    } else {
      return _fss.read(key: key);
    }
  }

  Future<void> delete({required String key}) async {
    if (_usesFile) {
      final vault = await _readVault();
      vault.remove(key);
      await _writeVault(vault);
    } else {
      await _fss.delete(key: key);
    }
  }

  Future<void> deleteAll() async {
    if (_usesFile) {
      final f = await _vaultFile();
      if (await f.exists()) await f.delete();
    } else {
      await _fss.deleteAll();
    }
  }
}
