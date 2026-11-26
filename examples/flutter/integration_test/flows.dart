// The flows the app is checked with, written once and run two ways: on the
// host by `test/app_test.dart`, and on a simulator, an emulator or a device
// by `integration_test/app_test.dart`.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba_example/demos/registry.dart';
import 'package:neba_showcase/main.dart';

/// Registers every flow with [testWidgets].
void flows() {
  testWidgets('starts on the demo list, with every demo reachable', (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp(colorScheme: NebaColorScheme.light));
    await tester.pump(const Duration(seconds: 1));

    // The list's own position, moved directly: a drag in the middle of the
    // list can land on a demo that scrolls on its own and take nothing along.
    final ScrollPosition list = tester
        .state<ScrollableState>(
          find
              .descendant(of: find.byKey(const Key('demos')), matching: find.byType(Scrollable))
              .first,
        )
        .position;

    for (final String key in demos.keys) {
      while (find.text(key).evaluate().isEmpty && list.pixels < list.maxScrollExtent) {
        list.jumpTo(math.min(list.pixels + 200, list.maxScrollExtent));
        await tester.pump();
      }

      expect(find.text(key), findsOneWidget, reason: key);
    }

    expect(tester.takeException(), isNull);

    // Gone, so a busy button's ring is not left turning when the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switches between the light and the dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp(colorScheme: NebaColorScheme.light));
    await tester.pump(const Duration(seconds: 1));

    BuildContext context = tester.element(find.text('Neba UI'));
    expect(NebaTheme.of(context).brightness, Brightness.light);

    await tester.tap(find.byKey(const Key('scheme')));
    await tester.pump(const Duration(seconds: 1));

    context = tester.element(find.text('Neba UI'));
    expect(NebaTheme.of(context).brightness, Brightness.dark);

    await tester.pumpWidget(const SizedBox());
  });
}
