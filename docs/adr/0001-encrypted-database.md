# ADR 0001: Encrypted database and database-key envelope

- Status: Proposed; security review and platform-baseline decision required
- Scope: SEC 01, SEC 08
- Date: 2026-09-24

## Context

Osiris stores bookmarks, history, and settings in a plaintext SQLite database opened through `sqflite`. The existing crypto packages already include `cryptography`; `pubspec.lock` resolves it to 2.9.0. The current database has three tables and no migration history. The declared SDK floor is Dart 3.1 / Flutter 3.13, while the lockfile currently records Dart 3.5 / Flutter 3.24.

The current `sqflite_sqlcipher` package documents SQLCipher on Android and iOS, is published by an unverified uploader, and does not document a desktop backend. The old `sqlcipher_flutter_libs` route is marked obsolete. The maintained `sqlite3` v3 package supports SQLCipher native assets across Android, iOS, macOS, Linux, and Windows. It can be combined with `sqflite_common_ffi` to retain the current sqflite-style asynchronous API. The current v3 pairing requires Dart 3.10 / Flutter 3.38, so it is incompatible with the declared minimum.

## Decision proposed

### Key hierarchy and envelope

1. SEC 08 derives a 32-byte wrapping key from the master password with Argon2id and a random salt. Its KDF version and calibrated parameters are stored with the vault metadata.
2. Generate a random 32-byte database key. Do not use the master password or its derived key directly as the SQLCipher key.
3. Wrap the database key with AES-256-GCM using a fresh 96-bit nonce. Authenticate a fixed domain separator and envelope version as associated data. The versioned binary envelope is stored as base64 in the OS secure storage record owned by the vault implementation.
4. Keep the unwrapped database key only in memory for the unlocked session. Wipe its byte buffer on lock as best effort; do not persist or log it.

This PR implements only the standalone v1 AES-GCM envelope primitive. It accepts an already-derived wrapping key and does not implement password derivation, vault persistence, or database opening. Those remain coordinated with SEC 08.

### Database engine

After an explicit SDK-floor decision, use `sqlite3` v3 and `sqflite_common_ffi` with the sqlite3 build hook selecting the SQLCipher community build. Preserve the existing async sqflite API where possible, use the FFI backend on all five native platforms, and set the key before any schema query. Do not enable the ordinary SQLite build as a fallback. At startup, verify `PRAGMA cipher_version`; fail closed if it is missing.

The dependency versions and native build artifacts must be pinned in `pubspec.lock` and reviewed for licenses and maintenance status. SQLCipher's build links OpenSSL on Android, Linux, and Windows; these platform packaging and licensing requirements need release-build verification. macOS, iOS, and Linux packaging also require native smoke tests.

### Plaintext migration and rollback

1. Close database handles and stop writers. Detect the existing plaintext SQLite header and a migration marker; never treat unreadable, encrypted, or unknown data as a new empty database.
2. Create a new encrypted database at a sibling temporary path with a newly generated database key. Copy all supported tables and settings in a transaction.
3. Reopen the temporary database with the key, verify schema/version, row counts, and deterministic row digests for every table. Confirm a wrong key fails and the file does not contain the SQLite plaintext header or test marker strings.
4. Keep the original database and its WAL/SHM files untouched until the encrypted copy passes verification. Record a resumable migration phase before same-volume renames. On any error, leave the app locked and restore the original or safely resume; never overwrite the only readable copy.
5. Reopen and re-verify the final encrypted path before deleting the plaintext backup, WAL, SHM, and temporary files. Report cleanup failure as migration failure. Do not claim physical erasure of flash storage.

The marker and rename recovery protocol must be implemented and fault-injection tested before replacing the current database opener. A partial migration must not run on the current release path.

## Consequences and gates

- The preferred maintained, shared SQLCipher backend requires raising the Flutter/Dart minimum to a compatible release (Dart 3.10 / Flutter 3.38). Do not silently drop desktop platforms or use an obsolete plugin to preserve the old declared floor.
- The existing `sqflite` API can remain largely intact through `sqflite_common_ffi`, but startup initialization and the database factory must be changed consistently across Android, iOS, macOS, Linux, Windows, and tests.
- No production database is switched to encryption until integration tests cover a new database, wrong key, tampered envelope, plaintext migration, every migration crash point, rollback, and forensic string scans on all supported platforms.
- KDF parameters must be benchmarked on the slowest supported device; do not copy a generic memory/time setting without measuring unlock latency and memory pressure.
- No new package dependency is added by this ADR/envelope tranche. `cryptography` 2.9.0 is already locked and supplies AES-GCM. The package's Argon2id API is suitable for SEC 08 integration, subject to performance tests.

## Evidence reviewed

- `sqlite3` package documentation: <https://pub.dev/packages/sqlite3>
- sqlite3 build-hook documentation (SQLCipher source, platform/license/OpenSSL notes): <https://pub.dev/documentation/sqlite3/latest/topics/hook-topic.html>
- `sqflite_common_ffi` documentation (five native platforms, v3 pairing, current API): <https://pub.dev/packages/sqflite_common_ffi>
- sqlite3 v3 upgrade notes: <https://github.com/simolus3/sqlite3.dart/blob/main/UPGRADING_TO_V3.md>
- SQLCipher Flutter package metadata and API: <https://pub.dev/packages/sqflite_sqlcipher>
- `cryptography` Argon2id and AES-GCM APIs: <https://pub.dev/documentation/cryptography/latest/cryptography/Argon2id-class.html> and <https://pub.dev/documentation/cryptography/latest/cryptography/AesGcm-class.html>
