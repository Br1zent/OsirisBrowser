import 'dart:convert';
import 'dart:io';

/// Copies a legacy JSON vault into secure storage, then removes the source.
/// The source stays intact if parsing or any secure-store write fails.
Future<void> migrateLegacyVaultFile({
  required File file,
  required Future<void> Function(String key, String value) storeIfAbsent,
}) async {
  if (!await file.exists()) return;

  final decoded = json.decode(await file.readAsString());
  if (decoded is! Map<String, dynamic> ||
      decoded.values.any((value) => value is! String)) {
    throw const FormatException('Invalid legacy secure-storage vault');
  }

  for (final entry in decoded.entries) {
    await storeIfAbsent(entry.key, entry.value as String);
  }

  await file.delete();
}
