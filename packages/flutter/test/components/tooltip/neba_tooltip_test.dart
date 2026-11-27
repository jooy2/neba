// NebaTooltip: the suite the React package runs on Tooltip, asked the way
// Flutter asks it — the plate it draws and where, the semantics it lends the
// trigger, and what the pointer, the keyboard and a finger do — rather than
// the elements and the ARIA it writes.

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

  Widget scene(Widget child, {bool disableAnimations = false}) {
    return host(
      Overlay.wrap(child: Center(child: child)),
      disableAnimations: disableAnimations,
    );
  }

  Widget copy({NebaColor? color, VoidCallback? onPressed}) {
    return NebaButton(
      key: triggerKey,
      onPressed: onPressed ?? () {},
      color: color,
      child: const Text('Copy'),
    );
  }

  Finder plate() => find.descendant(
    of: find.byType(NebaFloating),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is NebaSheet && widget.elevation == 3,
    ),
  );

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
        scene(NebaTooltip(content: const Text('Copy to clipboard'), child: copy())),
      );

      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('renders its content when open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, content: const Text('Copy to clipboard'), child: copy()),
        ),
      );

      expect(find.text('Copy to clipboard'), findsOneWidget);
    });

    testWidgets('adds nothing of its own around the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(scene(copy()));
      final Rect alone = tester.getRect(find.byKey(triggerKey));

      await tester.pumpWidget(
        scene(NebaTooltip(content: const Text('Copy to clipboard'), child: copy())),
      );

      expect(tester.getRect(find.byKey(triggerKey)), alone);
    });

    testWidgets('keeps the trigger a real Neba button that does its own work', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          NebaTooltip(
            content: const Text('Copy to clipboard'),
            child: copy(color: NebaColor.danger, onPressed: () => pressed += 1),
          ),
        ),
      );

      await tester.tap(find.text('Copy'));
      expect(pressed, 1);
      final NebaSheet button = tester.widget<NebaSheet>(
        find.descendant(of: find.byKey(triggerKey), matching: find.byType(NebaSheet)),
      );
      expect(button.fill, tokens.roles(NebaColor.danger).fill);
    });

    testWidgets('reflects changed content on a rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaTooltip(defaultOpen: true, content: const Text('Before'), child: copy())),
      );
      await tester.pumpWidget(
        scene(NebaTooltip(defaultOpen: true, content: const Text('After'), child: copy())),
      );

      expect(find.text('After'), findsOneWidget);
    });
  });

  group('the pointer', () {
    testWidgets('opens when a mouse rests on the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsOneWidget);
    });

    testWidgets('waits 600 milliseconds of rest by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaTooltip(content: const Text('Copy to clipboard'), child: copy())),
      );

      final Offset centre = tester.getCenter(find.byKey(triggerKey));
      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(centre);
      await tester.pump(const Duration(milliseconds: 400));
      // Moving starts the wait again.
      await mouse.moveTo(centre + const Offset(2, 0));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.text('Copy to clipboard'), findsNothing);

      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      await tester.pump();
      expect(find.text('Copy to clipboard'), findsOneWidget);
    });

    testWidgets('closes when the pointer leaves, and not on its way to the label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      final Rect trigger = tester.getRect(find.byKey(triggerKey));
      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(trigger.center);
      await settle(tester);

      // Up through the gap and onto the label.
      await mouse.moveTo(Offset(trigger.center.dx, trigger.top - 3));
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Copy to clipboard')));
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsOneWidget);

      await mouse.moveTo(const Offset(5, 590));
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('stays closeDelay after the pointer has left', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            closeDelay: const Duration(milliseconds: 300),
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);
      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Copy to clipboard'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('closes on a press on the trigger and stays closed until the pointer leaves', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      final Offset centre = tester.getCenter(find.byKey(triggerKey));
      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(centre);
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsOneWidget);

      await mouse.down(centre);
      await mouse.up();
      await settle(tester);
      await mouse.moveTo(centre + const Offset(3, 0));
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsNothing);

      await mouse.moveTo(const Offset(5, 590));
      await tester.pump();
      await mouse.moveTo(centre);
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsOneWidget);
    });

    testWidgets('never opens on a touch', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      await tester.tap(find.byKey(triggerKey));
      await settle(tester);
      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.byKey(triggerKey)),
      );
      await tester.pump(const Duration(seconds: 1));
      await finger.up();
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('does not open when it is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            disabled: true,
            delay: Duration.zero,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(triggerKey)));
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsNothing);
    });
  });

  group('the keyboard', () {
    testWidgets('opens at once on keyboard focus and closes when it leaves', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaTooltip(content: const Text('Copy to clipboard'), child: copy())),
      );

      final FocusNode node = Focus.of(tester.element(find.text('Copy')));
      node.requestFocus();
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsOneWidget);

      node.unfocus();
      await settle(tester);
      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('does not open on a focus a press gave the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaTooltip(content: const Text('Copy to clipboard'), child: copy())),
      );

      await tester.tap(find.text('Copy'));
      Focus.of(tester.element(find.text('Copy'))).requestFocus();
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsNothing);
    });

    testWidgets('closes on Escape', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, content: const Text('Copy to clipboard'), child: copy()),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsNothing);
    });
  });

  group('state', () {
    testWidgets('reports opening to the caller', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaTooltip(
            delay: Duration.zero,
            onOpenChange: changes.add,
            content: const Text('Copy to clipboard'),
            child: copy(),
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
          NebaTooltip(
            open: false,
            onOpenChange: (bool _) {},
            content: const Text('Copy'),
            child: copy(),
          ),
        ),
      );
      expect(find.byType(NebaSheet), findsOneWidget);

      await tester.pumpWidget(
        scene(
          NebaTooltip(
            open: true,
            onOpenChange: (bool _) {},
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsOneWidget);
    });

    testWidgets('stays closed while disabled, even when it is told to open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            open: true,
            disabled: true,
            onOpenChange: (bool _) {},
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Copy to clipboard'), findsNothing);
    });
  });

  group('the plate', () {
    testWidgets('is a filled neutral plate that floats', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, content: const Text('Copy to clipboard'), child: copy()),
        ),
      );

      final NebaColorRoles secondary = tokens.roles(NebaColor.secondary);
      final NebaSheet sheet = tester.widget<NebaSheet>(plate());
      expect(sheet.fill, secondary.fill);
      expect(sheet.plate, NebaPlate.solid);
      expect(sheet.edge, isNull);
      expect(sheet.borderRadius, BorderRadius.circular(tokens.radius[NebaSize.sm]!));

      final TextStyle text = DefaultTextStyle.of(
        tester.element(find.text('Copy to clipboard')),
      ).style;
      expect(text.color, secondary.onSolid);
      expect(text.fontSize, NebaScale.metaText[NebaSize.sm]);
    });

    testWidgets('takes a colour family of its own', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            defaultOpen: true,
            color: NebaColor.danger,
            content: const Text('Cannot be undone'),
            child: copy(),
          ),
        ),
      );

      expect(tester.widget<NebaSheet>(plate()).fill, tokens.roles(NebaColor.danger).fill);
    });

    testWidgets('pads its text on the control ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            defaultOpen: true,
            size: NebaSize.md,
            content: const Text('Copy to clipboard'),
            child: copy(),
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.text('Copy to clipboard')) - tester.getTopLeft(plate()),
        Offset(NebaScale.paddingX[NebaDensity.standard]![NebaSize.md]!, 4),
      );
    });

    testWidgets('wraps past 256 pixels', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(
            defaultOpen: true,
            content: const Text(
              'A tooltip that says far more than a tooltip ever should, and so has to wrap.',
            ),
            child: copy(),
          ),
        ),
      );

      expect(tester.getSize(plate()).width, NebaTooltip.maxWidth);
    });

    testWidgets('sits 6 pixels above the trigger, and flips when there is no room', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, content: const Text('Copy to clipboard'), child: copy()),
        ),
      );
      expect(tester.getRect(plate()).bottom, tester.getRect(find.byKey(triggerKey)).top - 6);

      await tester.pumpWidget(
        host(
          Overlay.wrap(
            child: Align(
              alignment: Alignment.topCenter,
              child: NebaTooltip(
                defaultOpen: true,
                content: const Text('Copy to clipboard'),
                child: copy(),
              ),
            ),
          ),
        ),
      );
      expect(tester.getRect(plate()).top, tester.getRect(find.byKey(triggerKey)).bottom + 6);
    });

    testWidgets('draws the wedge by default, in its own fill, and drops it when asked', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaTooltip(defaultOpen: true, content: const Text('Copy'), child: copy())),
      );
      expect(
        tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow,
        NebaFloatingArrow(size: 7, fill: tokens.roles(NebaColor.secondary).fill),
      );

      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, arrow: false, content: const Text('Copy'), child: copy()),
        ),
      );
      expect(tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow, isNull);
    });
  });

  group('semantics', () {
    testWidgets('describes its trigger with its words, and reads them once', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaTooltip(defaultOpen: true, content: const Text('Copy to clipboard'), child: copy()),
        ),
      );

      expect(
        tester.getSemantics(find.byKey(triggerKey)),
        matchesSemantics(
          label: 'Copy',
          tooltip: 'Copy to clipboard',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Copy to clipboard'), findsNothing);
      semantics.dispose();
    });

    testWidgets('leaves a label that is not a Text to be read where it is drawn', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaTooltip(
            defaultOpen: true,
            content: const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Text('Saved')]),
            child: copy(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Saved'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('NebaTooltipProvider', () {
    Widget row({Duration? delay}) {
      return NebaTooltipProvider(
        delay: delay,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NebaTooltip(
              content: const Text('Bold'),
              child: NebaButton(key: const Key('b'), onPressed: () {}, child: const Text('B')),
            ),
            NebaTooltip(
              content: const Text('Italic'),
              child: NebaButton(key: const Key('i'), onPressed: () {}, child: const Text('I')),
            ),
          ],
        ),
      );
    }

    testWidgets('lends its delay to the tooltips without one', (WidgetTester tester) async {
      await tester.pumpWidget(scene(row(delay: const Duration(milliseconds: 200))));

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      await tester.pump();

      expect(find.text('Bold'), findsOneWidget);
    });

    testWidgets('opens the next one at once and without a fade, until it cools', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(row(delay: const Duration(milliseconds: 200))));

      final TestGesture mouse = await mouseAt(tester, Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
      await tester.pump(const Duration(milliseconds: 250));
      await settle(tester);
      expect(find.text('Bold'), findsOneWidget);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('i'))));
      await tester.pump();
      await tester.pump();
      expect(find.text('Italic'), findsOneWidget);
      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('Italic'), matching: find.byType(FadeTransition)),
      );
      expect(fade.opacity.value, 1);

      // Away, past the timeout, and back: the wait has come back.
      await mouse.moveTo(const Offset(5, 590));
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 500));
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Bold'), findsNothing);
    });
  });
}
