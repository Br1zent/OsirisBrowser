import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/security/desktop_vault_migration.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('osiris_vault_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('copies all values and deletes legacy file only after success', () async {
    final file = File('${tempDir.path}/.osiris_vault');
    await file.writeAsString('{"password":"hash","salt":"salt-value"}');
    final stored = <String, String>{};

    await migrateLegacyVaultFile(
      file: file,
      storeIfAbsent: (key, value) async {
        stored[key] = value;
      },
    );

    expect(stored, {'password': 'hash', 'salt': 'salt-value'});
    expect(await file.exists(), isFalse);
  });

  test('preserves the legacy file if a secure-store write fails', () async {
    final file = File('${tempDir.path}/.osiris_vault');
    await file.writeAsString('{"password":"hash"}');

    await expectLater(
      migrateLegacyVaultFile(
        file: file,
        storeIfAbsent: (key, value) async {
          throw StateError('keyring unavailable');
        },
      ),
      throwsStateError,
    );

    expect(await file.exists(), isTrue);
  });

  test('preserves malformed vaults for recovery', () async {
    final file = File('${tempDir.path}/.osiris_vault');
    await file.writeAsString('not-json');

    await expectLater(
      migrateLegacyVaultFile(
        file: file,
        storeIfAbsent: (key, value) async {},
      ),
      throwsFormatException,
    );

    expect(await file.exists(), isTrue);
  });
}
