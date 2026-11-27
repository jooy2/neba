// NebaNavigationMenu: the suite the React package runs on NavigationMenu,
// asked the way Flutter asks it — what a screen reader is told about the
// items and the links, where the panel is drawn and how big it is, where the
// focus goes — rather than the elements, the classes and the ARIA it writes.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Widget scene(Widget nav, {Widget? after, TextDirection textDirection = TextDirection.ltr}) {
    return host(
      Overlay.wrap(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[nav, ?after]),
          ),
        ),
      ),
      textDirection: textDirection,
    );
  }

  void go() {}

  Widget nav({
    String? value,
    ValueChanged<String?>? onValueChange,
    NebaSize? size,
    NebaColor color = NebaColor.primary,
    NebaOrientation orientation = NebaOrientation.horizontal,
    VoidCallback? onAnalytics,
  }) {
    return NebaNavigationMenu(
      semanticLabel: 'Main',
      value: value,
      onValueChange: onValueChange,
      size: size,
      color: color,
      orientation: orientation,
      children: <Widget>[
        NebaNavigationMenuItem(
          label: const Text('Product'),
          value: 'product',
          children: <Widget>[
            NebaNavigationMenuLink(
              title: const Text('Analytics'),
              description: const Text('Every number.'),
              href: Uri.parse('/analytics'),
              onPressed: onAnalytics ?? go,
            ),
            NebaNavigationMenuLink(
              title: const Text('Pipelines'),
              href: Uri.parse('/pipelines'),
              onPressed: go,
            ),
          ],
        ),
        NebaNavigationMenuItem(
          label: const Text('Pricing'),
          href: Uri.parse('/pricing'),
          onPressed: go,
        ),
        NebaNavigationMenuItem(
          label: const Text('Docs'),
          value: 'docs',
          disabled: true,
          children: <Widget>[
            NebaNavigationMenuLink(
              title: const Text('Guide'),
              href: Uri.parse('/guide'),
              onPressed: go,
            ),
          ],
        ),
      ],
    );
  }

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

  Finder sheet() => find.descendant(of: find.byType(Overlay), matching: find.byType(NebaSheet));

  FocusNode node(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label)));

  bool focused(WidgetTester tester, String label) => node(tester, label).hasPrimaryFocus;

  group('rendering', () {
    testWidgets('is a navigation of items', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(nav()));

      final SemanticsNode region = tester.getSemantics(
        find
            .descendant(of: find.byType(NebaNavigationMenu), matching: find.byType(Semantics))
            .first,
      );
      expect(region.getSemanticsData().role, SemanticsRole.navigation);
      expect(region.getSemanticsData().label, 'Main');
      expect(
        tester.getSemantics(find.text('Product')),
        matchesSemantics(
          label: 'Product',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasFocusAction: true,
          hasTapAction: true,
          hasExpandedState: true,
        ),
      );
      semantics.dispose();
    });

    // The whole reason this is not a Menu: a destination has to be a link.
    testWidgets('makes an item with an href a link', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(nav()));

      expect(
        tester.getSemantics(find.text('Pricing')),
        matchesSemantics(
          label: 'Pricing',
          isLink: true,
          isFocusable: true,
          hasFocusAction: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Pricing')).getSemanticsData().linkUrl,
        Uri.parse('/pricing'),
      );
      semantics.dispose();
    });

    testWidgets('writes no href a link may not carry', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Run'),
                href: Uri.parse('javascript:alert(1)'),
                onPressed: go,
              ),
            ],
          ),
        ),
      );

      expect(tester.getSemantics(find.text('Run')).getSemanticsData().linkUrl, isNull);
      semantics.dispose();
    });

    testWidgets('says that an item opens in a new tab', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Docs'),
                href: Uri.parse('https://example.com'),
                newTab: true,
                onPressed: go,
              ),
            ],
          ),
        ),
      );

      final SemanticsNode link = tester.getSemantics(find.text('Docs'));
      expect(link.getSemanticsData().label, contains('Docs'));
      expect(link.getSemanticsData().label, contains('(opens in a new tab)'));
      semantics.dispose();
    });

    testWidgets('says that a panel link opens in a new tab', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Product'),
                children: <Widget>[
                  NebaNavigationMenuLink(
                    title: const Text('Status'),
                    href: Uri.parse('https://example.com'),
                    newTab: true,
                    onPressed: go,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Product'));
      await settle(tester);

      final SemanticsNode link = tester.getSemantics(find.text('Status'));
      expect(link, isSemantics(isLink: true));
      expect(link.getSemanticsData().label, endsWith('(opens in a new tab)'));
      semantics.dispose();
    });

    testWidgets('stops being a link while a link item is disabled', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Pricing'),
                href: Uri.parse('/pricing'),
                onPressed: go,
                disabled: true,
              ),
            ],
          ),
        ),
      );

      final SemanticsNode item = tester.getSemantics(find.text('Pricing'));
      expect(
        item,
        isSemantics(
          label: 'Pricing',
          isLink: false,
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: false,
        ),
      );
      expect(item.getSemanticsData().linkUrl, isNull);
      semantics.dispose();
    });

    // The item became a button and the href went nowhere, with nothing on the
    // screen to say so.
    testWidgets('warns, in a debug build, about an item with both an href and a panel', (
      WidgetTester tester,
    ) async {
      final List<String?> printed = <String?>[];
      final DebugPrintCallback previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => printed.add(message);

      try {
        await tester.pumpWidget(
          scene(
            NebaNavigationMenu(
              children: <Widget>[
                NebaNavigationMenuItem(
                  label: const Text('Product'),
                  href: Uri.parse('/product'),
                  children: <Widget>[
                    NebaNavigationMenuLink(title: const Text('Analytics'), onPressed: go),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.pump();
      } finally {
        debugPrint = previous;
      }

      expect(printed, hasLength(1));
      expect(printed.single, contains('href: /product'));
    });

    testWidgets('says nothing about an item that is only a link or only a panel', (
      WidgetTester tester,
    ) async {
      final List<String?> printed = <String?>[];
      final DebugPrintCallback previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => printed.add(message);

      try {
        await tester.pumpWidget(scene(nav()));
      } finally {
        debugPrint = previous;
      }

      expect(printed, isEmpty);
    });

    testWidgets('opens no panel until an item is asked', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav()));

      expect(find.text('Analytics'), findsNothing);
      expect(sheet(), findsNothing);
    });

    testWidgets('lays the panel out in columns of one width', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Regions'),
                columns: 3,
                children: <Widget>[
                  for (final String city in <String>['Seoul', 'Tokyo', 'Osaka', 'Frankfurt'])
                    NebaNavigationMenuLink(title: Text(city), onPressed: go),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Regions'));
      await settle(tester);

      Rect cell(String city) => tester.getRect(
        find.ancestor(of: find.text(city), matching: find.byType(NebaNavigationMenuLink)),
      );

      // Three to a row, the fourth on the next, every one as wide as the
      // widest.
      expect(cell('Tokyo').top, cell('Seoul').top);
      expect(cell('Osaka').top, cell('Seoul').top);
      expect(cell('Frankfurt').top, greaterThan(cell('Seoul').bottom));
      expect(cell('Frankfurt').left, cell('Seoul').left);
      expect(cell('Seoul').width, cell('Frankfurt').width);
      expect(cell('Tokyo').left - cell('Seoul').right, 4);
    });
  });

  group('behaviour', () {
    testWidgets('opens the panel behind an item', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(nav()));
      await tester.tap(find.text('Product'));
      await settle(tester);

      final SemanticsNode link = tester.getSemantics(find.text('Analytics'));
      expect(link, isSemantics(isLink: true));
      expect(link.getSemanticsData().linkUrl, Uri.parse('/analytics'));
      expect(
        tester.getSemantics(find.text('Product')),
        isSemantics(isButton: true, isExpanded: true),
      );
      semantics.dispose();
    });

    testWidgets('runs a link when it is pressed', (WidgetTester tester) async {
      int pressed = 0;

      await tester.pumpWidget(scene(nav(onAnalytics: () => pressed++)));
      await tester.tap(find.text('Product'));
      await settle(tester);
      await tester.tap(find.text('Analytics'));
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('reports which item is open', (WidgetTester tester) async {
      final List<String?> values = <String?>[];

      await tester.pumpWidget(scene(nav(onValueChange: values.add)));
      await tester.tap(find.text('Product'));
      await settle(tester);
      await tester.tap(find.text('Product'));
      await settle(tester);

      expect(values, <String?>['product', null]);
    });

    testWidgets('reports an item without a value by an identity of its own', (
      WidgetTester tester,
    ) async {
      final List<String?> values = <String?>[];

      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            onValueChange: values.add,
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Product'),
                children: <Widget>[
                  NebaNavigationMenuLink(title: const Text('Analytics'), onPressed: go),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Product'));
      await settle(tester);

      expect(values.single, isNotNull);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('honours a controlled value', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav(value: 'product', onValueChange: (String? _) {})));
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);

      // A press asks to close it; the value says it stays.
      await tester.tap(find.text('Product'));
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);

      await tester.pumpWidget(scene(nav(onValueChange: (String? _) {})));
      await settle(tester);

      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('leaves a disabled item unopenable', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(scene(nav()));

      // Still in the focus order, as a disabled Base UI trigger stays.
      expect(
        tester.getSemantics(find.text('Docs')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, isFocusable: true),
      );

      await tester.tap(find.text('Docs'), warnIfMissed: false);
      await settle(tester);

      expect(find.text('Guide'), findsNothing);
      semantics.dispose();
    });

    testWidgets('opens on the pointer resting and closes once it leaves', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(nav()));

      final TestGesture mouse = await mouseAt(tester, const Offset(5, 590));
      await mouse.moveTo(tester.getCenter(find.text('Product')));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Analytics'), findsNothing);

      await tester.pump(const Duration(milliseconds: 60));
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);

      // Across the gap and onto the panel, which keeps it.
      await mouse.moveTo(tester.getCenter(find.text('Analytics')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Analytics'), findsOneWidget);

      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(milliseconds: 60));
      await settle(tester);

      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('crosses the row on one sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaNavigationMenu(
            delay: Duration.zero,
            children: <Widget>[
              NebaNavigationMenuItem(
                label: const Text('Product'),
                children: <Widget>[
                  NebaNavigationMenuLink(title: const Text('Analytics'), onPressed: go),
                ],
              ),
              NebaNavigationMenuItem(
                label: const Text('Developers'),
                children: <Widget>[
                  NebaNavigationMenuLink(title: const Text('Documentation'), onPressed: go),
                  NebaNavigationMenuLink(title: const Text('API reference'), onPressed: go),
                  NebaNavigationMenuLink(title: const Text('Changelog'), onPressed: go),
                ],
              ),
            ],
          ),
        ),
      );

      final TestGesture mouse = await mouseAt(tester, const Offset(5, 590));
      await mouse.moveTo(tester.getCenter(find.text('Product')));
      await settle(tester);

      final Element first = tester.element(sheet());
      final double shorter = tester.getSize(sheet()).height;

      await mouse.moveTo(tester.getCenter(find.text('Developers')));
      await tester.pump();

      // The same sheet, under the next word, easing to the taller panel.
      expect(tester.element(sheet()), same(first));
      expect(find.text('Analytics'), findsNothing);
      expect(find.text('Documentation'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 40));

      final double during = tester.getSize(sheet()).height;
      expect(during, greaterThan(shorter));

      await settle(tester);

      expect(tester.getSize(sheet()).height, greaterThan(during));
      expect(
        tester.getRect(sheet()).center.dx,
        moreOrLessEquals(
          tester.getRect(find.byType(NebaNavigationMenuItem).last).center.dx,
          epsilon: 1,
        ),
      );
    });

    testWidgets('keeps a panel that a press arrives at just after the pointer opened it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(nav()));

      final TestGesture mouse = await mouseAt(tester, const Offset(5, 590));
      await mouse.moveTo(tester.getCenter(find.text('Product')));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.text('Analytics'), findsOneWidget);

      await mouse.down(tester.getCenter(find.text('Product')));
      await mouse.up();
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);

      // And it is held: the pointer leaving no longer closes it.
      await mouse.moveTo(const Offset(5, 590));
      await tester.pump(const Duration(milliseconds: 100));
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('closes on a press outside', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav()));
      await tester.tap(find.text('Product'));
      await settle(tester);

      await tester.tapAt(const Offset(5, 590));
      await settle(tester);

      expect(find.text('Analytics'), findsNothing);
    });
  });

  group('keyboard', () {
    testWidgets('walks the row with the arrows, and stops at its ends', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(nav()));

      node(tester, 'Product').requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(tester, 'Pricing'), isTrue);

      // The disabled word is skipped by the arrows; it is the last one, so
      // the arrow stays where it is.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(tester, 'Pricing'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focused(tester, 'Product'), isTrue);
    });

    testWidgets('opens on the arrow across the row, and Tab goes into the panel and out of it', (
      WidgetTester tester,
    ) async {
      final FocusNode after = FocusNode(debugLabel: 'after');
      addTearDown(after.dispose);

      await tester.pumpWidget(
        scene(
          nav(),
          after: Focus(focusNode: after, child: const SizedBox(width: 20, height: 20)),
        ),
      );

      node(tester, 'Product').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      expect(find.text('Analytics'), findsOneWidget);
      // The focus stays on the word.
      expect(focused(tester, 'Product'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(tester, 'Analytics'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'Pipelines'), isTrue);

      // Round from the end to the start.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focused(tester, 'Analytics'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump();

      // Out of the panel's end to the word after its own, and the panel stays.
      expect(focused(tester, 'Pricing'), isTrue);
      expect(find.text('Analytics'), findsOneWidget);

      // And back into the panel's end.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(tester, 'Pipelines'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(tester, 'Product'), isTrue);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);

      // The focus leaving the navigation closes the panel.
      after.requestFocus();
      await settle(tester);

      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('closes on Escape and gives the focus back to the word', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(nav()));

      node(tester, 'Product').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(tester, 'Analytics'), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(find.text('Analytics'), findsNothing);
      expect(focused(tester, 'Product'), isTrue);
    });
  });

  group('shared props', () {
    testWidgets('sets the size once for every item', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav(size: NebaSize.lg)));

      double height(String label) => tester
          .getSize(find.ancestor(of: find.text(label), matching: find.byType(DecoratedBox)).first)
          .height;

      expect(height('Product'), NebaScale.controlHeight[NebaSize.lg]);
      expect(height('Pricing'), NebaScale.controlHeight[NebaSize.lg]);
    });

    testWidgets('takes the size from the provider', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(
          NebaProvider(
            defaults: const NebaDefaults(size: NebaSize.sm),
            child: nav(),
          ),
        ),
      );

      expect(
        tester
            .getSize(
              find.ancestor(of: find.text('Pricing'), matching: find.byType(DecoratedBox)).first,
            )
            .height,
        NebaScale.controlHeight[NebaSize.sm],
      );
    });

    testWidgets('draws the panel on the frosted sheet with an edge in its colour', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(scene(nav(color: NebaColor.success)));
      await tester.tap(find.text('Product'));
      await settle(tester);

      final NebaSheet drawn = tester.widget<NebaSheet>(sheet());
      expect(drawn.fill, tokens.panelPress);
      expect(drawn.edge, tokens.roles(NebaColor.success).line);
      expect(drawn.elevation, 3);
      expect(drawn.plate, NebaPlate.glass);
    });

    testWidgets('tints the open item in its colour', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav(color: NebaColor.success)));
      await tester.tap(find.text('Product'));
      await settle(tester);

      final DecoratedBox box = tester.widget<DecoratedBox>(
        find.ancestor(of: find.text('Product'), matching: find.byType(DecoratedBox)).first,
      );
      expect((box.decoration as BoxDecoration).color, tokens.roles(NebaColor.success).softHover);
    });

    testWidgets('turns the row on its side when vertical', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav(orientation: NebaOrientation.vertical)));

      final Rect product = tester.getRect(find.byType(NebaNavigationMenuItem).first);
      final Rect pricing = tester.getRect(find.byType(NebaNavigationMenuItem).at(1));

      expect(pricing.top, greaterThan(product.bottom));
      expect(pricing.left, product.left);
      expect(pricing.width, product.width);
    });

    // The panel hung below the item and covered the next one down.
    testWidgets('opens a panel beside a vertical rail', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav(orientation: NebaOrientation.vertical)));
      await tester.tap(find.text('Product'));
      await settle(tester);

      expect(
        tester.getRect(sheet()).left,
        greaterThanOrEqualTo(tester.getRect(find.byType(NebaNavigationMenuItem).first).right),
      );
    });

    testWidgets('opens a vertical rail to the left right to left', (WidgetTester tester) async {
      await tester.pumpWidget(
        scene(nav(orientation: NebaOrientation.vertical), textDirection: TextDirection.rtl),
      );
      await tester.tap(find.text('Product'));
      await settle(tester);

      expect(
        tester.getRect(sheet()).right,
        lessThanOrEqualTo(tester.getRect(find.byType(NebaNavigationMenuItem).first).left),
      );
    });

    testWidgets('hangs the panel 8 pixels under its word', (WidgetTester tester) async {
      await tester.pumpWidget(scene(nav()));
      await tester.tap(find.text('Product'));
      await settle(tester);

      final Rect word = tester.getRect(find.byType(NebaNavigationMenuItem).first);
      expect(tester.getRect(sheet()).top, word.bottom + 8);
    });
  });
}
