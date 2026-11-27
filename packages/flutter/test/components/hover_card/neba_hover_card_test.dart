// NebaHoverCard: the suite the React package runs on HoverCard, asked the way
// Flutter asks it — the sheet it draws and where, and what the pointer, the
// keyboard and a finger do — rather than the elements it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  const Key triggerKey = Key('trigger');

  Widget scene(Widget child) => host(Overlay.wrap(child: Center(child: child)));

  Widget mention() {
    return NebaButton(
      key: triggerKey,
      onPressed: () {},
      variant: NebaVariant.text,
      child: const Text('@neba'),
    );
  }

  Finder sheet() =>
      find.descendant(of: find.byType(NebaFloatingSheet), matching: find.byType(NebaSheet));

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<TestGesture> mouseAt(WidgetTester tester, Offset position) async {
    final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: position);
    addTearDown(mouse.removePointer);
    await tester.pump();

    return mouse;
  }

  group('rendering', () {
    testWidgets('renders nothing until it is open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            trigger: mention(),
            title: const Text('Neba'),
            child: const Text('A component library.'),
          ),
        ),
      );

      expect(find.text('A component library.'), findsNothing);
    });

    testWidgets('renders its title, description and body when open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            defaultOpen: true,
            trigger: mention(),
            title: const Text('Neba'),
            description: const Text('1.21.0'),
            child: const Text('A component library.'),
          ),
        ),
      );

      expect(find.text('Neba'), findsOneWidget);
      expect(find.text('1.21.0'), findsOneWidget);
      expect(find.text('A component library.'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Neba'))).style.fontWeight,
        FontWeight.w600,
      );
      expect(DefaultTextStyle.of(tester.element(find.text('1.21.0'))).style.color, tokens.mutedFg);
    });

    testWidgets('adds nothing of its own around the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(scene(mention()));
      final Rect alone = tester.getRect(find.byKey(triggerKey));

      await tester.pumpWidget(scene(NebaHoverCard(trigger: mention(), child: const Text('Body'))));

      expect(tester.getRect(find.byKey(triggerKey)), alone);
    });

    testWidgets('reflects changed content on a rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(defaultOpen: true, trigger: mention(), title: const Text('Before'))),
      );
      await tester.pumpWidget(
        scene(NebaHoverCard(defaultOpen: true, trigger: mention(), title: const Text('After'))),
      );

      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('draws its title without announcing it as a name', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            defaultOpen: true,
            trigger: mention(),
            title: const Text('Neba'),
            child: const Text('Body'),
          ),
        ),
      );

      final SemanticsData card = tester
          .getSemantics(
            find
                .ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(Semantics))
                .first,
          )
          .getSemanticsData();
      expect(card.label, isEmpty);
      expect(card.role, SemanticsRole.none);
      expect(find.bySemanticsLabel('Neba'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('behaviour', () {
    testWidgets('opens when a mouse rests on the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(delay: Duration.zero, trigger: mention(), child: const Text('Body'))),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('waits 600 milliseconds by default', (WidgetTester tester) async {
      await tester.pumpWidget(scene(NebaHoverCard(trigger: mention(), child: const Text('Body'))));

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('Body'), findsNothing);

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();
      await tester.pump();
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('stays 300 milliseconds after the pointer leaves, long enough to reach it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(delay: Duration.zero, trigger: mention(), child: const Text('Body'))),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);

      // Out to the side, and back onto the card before the wait is up.
      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(milliseconds: 200));
      await mouse.moveTo(tester.getCenter(find.text('Body')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Body'), findsOneWidget);

      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(milliseconds: 350));
      await settle(tester);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('opens on keyboard focus after the same wait', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            delay: const Duration(milliseconds: 200),
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );

      Focus.of(tester.element(find.text('@neba'))).requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Body'), findsNothing);

      await tester.pump(const Duration(milliseconds: 150));
      await settle(tester);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('never opens on a touch', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(delay: Duration.zero, trigger: mention(), child: const Text('Body'))),
      );

      await tester.tap(find.byKey(triggerKey));
      await settle(tester);

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('closes on Escape and on a press elsewhere', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(defaultOpen: true, trigger: mention(), child: const Text('Body'))),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Body'), findsNothing);

      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            key: const Key('again'),
            defaultOpen: true,
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );
      await tester.tapAt(const Offset(5, 590), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('reports opening to the caller', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            delay: Duration.zero,
            onOpenChange: changes.add,
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);

      expect(changes, <bool>[true]);
    });

    testWidgets('honours a controlled open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            open: false,
            onOpenChange: (bool _) {},
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );
      expect(find.text('Body'), findsNothing);

      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            open: true,
            onOpenChange: (bool _) {},
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Body'), findsOneWidget);
    });
  });

  group('the sheet', () {
    testWidgets('is the popover sheet, with the colour family on its edge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            defaultOpen: true,
            color: NebaColor.success,
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );

      final NebaSheet drawn = tester.widget<NebaSheet>(sheet());
      expect(drawn.fill, tokens.panelPress);
      expect(drawn.edge, tokens.roles(NebaColor.success).line);
      expect(drawn.plate, NebaPlate.glass);
      expect(drawn.elevation, 3);
    });

    testWidgets('caps its width a rung wider than a popover', (WidgetTester tester) async {
      const String long =
          'A preview long enough to run past the widest any hover card gets, and then on further.';

      for (final NebaSize size in NebaSize.values) {
        await tester.pumpWidget(
          scene(
            NebaHoverCard(
              defaultOpen: true,
              size: size,
              trigger: mention(),
              child: const Text(long),
            ),
          ),
        );

        expect(tester.getSize(sheet()).width, NebaHoverCard.maxWidths[size], reason: '$size');
      }
    });

    testWidgets('takes a width of its own instead', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            defaultOpen: true,
            width: 200,
            trigger: mention(),
            child: const Text('A preview long enough to run past two hundred pixels.'),
          ),
        ),
      );

      expect(tester.getSize(sheet()).width, 200);
    });

    testWidgets('sits 6 pixels under the trigger, centred on it', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(defaultOpen: true, trigger: mention(), child: const Text('Body'))),
      );

      final Rect trigger = tester.getRect(find.byKey(triggerKey));
      expect(tester.getRect(sheet()).top, trigger.bottom + 6);
      expect(tester.getRect(sheet()).center.dx, moreOrLessEquals(trigger.center.dx));
    });

    testWidgets('draws no wedge by default, and one when asked', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaHoverCard(defaultOpen: true, trigger: mention(), child: const Text('Body'))),
      );
      expect(tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow, isNull);

      await tester.pumpWidget(
        scene(
          NebaHoverCard(
            defaultOpen: true,
            arrow: true,
            size: NebaSize.sm,
            trigger: mention(),
            child: const Text('Body'),
          ),
        ),
      );
      expect(tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow?.size, 9);
    });
  });
}
