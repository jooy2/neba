// That every demo builds, in both themes, without an exception or an overflow.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_example/main.dart';

void main() {
  for (final MapEntry<String, Widget Function()> demo in demos.entries) {
    for (final NebaColorScheme scheme in <NebaColorScheme>[
      NebaColorScheme.light,
      NebaColorScheme.dark,
    ]) {
      testWidgets('${demo.key} builds in the ${scheme.name} theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          GalleryApp(query: <String, String>{'demo': demo.key, 'theme': scheme.name}),
        );
        // A second of frames rather than a settle: a busy button's ring turns
        // for as long as it is on screen, so some demos never settle.
        await tester.pump(const Duration(seconds: 1));

        expect(tester.takeException(), isNull);

        // Gone, so nothing is left running when the test ends.
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('lists every demo without a query', (WidgetTester tester) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();

    expect(find.text(demos.keys.first), findsOneWidget);
  });
}
