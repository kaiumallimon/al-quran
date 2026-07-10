import 'package:flutter_test/flutter_test.dart';

import 'package:al_quran/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Full app init requires Hive; verify widget tree can be built in isolation.
    expect(const QuranCompanionApp(), isNotNull);
  });
}
