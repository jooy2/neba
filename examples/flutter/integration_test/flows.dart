// The flows the app is checked with, written once and run two ways: on the
// host by `test/app_test.dart`, and on a simulator, an emulator or a device
// by `integration_test/app_test.dart`.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_showcase/main.dart';

/// Registers every flow with [testWidgets].
void flows() {
  testWidgets('starts on the demo list, with every demo reachable', (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp(colorScheme: NebaColorScheme.light));
    await tester.pumpAndSettle();

    for (final String key in demos.keys) {
      await tester.scrollUntilVisible(
        find.text(key),
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('demos')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text(key), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between the light and the dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp(colorScheme: NebaColorScheme.light));
    await tester.pumpAndSettle();

    BuildContext context = tester.element(find.text('Neba UI'));
    expect(NebaTheme.of(context).brightness, Brightness.light);

    await tester.tap(find.byKey(const Key('scheme')));
    await tester.pumpAndSettle();

    context = tester.element(find.text('Neba UI'));
    expect(NebaTheme.of(context).brightness, Brightness.dark);
  });
}
