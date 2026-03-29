import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';
import '../constants/app_constants.dart';

class EncryptionService {
  EncryptionService._();

  static final EncryptionService _instance = EncryptionService._();
  static EncryptionService get instance => _instance;

  Uint8List? _derivedKey;

  bool get isInitialized => _derivedKey != null;

  /// Derives a 256-bit AES key from the master password using PBKDF2-SHA256
  Future<Uint8List> deriveKey(String password, Uint8List salt) async {
    final passwordBytes = utf8.encode(password);

    final params = Pbkdf2Parameters(
      salt,
      AppConstants.pbkdf2Iterations,
      AppConstants.keyLength,
    );

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(params);

    final keyBytes = Uint8List(AppConstants.keyLength);
    pbkdf2.deriveKey(Uint8List.fromList(passwordBytes), 0, keyBytes, 0);

    return keyBytes;
  }

  /// Generate a cryptographically secure random salt
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(AppConstants.saltLength, (_) => random.nextInt(256)),
    );
  }

  /// Generate a cryptographically secure random IV
  Uint8List generateIV() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(AppConstants.ivLength, (_) => random.nextInt(256)),
    );
  }

  /// Initialize the encryption service with a derived key
  void initializeWithKey(Uint8List key) {
    _derivedKey = key;
  }

  /// Clear the in-memory key (on logout/lock)
  void clearKey() {
    if (_derivedKey != null) {
      _derivedKey!.fillRange(0, _derivedKey!.length, 0);
      _derivedKey = null;
    }
  }

  /// Encrypt a string using AES-256-CBC with the derived key
  /// Returns base64(iv + ciphertext)
  String encrypt(String plaintext) {
    if (_derivedKey == null) {
      throw StateError('EncryptionService not initialized');
    }

    final iv = enc.IV(generateIV());
    final key = enc.Key(_derivedKey!);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Combine IV + ciphertext and base64 encode
    final combined = Uint8List(AppConstants.ivLength + encrypted.bytes.length);
    combined.setRange(0, AppConstants.ivLength, iv.bytes);
    combined.setRange(AppConstants.ivLength, combined.length, encrypted.bytes);

    return base64.encode(combined);
  }

  /// Decrypt a string encrypted by [encrypt]
  String decrypt(String ciphertext) {
    if (_derivedKey == null) {
      throw StateError('EncryptionService not initialized');
    }

    final combined = base64.decode(ciphertext);
    if (combined.length < AppConstants.ivLength) {
      throw ArgumentError('Invalid ciphertext: too short');
    }

    final ivBytes = combined.sublist(0, AppConstants.ivLength);
    final encryptedBytes = combined.sublist(AppConstants.ivLength);

    final iv = enc.IV(Uint8List.fromList(ivBytes));
    final key = enc.Key(_derivedKey!);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    return encrypter.decrypt(enc.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv);
  }

  /// Encrypt bytes - useful for binary data
  String encryptBytes(Uint8List data) {
    return encrypt(base64.encode(data));
  }

  /// Decrypt bytes
  Uint8List decryptBytes(String ciphertext) {
    final decoded = decrypt(ciphertext);
    return base64.decode(decoded);
  }

  /// Hash a value using SHA-256 (for verification purposes)
  String hashSHA256(String input) {
    final digest = SHA256Digest();
    final bytes = Uint8List.fromList(utf8.encode(input));
    digest.update(bytes, 0, bytes.length);
    final hash = Uint8List(digest.digestSize);
    digest.doFinal(hash, 0);
    return base64.encode(hash);
  }

  /// Verify a password against a stored hash
  bool verifyPassword(String password, Uint8List salt, String storedHash) {
    final verifyHash = _computePasswordHash(password, salt);
    return verifyHash == storedHash;
  }

  /// Compute password hash for storage
  String computePasswordHash(String password, Uint8List salt) {
    return _computePasswordHash(password, salt);
  }

  String _computePasswordHash(String password, Uint8List salt) {
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final saltedPassword = Uint8List(passwordBytes.length + salt.length);
    saltedPassword.setRange(0, passwordBytes.length, passwordBytes);
    saltedPassword.setRange(passwordBytes.length, saltedPassword.length, salt);

    final digest = SHA256Digest();
    // Multiple rounds for additional security
    Uint8List current = saltedPassword;
    for (int i = 0; i < 10000; i++) {
      digest.reset();
      final result = Uint8List(digest.digestSize);
      digest.update(current, 0, current.length);
      digest.doFinal(result, 0);
      current = result;
    }
    return base64.encode(current);
  }

  /// Generate a secure random database encryption key
  String generateDatabaseKey() {
    final random = Random.secure();
    final keyBytes =
        Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
    return base64.encode(keyBytes);
  }
}
