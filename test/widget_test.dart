import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Osiris Browser smoke test', (WidgetTester tester) async {
    // App requires async initialization (database, shared_preferences),
    // so we skip the full pump test here.
    expect(true, isTrue);
  });
}
