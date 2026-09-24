import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/security/database_key_envelope.dart';

void main() {
  const dbKey = <int>[
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  ];
  const wrappingKey = <int>[
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
  ];

  test('round trips a database key without storing it in clear', () async {
    final envelope = await DatabaseKeyEnvelope.seal(
      dbKey,
      wrappingKey: wrappingKey,
    );

    final bytes = base64Url.decode(envelope);
    expect(bytes.sublist(17, 49), isNot(equals(dbKey)));
    expect(
      await DatabaseKeyEnvelope.open(envelope, wrappingKey: wrappingKey),
      dbKey,
    );
  });

  test('uses a fresh nonce for each envelope', () async {
    final first = await DatabaseKeyEnvelope.seal(
      dbKey,
      wrappingKey: wrappingKey,
    );
    final second = await DatabaseKeyEnvelope.seal(
      dbKey,
      wrappingKey: wrappingKey,
    );

    expect(first, isNot(second));
  });

  test('rejects wrong wrapping keys and tampering', () async {
    final envelope = await DatabaseKeyEnvelope.seal(
      dbKey,
      wrappingKey: wrappingKey,
    );

    await expectLater(
      DatabaseKeyEnvelope.open(
        envelope,
        wrappingKey: List<int>.filled(32, 99),
      ),
      throwsA(anything),
    );

    final bytes = base64Url.decode(envelope);
    bytes[bytes.length - 1] ^= 1;
    await expectLater(
      DatabaseKeyEnvelope.open(
        base64Url.encode(bytes),
        wrappingKey: wrappingKey,
      ),
      throwsA(anything),
    );
  });

  test('rejects unknown envelope versions', () async {
    final envelope = await DatabaseKeyEnvelope.seal(
      dbKey,
      wrappingKey: wrappingKey,
    );
    final bytes = base64Url.decode(envelope);
    bytes[4] = 2;

    await expectLater(
      DatabaseKeyEnvelope.open(
        base64Url.encode(bytes),
        wrappingKey: wrappingKey,
      ),
      throwsFormatException,
    );
  });

  test('rejects non-256-bit database and wrapping keys', () async {
    await expectLater(
      DatabaseKeyEnvelope.seal([1, 2, 3], wrappingKey: wrappingKey),
      throwsArgumentError,
    );
    await expectLater(
      DatabaseKeyEnvelope.seal(dbKey, wrappingKey: [1, 2, 3]),
      throwsArgumentError,
    );
  });
}
