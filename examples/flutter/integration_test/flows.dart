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

  testWidgets('signs up through the three steps of the sign-up screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ShowcaseApp(colorScheme: NebaColorScheme.light, demo: 'concepts/signup'),
    );
    await tester.pump(const Duration(seconds: 1));

    Future<void> press(String label) async {
      final Finder target = find.text(label).last;

      await tester.ensureVisible(target);
      await tester.pump();
      await tester.tap(target);
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> type(Finder field, String text) async {
      await tester.ensureVisible(field);
      await tester.pump();
      await tester.enterText(field, text);
      await tester.pump();
    }

    Finder field(String label) {
      return find.descendant(
        of: find.ancestor(of: find.text(label), matching: find.byType(NebaTextField)).first,
        matching: find.byType(EditableText),
      );
    }

    // Who you are: Continue stays off until all three are right.
    await type(field('Full name'), 'Ada Bell');
    await type(field('Work email'), 'ada@example.com');
    await type(field('Password'), 'Correct-horse-9');
    await press('Continue');
    expect(find.text('Step 2 of 3 · Workspace'), findsOneWidget);

    // What you are making.
    await type(field('Workspace URL'), 'Northwind');
    expect(find.text('northwind'), findsOneWidget, reason: 'the address is written lowercase');
    await press('Continue');
    expect(find.text('Step 3 of 3 · Verify'), findsOneWidget);

    // Proving the address, and agreeing to the terms.
    await type(
      find.descendant(of: find.byType(NebaOtpField), matching: find.byType(EditableText)),
      '123456',
    );
    await press('I agree to the terms of service and the privacy notice');
    await press('Create workspace');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Workspace ready'), findsOneWidget);
    expect(find.text("You're in"), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });
}
