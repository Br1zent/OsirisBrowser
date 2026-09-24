import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Versioned AES-256-GCM wrapper for a random SQLCipher database key.
///
/// [wrappingKey] must be the 32-byte key produced by the vault's password KDF.
/// This class deliberately does not derive keys or persist secrets.
class DatabaseKeyEnvelope {
  DatabaseKeyEnvelope._();

  static final AesGcm _cipher = AesGcm.with256bits();
  static const List<int> _header = [0x4f, 0x53, 0x44, 0x42, 0x01]; // OSDB v1
  static const int _keyLength = 32;

  static Future<String> seal(
    List<int> databaseKey, {
    required List<int> wrappingKey,
  }) async {
    _checkKeyLength(databaseKey, 'databaseKey');
    _checkKeyLength(wrappingKey, 'wrappingKey');

    final box = await _cipher.encrypt(
      databaseKey,
      secretKey: SecretKey(wrappingKey),
      aad: _header,
    );
    return base64Url.encode([..._header, ...box.concatenation()]);
  }

  static Future<Uint8List> open(
    String envelope, {
    required List<int> wrappingKey,
  }) async {
    _checkKeyLength(wrappingKey, 'wrappingKey');

    final bytes = base64Url.decode(envelope);
    if (bytes.length != _header.length + _cipher.nonceLength +
        _keyLength + _cipher.macAlgorithm.macLength) {
      throw const FormatException('Invalid database key envelope length');
    }
    for (var i = 0; i < _header.length; i++) {
      if (bytes[i] != _header[i]) {
        throw const FormatException('Unsupported database key envelope');
      }
    }

    final box = SecretBox.fromConcatenation(
      bytes.sublist(_header.length),
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final key = await _cipher.decrypt(
      box,
      secretKey: SecretKey(wrappingKey),
      aad: _header,
    );
    if (key.length != _keyLength) {
      throw const FormatException('Invalid database key length');
    }
    return Uint8List.fromList(key);
  }

  static void _checkKeyLength(List<int> key, String name) {
    if (key.length != _keyLength) {
      throw ArgumentError.value(key.length, name, 'must be 32 bytes');
    }
  }
}
