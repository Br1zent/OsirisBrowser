import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/presentation/screens/browser/anti_fingerprint_js.dart';

void main() {
  test('does not inject page-world spoofing or an Osiris marker', () {
    final script = AntiFingerprintJS.buildScript();

    expect(script, isEmpty);
    expect(script, isNot(contains('__osiris')));
    expect(script, isNot(contains('privacyActive')));
  });
}
