import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/core/security/master_password_service.dart';

void main() {
  test('only a completely absent vault permits first-run setup', () {
    expect(
      MasterPasswordService.classifyConfiguration([null, null, null]),
      MasterPasswordConfiguration.notSet,
    );
    expect(
      MasterPasswordService.classifyConfiguration(['hash', 'salt', 'wrapped']),
      MasterPasswordConfiguration.configured,
    );
  });

  test('partial and empty vaults require recovery', () {
    for (final values in [
      ['hash', null, 'wrapped'],
      ['hash', 'salt', null],
      ['', 'salt', 'wrapped'],
    ]) {
      expect(
        MasterPasswordService.classifyConfiguration(values),
        MasterPasswordConfiguration.recoveryRequired,
      );
    }
  });
}
