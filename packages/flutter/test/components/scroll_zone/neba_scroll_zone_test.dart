// NebaScrollZone: the suite the React package runs on ScrollZone, asked the
// way Flutter asks it — where the children are laid out, which buttons are
// built and where, how far the strip moves for a press, a hold, the wheel, a
// drag and the keys, and what a screen reader hears.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

void main() {
  /// Six cards 300 wide, so the strip overflows an 800-pixel page.
  List<Widget> cards([int count = 6]) {
    return <Widget>[
      for (int index = 1; index <= count; index += 1)
        SizedBox(key: ValueKey<int>(index), width: 300, height: 40, child: Text('Card $index')),
    ];
  }

  Future<void> pump(
    WidgetTester tester,
    Widget zone, {
    double width = 800,
    TextDirection textDirection = TextDirection.ltr,
    bool disableAnimations = false,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: zone),
        ),
        textDirection: textDirection,
        disableAnimations: disableAnimations,
      ),
    );

    // The strip measures itself after its first frame, as a scroll view
    // reports its extent once it has been laid out.
    if (settle) {
      await tester.pump();
    }
  }

  Finder card(int index) => find.byKey(ValueKey<int>(index));

  /// A drag along [by] that comes to rest before it is let go, so it ends
  /// with no fling.
  Future<void> slowDrag(
    WidgetTester tester,
    Offset from,
    Offset by, {
    PointerDeviceKind kind = PointerDeviceKind.touch,
  }) async {
    final TestGesture gesture = await tester.startGesture(from, kind: kind);

    for (int step = 1; step <= 10; step += 1) {
      await gesture.moveBy(by / 10, timeStamp: Duration(milliseconds: 50 * step));
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up(timeStamp: const Duration(milliseconds: 1000));
  }

  Finder button(String label) {
    return find.byWidgetPredicate((Widget w) => w is NebaButton && w.semanticLabel == label);
  }

  Rect viewport(WidgetTester tester) => tester.getRect(find.byType(SingleChildScrollView));

  FocusNode stripNode(WidgetTester tester) => Focus.of(tester.element(card(1)));

  group('rendering', () {
    testWidgets('builds every child', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards()));

      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 6'), findsOneWidget);
    });

    testWidgets('lays the children out in one line running across', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(buttons: NebaScrollZoneButtons.none, children: cards()));

      // The default gutter is the spacing scale's 2, eight pixels.
      expect(tester.getTopLeft(card(2)) - tester.getTopLeft(card(1)), const Offset(308, 0));
      expect(tester.getTopLeft(card(3)) - tester.getTopLeft(card(2)), const Offset(308, 0));
    });

    testWidgets('takes a second line, filling each column before the next', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(lines: 2, buttons: NebaScrollZoneButtons.none, children: cards()),
      );

      expect(tester.getTopLeft(card(2)) - tester.getTopLeft(card(1)), const Offset(0, 48));
      expect(tester.getTopLeft(card(3)) - tester.getTopLeft(card(1)), const Offset(308, 0));
    });

    testWidgets('stretches a child to its column and its row, as a grid cell does', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(
          lines: 2,
          buttons: NebaScrollZoneButtons.none,
          children: const <Widget>[
            SizedBox(key: ValueKey<int>(1), width: 120, height: 20),
            SizedBox(key: ValueKey<int>(2), width: 80, height: 30),
            SizedBox(key: ValueKey<int>(3), width: 60, height: 50),
          ],
        ),
      );

      expect(tester.getSize(card(1)), const Size(120, 50));
      expect(tester.getSize(card(2)), const Size(120, 30));
      expect(tester.getSize(card(3)), const Size(60, 50));
    });

    testWidgets('turns the layout on its side when it runs down the page', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        SizedBox(
          height: 300,
          child: NebaScrollZone(
            orientation: NebaOrientation.vertical,
            lines: 3,
            buttons: NebaScrollZoneButtons.none,
            children: cards(),
          ),
        ),
        width: 400,
      );

      // Three even columns across the width, the rows filled one by one.
      expect(tester.getSize(card(1)).width, (400 - 2 * 8) / 3);
      expect(tester.getTopLeft(card(2)).dy, tester.getTopLeft(card(1)).dy);
      expect(tester.getTopLeft(card(4)) - tester.getTopLeft(card(1)), const Offset(0, 48));
    });

    testWidgets('writes spacing on the spacing scale', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(spacing: 6, buttons: NebaScrollZoneButtons.none, children: cards()),
      );

      expect(tester.getTopLeft(card(2)).dx - tester.getTopLeft(card(1)).dx, 300 + 24);
    });

    testWidgets('runs from the right under RTL', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(buttons: NebaScrollZoneButtons.none, children: cards()),
        textDirection: TextDirection.rtl,
      );

      expect(tester.getTopRight(card(1)).dx, 800);
      expect(tester.getTopRight(card(1)).dx - tester.getTopRight(card(2)).dx, 308);
    });

    testWidgets('names the scrollable region, in the locale\'s words without a label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaScrollZone(children: cards()));
      expect(find.bySemanticsLabel('Scrollable content'), findsOneWidget);

      await pump(tester, NebaScrollZone(label: 'Categories', children: cards()));
      expect(find.bySemanticsLabel('Categories'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is a focus stop only while there is somewhere to go', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards()));
      expect(stripNode(tester).debugLabel, 'NebaScrollZone');
      expect(stripNode(tester).canRequestFocus, isTrue);

      await pump(tester, NebaScrollZone(children: cards(1)));
      expect(stripNode(tester).canRequestFocus, isFalse);
    });

    testWidgets('reflects a changed set of children on rebuild', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards()));
      await pump(tester, const NebaScrollZone(children: <Widget>[Text('Only')]));

      expect(find.text('Only'), findsOneWidget);
      expect(find.text('Card 1'), findsNothing);
    });

    testWidgets('leaves out a child a NebaShow hides at this width', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(
          buttons: NebaScrollZoneButtons.none,
          children: <Widget>[
            ...cards(2),
            const NebaShow(below: NebaBreakpoint.sm, child: Text('Phones only')),
          ],
        ),
      );

      expect(find.text('Phones only'), findsNothing);
    });

    testWidgets('hands its position to controller and calls onScroll', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);
      final List<double> seen = <double>[];

      await pump(
        tester,
        NebaScrollZone(
          controller: controller,
          onScroll: (ScrollMetrics metrics) => seen.add(metrics.pixels),
          children: cards(),
        ),
      );

      controller.jumpTo(120);
      await tester.pump();

      expect(seen, <double>[120]);
    });
  });

  group('the buttons', () {
    testWidgets('offers only the overlaid one that has somewhere to go', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(buttonPlacement: NebaScrollZoneButtonPlacement.overlay, children: cards()),
      );

      expect(button('Scroll forward'), findsOneWidget);
      expect(button('Scroll back'), findsNothing);
    });

    testWidgets('draws both from the first frame when it is told to', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaScrollZone(buttons: NebaScrollZoneButtons.always, children: cards()),
        settle: false,
      );

      expect(button('Scroll back'), findsOneWidget);
      expect(button('Scroll forward'), findsOneWidget);

      await tester.pump();

      // Disabled rather than gone, and still a focus stop.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Scroll back')),
        matchesSemantics(
          label: 'Scroll back',
          isButton: true,
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Scroll forward')),
        matchesSemantics(
          label: 'Scroll forward',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('keeps an overlaid button that runs out while it has the focus', (
      WidgetTester tester,
    ) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        NebaScrollZone(
          buttonPlacement: NebaScrollZoneButtonPlacement.overlay,
          controller: controller,
          children: cards(),
        ),
      );

      tester.widget<NebaButton>(button('Scroll forward')).focusNode!.requestFocus();
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      expect(button('Scroll forward'), findsOneWidget);
      expect(tester.widget<NebaButton>(button('Scroll forward')).disabled, isTrue);
      expect(
        FocusManager.instance.primaryFocus,
        tester.widget<NebaButton>(button('Scroll forward')).focusNode,
      );

      stripNode(tester).requestFocus();
      await tester.pump();

      expect(button('Scroll forward'), findsNothing);
    });

    testWidgets('draws none at all when it is told to', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(buttons: NebaScrollZoneButtons.none, children: cards()));

      expect(find.byType(NebaButton), findsNothing);
    });

    testWidgets('draws neither while everything fits', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards(1)));

      expect(find.byType(NebaButton), findsNothing);
    });

    testWidgets('names itself in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, NebaScrollZone(locale: const Locale('ko'), children: cards()));

      expect(button('앞으로 스크롤'), findsOneWidget);
    });

    testWidgets('takes names of its own', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(
          buttons: NebaScrollZoneButtons.always,
          previousLabel: 'Earlier',
          nextLabel: 'Later',
          children: cards(),
        ),
      );

      expect(button('Earlier'), findsOneWidget);
      expect(button('Later'), findsOneWidget);
    });

    testWidgets('takes its look from the arguments, then the provider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          NebaProvider(
            defaults: const NebaDefaults(size: NebaSize.lg, variant: NebaVariant.outline),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 800,
                child: NebaScrollZone(color: NebaColor.secondary, children: cards()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final NebaButton forward = tester.widget<NebaButton>(button('Scroll forward'));

      expect(forward.size, NebaSize.lg);
      expect(forward.variant, NebaVariant.outline);
      expect(forward.color, NebaColor.secondary);
      expect(forward.elevation, 1);
      // Round: as wide as it is tall, with corners of half its height.
      expect(tester.getSize(button('Scroll forward')), const Size(40, 40));
    });
  });

  group('where the buttons sit', () {
    testWidgets('puts them beside the strip by default', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards()));

      // A lane either side, each a button and the gap beside it.
      expect(viewport(tester).left, 32 + 8);
      expect(viewport(tester).right, 800 - 32 - 8);
      expect(tester.getRect(button('Scroll forward')).left, viewport(tester).right + 8);
      expect(tester.getRect(button('Scroll back')).right, viewport(tester).left - 8);
    });

    testWidgets('overlays them when it is asked to', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(
          buttonPlacement: NebaScrollZoneButtonPlacement.overlay,
          buttons: NebaScrollZoneButtons.always,
          children: cards(),
        ),
      );

      expect(viewport(tester), const Rect.fromLTWH(0, 0, 800, 40));
      expect(tester.getRect(button('Scroll forward')).right, 800 - 8);
      expect(tester.getRect(button('Scroll back')).left, 8);
      expect(tester.getCenter(button('Scroll forward')).dy, 20);
    });

    // A flex item keeps its own height and overflows a thinner line, so the
    // button stands out of a strip of short chips rather than being squeezed.
    testWidgets('keeps an overlaid button round over a strip thinner than it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(
          buttonPlacement: NebaScrollZoneButtonPlacement.overlay,
          children: <Widget>[
            for (int index = 1; index <= 6; index += 1) const SizedBox(width: 300, height: 20),
          ],
        ),
      );

      expect(tester.getSize(button('Scroll forward')), const Size(32, 32));
      expect(tester.getCenter(button('Scroll forward')).dy, 10);
    });

    testWidgets('disables an inline button with nowhere to go rather than emptying its lane', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(children: cards()));

      expect(tester.widget<NebaButton>(button('Scroll back')).disabled, isTrue);
      expect(tester.widget<NebaButton>(button('Scroll forward')).disabled, isFalse);
      expect(
        tester.widget<Visibility>(
          find.ancestor(of: button('Scroll back'), matching: find.byType(Visibility)),
        ),
        isA<Visibility>().having((Visibility v) => v.visible, 'visible', isTrue),
      );
    });

    testWidgets('runs the strip down the page with the buttons above and below it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        SizedBox(
          height: 240,
          child: NebaScrollZone(
            orientation: NebaOrientation.vertical,
            buttons: NebaScrollZoneButtons.always,
            children: cards(),
          ),
        ),
      );

      expect(viewport(tester).top, 32 + 8);
      expect(viewport(tester).bottom, 240 - 32 - 8);
      expect(tester.getRect(button('Scroll forward')).top, viewport(tester).bottom + 8);
      expect(tester.getCenter(button('Scroll forward')).dx, 400);
    });

    testWidgets('turns the chevron for the way each button goes', (WidgetTester tester) async {
      int turnsOf(String label) {
        return tester
            .widget<RotatedBox>(
              find.descendant(of: button(label), matching: find.byType(RotatedBox)),
            )
            .quarterTurns;
      }

      await pump(tester, NebaScrollZone(buttons: NebaScrollZoneButtons.always, children: cards()));
      expect(turnsOf('Scroll forward'), 3);
      expect(turnsOf('Scroll back'), 1);

      await pump(
        tester,
        NebaScrollZone(buttons: NebaScrollZoneButtons.always, children: cards()),
        textDirection: TextDirection.rtl,
      );
      expect(turnsOf('Scroll forward'), 1);
    });
  });

  // The lanes used to arrive a frame late, so every item of a strip that
  // overflowed moved inward by a lane's width.
  group('before it has measured itself', () {
    bool shown(WidgetTester tester, String label) {
      return tester
          .widget<Visibility>(find.ancestor(of: button(label), matching: find.byType(Visibility)))
          .visible;
    }

    testWidgets('holds both inline lanes open in its first frame, with nothing visible in them', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(children: cards()), settle: false);

      expect(shown(tester, 'Scroll back'), isFalse);
      expect(shown(tester, 'Scroll forward'), isFalse);
      expect(viewport(tester).width, 800 - 2 * (32 + 8));
    });

    testWidgets('shows the buttons in the lanes it already held once the strip overflows', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(children: cards()), settle: false);
      final State scrollable = tester.state(find.byType(Scrollable));

      await tester.pump();

      expect(shown(tester, 'Scroll forward'), isTrue);
      expect(viewport(tester).width, 800 - 2 * (32 + 8));
      // The same scroll view, kept rather than built again.
      expect(tester.state(find.byType(Scrollable)), same(scrollable));
    });

    testWidgets('gives the lanes back when the strip fits', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards(1)));

      expect(find.byType(NebaButton), findsNothing);
      expect(viewport(tester).width, 800);
    });

    // The first measurement is taken with the lanes in place, and a strip that
    // fits the zone but not the room between two lanes was kept as a scroller.
    testWidgets('draws no buttons for a strip that fits only without them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScrollZone(children: <Widget>[SizedBox(width: 380, height: 40)]),
        width: 400,
      );

      expect(find.byType(NebaButton), findsNothing);
    });

    testWidgets('keeps them for a strip wider than the zone', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScrollZone(children: <Widget>[SizedBox(width: 600, height: 40)]),
        width: 400,
      );

      expect(tester.widget<NebaButton>(button('Scroll forward')).disabled, isFalse);
    });
  });

  group('pressing one', () {
    late ScrollController controller;

    setUp(() => controller = ScrollController());
    tearDown(() => controller.dispose());

    testWidgets('moves to the next child along, and back', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(controller: controller, children: cards()));

      await tester.tap(button('Scroll forward'));
      await tester.pumpAndSettle();
      // Where the second card starts, measured rather than assumed.
      expect(controller.offset, 308);

      await tester.tap(button('Scroll back'));
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
    });

    testWidgets('moves by more than one when it is asked to', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(step: 2, controller: controller, children: cards()));

      await tester.tap(button('Scroll forward'));
      await tester.pumpAndSettle();

      expect(controller.offset, 616);
    });

    testWidgets('goes as far as there is when no child is that far along', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(controller: controller, children: cards()));

      controller.jumpTo(controller.position.maxScrollExtent - 100);
      await tester.pump();
      await tester.tap(button('Scroll forward'));
      await tester.pumpAndSettle();

      expect(controller.offset, controller.position.maxScrollExtent);
    });

    testWidgets('moves by everything on screen in page mode', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(mode: NebaScrollZoneMode.page, controller: controller, children: cards()),
      );

      await tester.tap(button('Scroll forward'));
      await tester.pumpAndSettle();

      expect(controller.offset, viewport(tester).width);
    });

    testWidgets('cuts to the child for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(controller: controller, children: cards()),
        disableAnimations: true,
      );

      await tester.tap(button('Scroll forward'));
      await tester.pump();

      expect(controller.offset, 308);
    });

    testWidgets('still moves on a tap in hold mode, rather than doing nothing', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScrollZone(mode: NebaScrollZoneMode.hold, controller: controller, children: cards()),
      );

      await tester.tap(button('Scroll forward'));
      await tester.pumpAndSettle();

      expect(controller.offset, 308);
    });

    testWidgets('scrolls at speed for as long as it is held', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(
          mode: NebaScrollZoneMode.hold,
          speed: 600,
          controller: controller,
          children: cards(),
        ),
      );

      final TestGesture press = await tester.startGesture(
        tester.getCenter(button('Scroll forward')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.offset, closeTo(300, 1));

      await press.up();
      await tester.pumpAndSettle();

      // Let go after a hold, it stays where it was let go.
      expect(controller.offset, closeTo(300, 1));
    });

    testWidgets('holds from the keyboard too', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(mode: NebaScrollZoneMode.hold, controller: controller, children: cards()),
      );

      tester.widget<NebaButton>(button('Scroll forward')).focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(controller.offset, closeTo(360, 1));
    });

    testWidgets('stops a hold when the zone goes away mid-press', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(mode: NebaScrollZoneMode.hold, controller: controller, children: cards()),
      );

      final TestGesture press = await tester.startGesture(
        tester.getCenter(button('Scroll forward')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      await press.up();

      expect(tester.takeException(), isNull);
    });
  });

  group('the wheel', () {
    late ScrollController page;
    late ScrollController strip;

    setUp(() {
      page = ScrollController();
      strip = ScrollController();
    });
    tearDown(() {
      page.dispose();
      strip.dispose();
    });

    /// [zone] on a page that scrolls down.
    Future<void> onPage(WidgetTester tester, Widget zone) async {
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            controller: page,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 200),
                SizedBox(width: 800, child: zone),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Future<void> roll(WidgetTester tester, Offset delta) async {
      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
      final Offset at = tester.getCenter(find.byType(NebaScrollZone).first);

      await tester.sendEventToBinding(mouse.hover(at));
      await tester.sendEventToBinding(mouse.scroll(delta));
      await tester.pumpAndSettle();
    }

    testWidgets('leaves it to the page unless it is asked for it', (WidgetTester tester) async {
      await onPage(tester, NebaScrollZone(controller: strip, children: cards()));
      await roll(tester, const Offset(0, 120));

      expect(strip.offset, 0);
      expect(page.offset, 120);
    });

    testWidgets('turns a wheel rolled down the page into travel along the strip', (
      WidgetTester tester,
    ) async {
      await onPage(tester, NebaScrollZone(wheel: true, controller: strip, children: cards()));
      await roll(tester, const Offset(0, 120));

      expect(strip.offset, 120);
      expect(page.offset, 0);
    });

    // The strip is at its start, so there is nothing behind it — and the page
    // still does not get the wheel, because the pointer is over the strip.
    testWidgets('holds the wheel at the end of the strip', (WidgetTester tester) async {
      await onPage(tester, NebaScrollZone(wheel: true, controller: strip, children: cards()));
      page.jumpTo(100);
      await tester.pump();
      await roll(tester, const Offset(0, -120));

      expect(strip.offset, 0);
      expect(page.offset, 100);
    });

    testWidgets('holds nothing on a strip that fits', (WidgetTester tester) async {
      await onPage(tester, NebaScrollZone(wheel: true, controller: strip, children: cards(1)));
      await roll(tester, const Offset(0, 120));

      expect(page.offset, 120);
    });

    testWidgets('leaves a sideways swipe to the strip, which already scrolls with it', (
      WidgetTester tester,
    ) async {
      await onPage(tester, NebaScrollZone(wheel: true, controller: strip, children: cards()));
      await roll(tester, const Offset(120, 4));

      // Moved once, by the strip's own scroll view, and not again here.
      expect(strip.offset, 120);
      expect(page.offset, 0);
    });

    testWidgets('leaves a notch a strip nearer the pointer has already answered', (
      WidgetTester tester,
    ) async {
      final ScrollController inner = ScrollController();
      addTearDown(inner.dispose);

      await onPage(
        tester,
        NebaScrollZone(
          wheel: true,
          buttons: NebaScrollZoneButtons.none,
          controller: strip,
          children: <Widget>[
            SizedBox(
              width: 400,
              child: NebaScrollZone(
                wheel: true,
                buttons: NebaScrollZoneButtons.none,
                controller: inner,
                children: cards(),
              ),
            ),
            ...cards(),
          ],
        ),
      );

      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(tester.getCenter(find.text('Card 1').first)));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
      await tester.pumpAndSettle();

      expect(inner.offset, 120);
      expect(strip.offset, 0);
    });

    testWidgets('ignores the prop on a strip that already runs the way the wheel points', (
      WidgetTester tester,
    ) async {
      await onPage(
        tester,
        SizedBox(
          height: 200,
          child: NebaScrollZone(
            orientation: NebaOrientation.vertical,
            wheel: true,
            controller: strip,
            children: cards(),
          ),
        ),
      );
      await roll(tester, const Offset(0, 60));

      expect(strip.offset, 60);
      expect(page.offset, 0);
    });

    // The page behind does not take over when a strip that scrolls with the
    // wheel runs out under it.
    testWidgets('keeps the wheel of a vertical strip at its end', (WidgetTester tester) async {
      await onPage(
        tester,
        SizedBox(
          height: 200,
          child: NebaScrollZone(
            orientation: NebaOrientation.vertical,
            controller: strip,
            children: cards(),
          ),
        ),
      );
      strip.jumpTo(strip.position.maxScrollExtent);
      await tester.pump();
      await roll(tester, const Offset(0, 120));

      expect(page.offset, 0);
    });
  });

  group('dragging', () {
    late ScrollController controller;

    setUp(() => controller = ScrollController());
    tearDown(() => controller.dispose());

    testWidgets('lets a mouse drag the strip along', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(controller: controller, children: cards()));

      await slowDrag(
        tester,
        tester.getCenter(card(2)),
        const Offset(-200, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();

      expect(controller.offset, closeTo(200, 1));
    });

    testWidgets('leaves a mouse alone without drag, and a finger still scrolls', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(drag: false, controller: controller, children: cards()));

      await slowDrag(
        tester,
        tester.getCenter(card(2)),
        const Offset(-200, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(controller.offset, 0);

      await slowDrag(tester, tester.getCenter(card(2)), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(100));
    });

    // The release that ends a drag would otherwise land as a press on
    // whatever card the strip stopped under.
    testWidgets('does not press the child a drag ends over', (WidgetTester tester) async {
      int pressed = 0;

      await pump(
        tester,
        NebaScrollZone(
          controller: controller,
          children: <Widget>[
            for (int index = 1; index <= 6; index += 1)
              GestureDetector(
                key: ValueKey<int>(index),
                behavior: HitTestBehavior.opaque,
                onTap: () => pressed += 1,
                child: const SizedBox(width: 300, height: 40),
              ),
          ],
        ),
      );

      await slowDrag(
        tester,
        tester.getCenter(card(2)),
        const Offset(-200, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(pressed, 0);

      await tester.tap(card(2), kind: PointerDeviceKind.mouse);
      expect(pressed, 1);
    });

    testWidgets('shows a grab cursor over a strip that can move', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(children: cards()));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(card(1)));
      addTearDown(mouse.removePointer);
      await tester.pump();

      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.grab,
      );
    });
  });

  group('snap', () {
    late ScrollController controller;

    setUp(() => controller = ScrollController());
    tearDown(() => controller.dispose());

    testWidgets('settles a drag on the nearest child', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(snap: true, controller: controller, children: cards()));

      await slowDrag(tester, tester.getCenter(card(2)), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(controller.offset, 308);

      await slowDrag(tester, tester.getCenter(card(2)), const Offset(-80, 0));
      await tester.pumpAndSettle();
      expect(controller.offset, 308);
    });

    // A notch shorter than half a card would otherwise always fall back.
    testWidgets('goes on to the next child after a notch of the wheel', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScrollZone(snap: true, controller: controller, children: cards()));

      final TestPointer mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(tester.getCenter(card(1))));
      await tester.sendEventToBinding(mouse.scroll(const Offset(60, 0)));
      await tester.pumpAndSettle();

      expect(controller.offset, 308);
    });

    testWidgets('goes on to the next child after an arrow key', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(snap: true, controller: controller, children: cards()));

      stripNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(controller.offset, 308);
    });
  });

  group('the keyboard', () {
    late ScrollController controller;

    setUp(() => controller = ScrollController());
    tearDown(() {
      controller.dispose();
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
    });

    testWidgets('scrolls the strip with the arrows along it', (WidgetTester tester) async {
      await pump(tester, NebaScrollZone(controller: controller, children: cards()));

      stripNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(controller.offset, 40);

      // An arrow across a horizontal strip is the page's.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.offset, 40);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(controller.offset, controller.position.maxScrollExtent);
    });

    testWidgets('follows the reading direction under RTL', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScrollZone(controller: controller, children: cards()),
        textDirection: TextDirection.rtl,
      );

      stripNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(controller.offset, 40);
    });

    testWidgets('tabs through the strip in the order the widgets are in', (
      WidgetTester tester,
    ) async {
      final List<FocusNode> nodes = <FocusNode>[
        for (int index = 0; index < 6; index += 1) FocusNode(debugLabel: 'card $index'),
      ];
      addTearDown(() {
        for (final FocusNode node in nodes) {
          node.dispose();
        }
      });

      await pump(
        tester,
        NebaScrollZone(
          controller: controller,
          children: <Widget>[
            for (int index = 0; index < 6; index += 1)
              Focus(
                focusNode: nodes[index],
                child: SizedBox(key: ValueKey<int>(index + 1), width: 300, height: 40),
              ),
          ],
        ),
      );

      final FocusNode back = tester.widget<NebaButton>(button('Scroll back')).focusNode!;
      final FocusNode forward = tester.widget<NebaButton>(button('Scroll forward')).focusNode!;

      back.requestFocus();
      await tester.pump();

      final List<FocusNode?> order = <FocusNode?>[];
      for (int step = 0; step < 8; step += 1) {
        FocusManager.instance.primaryFocus!.nextFocus();
        await tester.pump();
        order.add(FocusManager.instance.primaryFocus);
      }

      final FocusNode strip = FocusManager.instance.rootScope.descendants.firstWhere(
        (FocusNode node) => node.debugLabel == 'NebaScrollZone',
      );

      expect(order, <FocusNode?>[strip, ...nodes, forward]);
    });

    // The ring stands outside a child, and a child brought only as far as the
    // strip's edge would have it cut off there.
    testWidgets('brings a child the keyboard focuses clear of the edge', (
      WidgetTester tester,
    ) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      final FocusNode fourth = FocusNode();
      addTearDown(fourth.dispose);

      await pump(
        tester,
        NebaScrollZone(
          controller: controller,
          buttons: NebaScrollZoneButtons.none,
          children: <Widget>[
            for (int index = 0; index < 6; index += 1)
              if (index == 3)
                Focus(focusNode: fourth, child: const SizedBox(width: 300, height: 40))
              else
                const SizedBox(width: 300, height: 40),
          ],
        ),
      );

      fourth.requestFocus();
      await tester.pump();

      // The fourth card ends at 1224, four pixels short of the edge.
      expect(controller.offset, 1224 - 800 + 4);
    });
  });
}
