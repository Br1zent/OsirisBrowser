import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'desktop_vault_migration.dart';

/// Platform-aware secure storage.
/// - iOS / Android : flutter_secure_storage (Keychain / Keystore)
/// - Desktop       : flutter_secure_storage (native platform secure storage)
///
/// Existing desktop JSON vaults are copied into the platform store before the
/// legacy file is removed.
class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _fileName = '.osiris_vault';
  static const _keyIndex = '__osiris_secure_storage_keys_v1';

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

  Future<void>? _migration;
  Future<void> _mutationQueue = Future<void>.value();

  Future<File> _vaultFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _ensureLegacyVaultMigrated() async {
    final pending = _migration ??= _migrateLegacyVault();
    try {
      await pending;
    } catch (_) {
      _migration = null;
      rethrow;
    }
  }

  Future<void> _migrateLegacyVault() async {
    final file = await _vaultFile();
    await migrateLegacyVaultFile(
      file: file,
      storeIfAbsent: (key, value) async {
        if (await _fss.read(key: key) != null) return;
        await _trackKey(key);
        await _fss.write(key: key, value: value);
      },
    );
  }

  Future<Set<String>> _readKeyIndex() async {
    final raw = await _fss.read(key: _keyIndex);
    if (raw == null) return <String>{};
    final decoded = json.decode(raw);
    if (decoded is! List || decoded.any((key) => key is! String)) {
      throw const FormatException('Invalid secure-storage key index');
    }
    return decoded.cast<String>().toSet();
  }

  Future<void> _writeKeyIndex(Set<String> keys) async {
    final sorted = keys.toList()..sort();
    await _fss.write(key: _keyIndex, value: json.encode(sorted));
  }

  Future<void> _trackKey(String key) async {
    final keys = await _readKeyIndex();
    if (keys.add(key)) await _writeKeyIndex(keys);
  }

  Future<void> _untrackKey(String key) async {
    final keys = await _readKeyIndex();
    if (keys.remove(key)) await _writeKeyIndex(keys);
  }

  Future<void> _enqueueMutation(Future<void> Function() action) {
    final pending = _mutationQueue.then((_) => action());
    _mutationQueue = pending.catchError((Object _) {});
    return pending;
  }

  Future<void> write({required String key, required String value}) =>
      _enqueueMutation(() async {
        await _ensureLegacyVaultMigrated();
        await _trackKey(key);
        await _fss.write(key: key, value: value);
      });

  Future<String?> read({required String key}) async {
    await _ensureLegacyVaultMigrated();
    return _fss.read(key: key);
  }

  Future<void> delete({required String key}) => _enqueueMutation(() async {
        await _ensureLegacyVaultMigrated();
        await _fss.delete(key: key);
        await _untrackKey(key);
      });

  Future<void> deleteAll() => _enqueueMutation(() async {
        // Destructive reset should still work if legacy data is malformed.
        final file = await _vaultFile();
        if (await file.exists()) await file.delete();

        if (Platform.isWindows) {
          // flutter_secure_storage 9.2.4 does not implement Windows deleteAll.
          for (final key in await _readKeyIndex()) {
            await _fss.delete(key: key);
          }
          await _fss.delete(key: _keyIndex);
        } else {
          await _fss.deleteAll();
        }
        _migration = null;
      });
}
