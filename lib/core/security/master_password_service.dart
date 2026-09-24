import 'dart:convert';
import 'dart:typed_data';
import '../constants/app_constants.dart';
import 'encryption_service.dart';
import 'secure_storage.dart';

enum MasterPasswordStatus {
  notSet,
  set,
  verified,
  error,
}

class MasterPasswordService {
  MasterPasswordService._();

  static final MasterPasswordService _instance = MasterPasswordService._();
  static MasterPasswordService get instance => _instance;

  SecureStorage get _storage => SecureStorage.instance;

  void initialize() {}

  /// Check if master password has been set
  Future<bool> isMasterPasswordSet() async {
    try {
      final hash = await _storage.read(key: AppConstants.masterPasswordKey);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Set up the master password for the first time
  Future<bool> setupMasterPassword(String password) async {
    try {
      if (!isPasswordValid(password)) return false;

      final salt = EncryptionService.instance.generateSalt();
      final hash = EncryptionService.instance.computePasswordHash(password, salt);

      await _storage.write(
        key: AppConstants.encryptionSaltKey,
        value: base64.encode(salt),
      );
      await _storage.write(
        key: AppConstants.masterPasswordKey,
        value: hash,
      );

      final derivedKey =
          await EncryptionService.instance.deriveKey(password, salt);
      EncryptionService.instance.initializeWithKey(derivedKey);

      final dbKey = EncryptionService.instance.generateDatabaseKey();
      final encryptedDbKey = EncryptionService.instance.encrypt(dbKey);
      await _storage.write(
        key: AppConstants.dbEncryptionKeyKey,
        value: encryptedDbKey,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify the master password
  Future<MasterPasswordStatus> verifyMasterPassword(String password) async {
    try {
      final storedHash =
          await _storage.read(key: AppConstants.masterPasswordKey);
      final storedSalt =
          await _storage.read(key: AppConstants.encryptionSaltKey);

      if (storedHash == null || storedSalt == null) {
        return MasterPasswordStatus.notSet;
      }

      final salt = base64.decode(storedSalt);
      final isValid = EncryptionService.instance
          .verifyPassword(password, Uint8List.fromList(salt), storedHash);

      if (!isValid) return MasterPasswordStatus.error;

      // Upgrade legacy fast hashes after a successful login, keeping existing
      // installations usable while improving their offline-cracking cost.
      if (!storedHash.startsWith('pbkdf2-sha256-v1:')) {
        await _storage.write(
          key: AppConstants.masterPasswordKey,
          value: EncryptionService.instance.computePasswordHash(
            password,
            Uint8List.fromList(salt),
          ),
        );
      }

      final derivedKey = await EncryptionService.instance
          .deriveKey(password, Uint8List.fromList(salt));
      EncryptionService.instance.initializeWithKey(derivedKey);

      return MasterPasswordStatus.verified;
    } catch (e) {
      return MasterPasswordStatus.error;
    }
  }

  /// Get the decrypted database encryption key
  Future<String?> getDatabaseKey() async {
    try {
      final encryptedKey =
          await _storage.read(key: AppConstants.dbEncryptionKeyKey);
      if (encryptedKey == null) return null;
      if (!EncryptionService.instance.isInitialized) return null;
      return EncryptionService.instance.decrypt(encryptedKey);
    } catch (e) {
      return null;
    }
  }

  /// Change the master password
  Future<bool> changeMasterPassword(
      String oldPassword, String newPassword) async {
    try {
      if (!isPasswordValid(newPassword)) return false;
      final status = await verifyMasterPassword(oldPassword);
      if (status != MasterPasswordStatus.verified) return false;

      final dbKey = await getDatabaseKey();
      if (dbKey == null) return false;

      final newSalt = EncryptionService.instance.generateSalt();
      final newHash =
          EncryptionService.instance.computePasswordHash(newPassword, newSalt);
      final newDerivedKey =
          await EncryptionService.instance.deriveKey(newPassword, newSalt);
      EncryptionService.instance.initializeWithKey(newDerivedKey);
      final newEncryptedDbKey = EncryptionService.instance.encrypt(dbKey);

      await _storage.write(
          key: AppConstants.encryptionSaltKey,
          value: base64.encode(newSalt));
      await _storage.write(
          key: AppConstants.masterPasswordKey, value: newHash);
      await _storage.write(
          key: AppConstants.dbEncryptionKeyKey, value: newEncryptedDbKey);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lock the app (clear in-memory key)
  void lock() {
    EncryptionService.instance.clearKey();
  }

  /// Delete all stored credentials (full reset)
  Future<void> deleteAllCredentials() async {
    await _storage.deleteAll();
    EncryptionService.instance.clearKey();
  }

  /// Validate password format
  bool isPasswordValid(String password) {
    return password.length >= AppConstants.minPasswordLength &&
        password.length <= AppConstants.maxPasswordLength;
  }

  /// Check biometric availability
  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: AppConstants.biometricEnabledKey);
    return val == 'true';
  }

  /// Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
        key: AppConstants.biometricEnabledKey,
        value: enabled ? 'true' : 'false');
  }
}
