// NebaPopover: the suite the React package runs on Popover, asked the way
// Flutter asks it — the sheet it draws and where it puts it, the semantics it
// builds, and what a press, a key and the focus do — rather than the elements
// and the ARIA it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/floating.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/internal/sheet_close.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  const Key triggerKey = Key('trigger');

  /// [popover] in the middle of an 800 × 600 overlay, with [before] and
  /// [after] beside it.
  Widget scene(
    Widget popover, {
    Widget? before,
    Widget? after,
    double width = 800,
    bool disableAnimations = false,
  }) {
    return host(
      Overlay.wrap(
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[?before, popover, ?after]),
        ),
      ),
      width: width,
      disableAnimations: disableAnimations,
    );
  }

  Widget share({VoidCallback? onPressed, NebaColor? color}) {
    return NebaButton(
      key: triggerKey,
      onPressed: onPressed ?? () {},
      color: color,
      child: const Text('Share'),
    );
  }

  Finder sheetFinder() =>
      find.descendant(of: find.byType(NebaFloatingSheet), matching: find.byType(NebaSheet));

  Rect popupRect(WidgetTester tester) => tester.getRect(sheetFinder());

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('rendering', () {
    testWidgets('renders nothing until it is open', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), title: const Text('Share this page'))),
      );

      expect(find.text('Share this page'), findsNothing);
      expect(find.byType(NebaFloatingSheet), findsNothing);
    });

    testWidgets('is a dialog named by its title', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(const NebaPopover(defaultOpen: true, title: Text('Share this page'))),
      );

      final SemanticsData data = tester
          .getSemantics(
            find
                .ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(Semantics))
                .first,
          )
          .getSemanticsData();
      expect(data.role, SemanticsRole.dialog);
      expect(data.label, 'Share this page');
      semantics.dispose();
    });

    testWidgets('takes a name of its own, which names it on the web too', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            semanticLabel: 'Sharing',
            child: Text('Anyone with the link can read it.'),
          ),
        ),
      );

      expect(
        tester.getSemantics(
          find.ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(Semantics)).first,
        ),
        matchesSemantics(label: 'Sharing', namesRoute: true),
      );
      semantics.dispose();
    });

    testWidgets('draws the description under the title, muted', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            title: Text('Share this page'),
            description: Text('Anyone with the link can read.'),
          ),
        ),
      );

      final Rect title = tester.getRect(find.text('Share this page'));
      final Rect description = tester.getRect(find.text('Anyone with the link can read.'));
      expect(description.top, greaterThan(title.bottom));
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Anyone with the link can read.')),
        ).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets('renders the body, and it can be pressed', (WidgetTester tester) async {
      int copied = 0;

      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            title: const Text('Share this page'),
            child: NebaButton(onPressed: () => copied += 1, child: const Text('Copy link')),
          ),
        ),
      );

      await tester.tap(find.text('Copy link'));
      expect(copied, 1);
    });

    testWidgets('reflects changed content on a rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('Before'))));
      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('After'))));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('draws in the overlay, outside a clip around the trigger', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          ClipRect(
            child: SizedBox(
              width: 120,
              height: 40,
              child: NebaPopover(
                defaultOpen: true,
                trigger: share(),
                title: const Text('Share this page'),
              ),
            ),
          ),
        ),
      );

      // Hit-testable where it is drawn, which a clipped child would not be.
      expect(tester.getRect(find.text('Share this page')).top, greaterThan(320));
      expect(find.text('Share this page').hitTestable(), findsOneWidget);
    });

    testWidgets('fails loudly when there is no overlay to draw in', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const Center(child: NebaPopover(defaultOpen: true, title: Text('Lost')))),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('opening and closing', () {
    testWidgets('opens from its trigger, and a second press closes it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), title: const Text('Share this page'))),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);
      expect(find.text('Share this page'), findsOneWidget);

      await tester.tap(find.text('Share'));
      await settle(tester);
      expect(find.text('Share this page'), findsNothing);
    });

    testWidgets('keeps the trigger a real Neba button that does its own work too', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(onPressed: () => pressed += 1, color: NebaColor.danger),
            title: const Text('Share this page'),
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);
      expect(pressed, 1);
      expect(find.text('Share this page'), findsOneWidget);

      final NebaSheet button = tester.widget<NebaSheet>(
        find.descendant(of: find.byKey(triggerKey), matching: find.byType(NebaSheet)),
      );
      expect(button.fill, tokens.roles(NebaColor.danger).fill);
    });

    testWidgets('does not open from a disabled trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(
            trigger: NebaButton(onPressed: null, child: Text('Share')),
            title: Text('Share this page'),
          ),
        ),
      );

      await tester.tap(find.text('Share'), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Share this page'), findsNothing);
    });

    testWidgets('opens from the keyboard on the trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), title: const Text('Share this page'))),
      );

      Focus.of(tester.element(find.text('Share'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(find.text('Share this page'), findsOneWidget);
    });

    testWidgets('reports opening and closing to the caller', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(),
            title: const Text('Share this page'),
            onOpenChange: changes.add,
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(changes, <bool>[true, false]);
    });

    testWidgets('honours a controlled open', (WidgetTester tester) async {
      final List<bool> asked = <bool>[];

      await tester.pumpWidget(
        scene(
          NebaPopover(
            open: false,
            onOpenChange: asked.add,
            trigger: share(),
            title: const Text('Share this page'),
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);
      expect(asked, <bool>[true]);
      expect(find.text('Share this page'), findsNothing);

      await tester.pumpWidget(
        scene(
          NebaPopover(
            open: true,
            onOpenChange: asked.add,
            trigger: share(),
            title: const Text('Share this page'),
          ),
        ),
      );
      await settle(tester);
      expect(find.text('Share this page'), findsOneWidget);
    });

    testWidgets('closes from a NebaPopoverClose', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            title: const Text('Share this page'),
            child: NebaPopoverClose(
              builder: (BuildContext context, VoidCallback close) =>
                  NebaButton(onPressed: close, child: const Text('Done')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Done'));
      await settle(tester);
      expect(find.text('Share this page'), findsNothing);
    });

    testWidgets('closes on Escape and gives the focus back to the trigger', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(),
            title: const Text('Share this page'),
            child: NebaButton(onPressed: () {}, child: const Text('Copy link')),
          ),
        ),
      );

      final FocusNode trigger = Focus.of(tester.element(find.text('Share')));
      trigger.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      // The focus went to the first control inside.
      expect(FocusManager.instance.primaryFocus, Focus.of(tester.element(find.text('Copy link'))));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('Share this page'), findsNothing);
      expect(FocusManager.instance.primaryFocus, trigger);
    });

    testWidgets('closes on a click outside, and not on one inside', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(),
            title: const Text('Share this page'),
            child: const Text('Body'),
          ),
          after: const SizedBox(key: Key('outside'), width: 100, height: 40),
        ),
      );

      await tester.tap(find.text('Share'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      await tester.tap(find.text('Body'), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.text('Share this page'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.text('Share this page'), findsNothing);
    });

    testWidgets('stays open on a drag that starts outside on a touch screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('Pinned'))));

      await tester.dragFrom(const Offset(20, 300), const Offset(0, -120));
      await settle(tester);
      expect(find.text('Pinned'), findsOneWidget);

      await tester.tapAt(const Offset(20, 300));
      await settle(tester);
      expect(find.text('Pinned'), findsNothing);
    });

    testWidgets('closes when the focus leaves it', (WidgetTester tester) async {
      final FocusNode elsewhere = FocusNode();
      addTearDown(elsewhere.dispose);

      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(),
            title: const Text('Share this page'),
            child: NebaButton(onPressed: () {}, child: const Text('Copy link')),
          ),
          after: Focus(focusNode: elsewhere, child: const SizedBox(width: 10, height: 10)),
        ),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);
      elsewhere.requestFocus();
      await settle(tester);

      expect(find.text('Share this page'), findsNothing);
      expect(elsewhere.hasFocus, isTrue);
    });

    testWidgets('stays open on Escape and a click outside when it is not dismissible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            dismissible: false,
            title: const Text('Share this page'),
            child: NebaPopoverClose(
              builder: (BuildContext context, VoidCallback close) =>
                  NebaButton(onPressed: close, child: const Text('Done')),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(20, 20), kind: PointerDeviceKind.mouse);
      await settle(tester);
      expect(find.text('Share this page'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await settle(tester);
      expect(find.text('Share this page'), findsNothing);
    });

    testWidgets('closes only the popover on top on Escape', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            title: const Text('Outer'),
            child: NebaPopover(
              trigger: NebaButton(onPressed: () {}, child: const Text('More')),
              title: const Text('Inner'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'));
      await settle(tester);
      expect(find.text('Inner'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Inner'), findsNothing);
      expect(find.text('Outer'), findsOneWidget);
    });

    testWidgets('counts a press in a popover it opened as inside it', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            side: NebaSide.left,
            title: const Text('Outer'),
            child: NebaPopover(
              side: NebaSide.right,
              trigger: NebaButton(onPressed: () {}, child: const Text('More')),
              child: const Text('Inner body'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'), kind: PointerDeviceKind.mouse);
      await settle(tester);
      await tester.tap(find.text('Inner body'), kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(find.text('Outer'), findsOneWidget);
      expect(find.text('Inner body'), findsOneWidget);
    });

    testWidgets('fades in and out in opacity, and never moves or scales', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), title: const Text('Share this page'))),
      );

      await tester.tap(find.text('Share'));
      // The popup arrives a frame after `open` does.
      await tester.pump();
      await tester.pump();
      final Rect arriving = popupRect(tester);
      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(FadeTransition)),
      );
      expect(fade.opacity.value, 0);

      await tester.pump(const Duration(milliseconds: 80));
      expect(fade.opacity.value, greaterThan(0));
      expect(fade.opacity.value, lessThan(1));
      expect(popupRect(tester), arriving);

      await tester.pump(const Duration(milliseconds: 200));
      expect(fade.opacity.value, 1);
      expect(
        find.ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('lands at once under reduced motion', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(trigger: share(), title: const Text('Share this page')),
          disableAnimations: true,
        ),
      );

      await tester.tap(find.text('Share'));
      await tester.pump();
      await tester.pump();

      final FadeTransition fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.byType(NebaFloatingSheet), matching: find.byType(FadeTransition)),
      );
      expect(fade.opacity.value, 1);
    });
  });

  group('modal', () {
    testWidgets('takes every press on the page behind while it is open', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          const NebaPopover(defaultOpen: true, modal: NebaModal.on, title: Text('Share')),
          before: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
        ),
      );

      await tester.tap(find.text('Behind'), warnIfMissed: false);
      await settle(tester);
      expect(pressed, 0);
      // The press was outside, so it closed the popover.
      expect(find.byType(NebaFloatingSheet), findsNothing);
    });

    testWidgets('closes on a second press on its trigger through the barrier', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), modal: NebaModal.on, title: const Text('Share'))),
      );

      await tester.tap(find.text('Share').first);
      await settle(tester);
      expect(find.byType(NebaFloatingSheet), findsOneWidget);

      await tester.tap(find.text('Share').first);
      await settle(tester);
      expect(find.byType(NebaFloatingSheet), findsNothing);
    });

    testWidgets('leaves the page behind pressable when it only traps the focus', (
      WidgetTester tester,
    ) async {
      int pressed = 0;

      await tester.pumpWidget(
        scene(
          const NebaPopover(defaultOpen: true, modal: NebaModal.trapFocus, title: Text('Share')),
          before: NebaButton(onPressed: () => pressed += 1, child: const Text('Behind')),
        ),
      );

      await tester.tap(find.text('Behind'));
      expect(pressed, 1);
    });

    testWidgets('keeps Tab inside', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaPopover(
            trigger: share(),
            modal: NebaModal.trapFocus,
            showClose: true,
            title: const Text('Share'),
            child: NebaButton(onPressed: () {}, child: const Text('Copy link')),
          ),
        ),
      );

      Focus.of(tester.element(find.text('Share').first)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      final FocusNode first = FocusManager.instance.primaryFocus!;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(FocusManager.instance.primaryFocus, first);
    });
  });

  group('the sheet', () {
    testWidgets('is an undyed panel that floats', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaPopover(defaultOpen: true, title: Text('Share this page'))),
      );

      final NebaSheet sheet = tester.widget<NebaSheet>(sheetFinder());
      expect(sheet.fill, tokens.panelPress);
      expect(sheet.plate, NebaPlate.glass);
      expect(sheet.elevation, 3);
      expect(sheet.borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));
    });

    testWidgets('sends the colour family to the edge', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(defaultOpen: true, color: NebaColor.success, title: Text('Deployed')),
        ),
      );

      expect(tester.widget<NebaSheet>(sheetFinder()).edge, tokens.roles(NebaColor.success).line);
    });

    testWidgets('is as wide as its content', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('Hi'))));

      expect(popupRect(tester).width, lessThan(100));
    });

    testWidgets('caps its width on the size ladder', (WidgetTester tester) async {
      const String long =
          'A sentence long enough to run past the widest any popover gets, and then some more.';

      for (final NebaSize size in NebaSize.values) {
        await tester.pumpWidget(
          scene(NebaPopover(defaultOpen: true, size: size, child: const Text(long))),
        );

        expect(popupRect(tester).width, NebaPopover.maxWidths[size], reason: '$size');
      }
    });

    testWidgets('takes an explicit width instead', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            width: 420,
            child: Text('A sentence long enough to run past the widest any popover gets.'),
          ),
        ),
      );

      expect(popupRect(tester).width, 420);
    });

    testWidgets('pads its content on the size and density ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            size: NebaSize.sm,
            density: NebaDensity.compact,
            child: Text('Body'),
          ),
        ),
      );

      // The hairline takes its pixel, then the padding.
      expect(
        tester.getTopLeft(find.text('Body')) - popupRect(tester).topLeft,
        Offset(1 + NebaBox.padding[NebaDensity.compact]![NebaSize.sm]!, 1 + 8),
      );
    });

    testWidgets('sets its title and body on the sheet ladder', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaPopover(defaultOpen: true, title: Text('Title'), child: Text('Body'))),
      );

      final TextStyle title = DefaultTextStyle.of(tester.element(find.text('Title'))).style;
      final TextStyle body = DefaultTextStyle.of(tester.element(find.text('Body'))).style;
      expect(title.fontSize, NebaScale.sheetTitleText[NebaSize.md]);
      expect(title.fontWeight, FontWeight.w600);
      expect(body.fontSize, NebaScale.sheetBodyText[NebaSize.md]);
      expect(body.color, tokens.fg);
    });

    testWidgets('starts from the body text, not the paragraph its trigger is in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        scene(
          const DefaultTextStyle(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            child: NebaPopover(defaultOpen: true, child: Text('Body')),
          ),
        ),
      );

      final DefaultTextStyle text = DefaultTextStyle.of(tester.element(find.text('Body')));
      expect(text.style.fontWeight, FontWeight.w400);
      expect(text.style.fontStyle, FontStyle.normal);
      expect(text.textAlign, isNot(TextAlign.center));
    });

    testWidgets('takes its defaults from NebaProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaProvider(
            defaults: NebaDefaults(size: NebaSize.xs),
            child: NebaPopover(
              defaultOpen: true,
              child: Text('A sentence long enough to run past the widest any popover gets.'),
            ),
          ),
        ),
      );

      expect(popupRect(tester).width, NebaPopover.maxWidths[NebaSize.xs]);
    });

    testWidgets('draws no wedge by default, and one when asked', (WidgetTester tester) async {
      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('A'))));
      expect(tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow, isNull);

      await tester.pumpWidget(
        scene(const NebaPopover(defaultOpen: true, arrow: true, title: Text('A'))),
      );
      expect(
        tester.widget<NebaFloating>(find.byType(NebaFloating)).arrow,
        NebaFloatingArrow(
          size: 10,
          fill: tokens.panelPress,
          edge: tokens.roles(NebaColor.primary).line,
          border: 1,
        ),
      );
    });
  });

  group('placement', () {
    testWidgets('sits 6 pixels under the trigger, centred on it', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(NebaPopover(defaultOpen: true, trigger: share(), title: const Text('Share'))),
      );

      final Rect trigger = tester.getRect(find.byKey(triggerKey));
      final Rect popup = popupRect(tester);
      expect(popup.top, trigger.bottom + 6);
      expect(popup.center.dx, moreOrLessEquals(trigger.center.dx));
    });

    testWidgets('goes on the side it is given', (WidgetTester tester) async {
      for (final NebaSide side in NebaSide.values) {
        await tester.pumpWidget(
          scene(
            NebaPopover(defaultOpen: true, side: side, trigger: share(), title: const Text('A')),
          ),
        );

        final Rect trigger = tester.getRect(find.byKey(triggerKey));
        final Rect popup = popupRect(tester);
        final double gap = switch (side) {
          NebaSide.top => trigger.top - popup.bottom,
          NebaSide.bottom => popup.top - trigger.bottom,
          NebaSide.left => trigger.left - popup.right,
          NebaSide.right => popup.left - trigger.right,
        };
        expect(gap, 6, reason: '$side');
      }
    });

    testWidgets('flips to the other side when there is no room', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => Align(
                  alignment: Alignment.bottomCenter,
                  child: NebaPopover(
                    defaultOpen: true,
                    trigger: share(),
                    title: const Text('Share'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      expect(popupRect(tester).bottom, tester.getRect(find.byKey(triggerKey)).top - 6);
    });

    testWidgets('follows the trigger when it moves', (WidgetTester tester) async {
      final ScrollController scroll = ScrollController();
      addTearDown(scroll.dispose);

      await tester.pumpWidget(
        host(
          Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => ListView(
                  controller: scroll,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    Center(
                      child: NebaPopover(
                        defaultOpen: true,
                        trigger: share(),
                        title: const Text('Share'),
                      ),
                    ),
                    const SizedBox(height: 1000),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      final double before = popupRect(tester).top;
      scroll.jumpTo(40);
      await tester.pump();

      expect(popupRect(tester).top, before - 40);
      expect(popupRect(tester).top, tester.getRect(find.byKey(triggerKey)).bottom + 6);
    });
  });

  group('the close button', () {
    testWidgets('is not drawn by default', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('A'))));

      expect(find.bySemanticsLabel('Close'), findsNothing);
      semantics.dispose();
    });

    testWidgets('closes the popup when it is', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(const NebaPopover(defaultOpen: true, showClose: true, title: Text('A'))),
      );

      await tester.tap(find.bySemanticsLabel('Close'));
      await settle(tester);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('gets through when the popover is not dismissible', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            dismissible: false,
            showClose: true,
            title: Text('A'),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Close'));
      await settle(tester);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('is there, hidden until focused, on a modal popover that did not ask', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaPopover(
            defaultOpen: true,
            modal: NebaModal.on,
            title: const Text('A'),
            child: NebaButton(onPressed: () {}, child: const Text('Copy link')),
          ),
        ),
      );
      await tester.pump();

      // Last in the popup, so the focus it opens with goes to the body.
      expect(FocusManager.instance.primaryFocus, Focus.of(tester.element(find.text('Copy link'))));

      final Finder close = find.bySemanticsLabel('Close');
      expect(close, findsOneWidget);
      expect(
        tester.getSemantics(close),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: 'Close',
        ),
      );

      // Focused from the keyboard, it is drawn.
      final Finder glyph = find.descendant(
        of: find.byType(NebaSheetClose),
        matching: find.byType(Opacity),
      );
      expect(tester.widget<Opacity>(glyph).opacity, 0);
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
      Focus.of(tester.element(glyph)).requestFocus();
      await tester.pump();
      await tester.pump();
      expect(tester.widget<Opacity>(glyph).opacity, 1);

      await tester.pumpWidget(scene(const NebaPopover(defaultOpen: true, title: Text('A'))));
      expect(find.bySemanticsLabel('Close'), findsNothing);
      semantics.dispose();
    });

    testWidgets('takes a name of its own', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            showClose: true,
            closeLabel: 'Dismiss',
            title: Text('A'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('trigger semantics', () {
    testWidgets('says whether it is expanded', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(NebaPopover(trigger: share(), title: const Text('Share this page'))),
      );

      expect(
        tester.getSemantics(find.byKey(triggerKey)),
        matchesSemantics(
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasExpandedState: true,
          label: 'Share',
        ),
      );

      await tester.tap(find.text('Share'));
      await settle(tester);

      expect(
        tester.getSemantics(find.byKey(triggerKey)),
        matchesSemantics(
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasExpandedState: true,
          isExpanded: true,
          label: 'Share',
        ),
      );
      semantics.dispose();
    });
  });

  group('locale', () {
    tearDown(resetNebaMessages);

    testWidgets('names the × in the language it was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            showClose: true,
            locale: Locale('ko'),
            title: Text('공유'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('닫기'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('takes a word of its own over the locale', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      registerNebaMessages('ko', ko);

      await tester.pumpWidget(
        scene(
          const NebaPopover(
            defaultOpen: true,
            showClose: true,
            locale: Locale('ko'),
            closeLabel: 'Dismiss',
            title: Text('공유'),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      semantics.dispose();
    });
  });
}
