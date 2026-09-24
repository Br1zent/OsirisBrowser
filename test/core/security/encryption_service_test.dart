import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/security/encryption_service.dart';

void main() {
  final encryption = EncryptionService.instance;
  final salt = Uint8List.fromList(List.generate(32, (index) => index));

  test('stores password verifiers as PBKDF2 and verifies them', () {
    final hash = encryption.computePasswordHash('correct horse', salt);

    expect(hash, startsWith('pbkdf2-sha256-v1:'));
    expect(encryption.verifyPassword('correct horse', salt, hash), isTrue);
    expect(encryption.verifyPassword('wrong password', salt, hash), isFalse);
  });

  test('verifies the legacy hash so existing accounts can be upgraded', () {
    const legacyHash = 'hgzDdL35+IhEaeDXfnXroT6YDtLTOmPzQxPIWN3aleA=';

    expect(
      encryption.verifyPassword('correct horse', salt, legacyHash),
      isTrue,
    );
    expect(
      encryption.verifyPassword('wrong password', salt, legacyHash),
      isFalse,
    );
  });
}
