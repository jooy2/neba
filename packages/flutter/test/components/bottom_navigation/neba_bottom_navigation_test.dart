// NebaBottomNavigation: the suite the React package runs on BottomNavigation,
// asked the way Flutter asks it — the navigation region and the buttons and
// links a screen reader hears, the destination it keeps, the sheet and the
// hairlines it draws for each position, the insets it keeps clear of and the
// names it draws or only says — rather than the classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<NebaBottomNavigationItem<String>> two = <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: 'home', icon: SizedBox.square(), child: Text('Home')),
    NebaBottomNavigationItem<String>(
      value: 'search',
      icon: SizedBox.square(),
      child: Text('Search'),
    ),
  ];

  /// Two destinations with names and no glyphs, shorter than any bar's floor.
  const List<NebaBottomNavigationItem<String>> words = <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: 'home', child: Text('Home')),
    NebaBottomNavigationItem<String>(value: 'search', child: Text('Search')),
  ];

  /// [bar] at the bottom of an 800 by 600 window whose insets are [padding].
  Future<void> pump(WidgetTester tester, Widget bar, {EdgeInsets padding = EdgeInsets.zero}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: const Size(800, 600), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(alignment: Alignment.bottomCenter, child: bar),
        ),
      ),
    );
  }

  Finder item(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(NebaBottomNavigationItem<String>),
    );
  }

  Rect barOf(WidgetTester tester) => tester.getRect(find.byType(NebaBottomNavigation<String>));

  /// The sheet the bar is drawn on.
  NebaSheet sheetOf(WidgetTester tester) => tester.widget<NebaSheet>(find.byType(NebaSheet));

  /// The hairline along the top, drawn apart from the sheet's own edge.
  Iterable<Border> topLines(WidgetTester tester) {
    return tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(NebaBottomNavigation<String>),
            matching: find.byType(Container),
          ),
        )
        .map((Container container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((BoxDecoration decoration) => decoration.border)
        .whereType<Border>();
  }

  Color? inkOf(WidgetTester tester, String label) {
    return DefaultTextStyle.of(tester.element(find.text(label))).style.color;
  }

  double opacityOf(WidgetTester tester, String label) {
    final Iterable<Opacity> layers = tester.widgetList<Opacity>(
      find.ancestor(of: find.text(label), matching: find.byType(Opacity)),
    );

    return layers.fold<double>(1, (double a, Opacity layer) => a * layer.opacity);
  }

  group('rendering', () {
    testWidgets('is a navigation region named by its label, with a button per destination', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaBottomNavigation<String>(label: 'Main', children: two));

      final SemanticsNode bar = tester.getSemantics(find.byType(NebaBottomNavigation<String>));
      expect(bar.label, 'Main');
      expect(bar.getSemanticsData().role, SemanticsRole.navigation);

      expect(
        tester.getSemantics(item('Search')),
        matchesSemantics(
          label: 'Search',
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

    testWidgets('is a link with its address when it has an href', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaBottomNavigation<String>(
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'home',
              href: Uri.parse('/home'),
              child: const Text('Home'),
            ),
          ],
        ),
      );

      expect(
        tester.getSemantics(item('Home')),
        matchesSemantics(
          label: 'Home',
          isLink: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(tester.getSemantics(item('Home')).getSemanticsData().linkUrl, Uri.parse('/home'));
      semantics.dispose();
    });

    testWidgets('writes no address it should not hand on', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaBottomNavigation<String>(
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'home',
              href: Uri.parse('javascript:alert(1)'),
              child: const Text('Home'),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(item('Home')).getSemanticsData().linkUrl, isNull);
      semantics.dispose();
    });

    testWidgets('says that a destination leaving the app opens in a new tab', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaBottomNavigation<String>(
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'docs',
              href: Uri.parse('https://example.com'),
              newTab: true,
              child: const Text('Docs'),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(item('Docs')).label, 'Docs (opens in a new tab)');
      semantics.dispose();
    });

    testWidgets('reflects a changed name on rebuild', (WidgetTester tester) async {
      Widget bar(String name) {
        return NebaBottomNavigation<String>(
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(value: 'home', child: Text(name)),
          ],
        );
      }

      await pump(tester, bar('Before'));
      await pump(tester, bar('After'));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('shares the width between its destinations', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(children: two));

      expect(barOf(tester).width, 800);
      expect(tester.getSize(item('Home')).width, tester.getSize(item('Search')).width);
      expect(tester.getRect(item('Home')).right, tester.getRect(item('Search')).left);
    });

    testWidgets('stands on a floor of 56 pixels at md, and follows the ladder', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBottomNavigation<String>(divider: false, children: words));
      expect(barOf(tester).height, 56);

      await pump(
        tester,
        const NebaBottomNavigation<String>(divider: false, size: NebaSize.xl, children: words),
      );
      expect(barOf(tester).height, 72);
    });

    testWidgets('grows past the floor for a glyph with a name under it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBottomNavigation<String>(divider: false, children: two));

      // The row's 6 and the item's 6 each way, a 20-pixel glyph, a 4-pixel
      // gap and a 15-pixel line: what the stylesheet comes to as well.
      expect(barOf(tester).height, 6 + 6 + 20 + 4 + 15 + 6 + 6);
    });

    testWidgets('fails with a message outside a bar', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigationItem<String>(value: 'home', child: Text('H')));

      expect(tester.takeException(), isFlutterError);
    });
  });

  group('position', () {
    testWidgets('is square against the edge by default, with only the top hairline', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBottomNavigation<String>(children: two));

      expect(sheetOf(tester).borderRadius, BorderRadius.zero);
      expect(sheetOf(tester).edge, isNull);
      expect(topLines(tester).single.top.color, primary.line);
      expect(topLines(tester).single.bottom, BorderSide.none);
    });

    testWidgets('is a sheet with corners and a hairline all round in the flow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBottomNavigation<String>(position: NebaPosition.static, children: two),
      );

      expect(sheetOf(tester).borderRadius, BorderRadius.circular(tokens.radius[NebaSize.md]!));
      expect(sheetOf(tester).edge, primary.line);
      // The edge already draws the top; a second line would be two pixels.
      expect(topLines(tester), isEmpty);
    });

    testWidgets('draws the top hairline alone on a solid sheet in the flow', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBottomNavigation<String>(
          position: NebaPosition.static,
          variant: NebaVariant.solid,
          children: two,
        ),
      );

      expect(sheetOf(tester).edge, isNull);
      expect(sheetOf(tester).fill, tokens.panelHover);
      expect(topLines(tester), hasLength(1));
    });

    testWidgets('draws no line when the divider is off', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(divider: false, children: two));

      expect(topLines(tester), isEmpty);
    });

    testWidgets('draws no sheet at all as text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBottomNavigation<String>(variant: NebaVariant.text, children: two),
      );

      expect(find.byType(NebaSheet), findsNothing);
    });

    testWidgets('keeps the destinations clear of the insets, with the sheet under them', (
      WidgetTester tester,
    ) async {
      const EdgeInsets padding = EdgeInsets.fromLTRB(11, 47, 13, 34);

      await pump(tester, const NebaBottomNavigation<String>(children: two), padding: padding);

      expect(barOf(tester).bottom, 600);
      expect(barOf(tester).left, 0);
      expect(600 - tester.getRect(item('Home')).bottom, greaterThanOrEqualTo(34));
      expect(tester.getRect(item('Home')).left, greaterThanOrEqualTo(11));
      expect(tester.getRect(item('Search')).right, lessThanOrEqualTo(800 - 13));
    });

    testWidgets('takes no insets when told not to, or in the flow', (WidgetTester tester) async {
      const EdgeInsets padding = EdgeInsets.fromLTRB(11, 47, 13, 34);

      await pump(
        tester,
        const NebaBottomNavigation<String>(safeArea: false, divider: false, children: words),
        padding: padding,
      );
      expect(barOf(tester).height, 56);

      await pump(
        tester,
        const NebaBottomNavigation<String>(
          position: NebaPosition.static,
          divider: false,
          variant: NebaVariant.solid,
          children: words,
        ),
        padding: padding,
      );
      expect(barOf(tester).height, 56);
    });
  });

  group('choosing a destination', () {
    testWidgets('marks the current one, and no other', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaBottomNavigation<String>(value: 'search', children: two));

      expect(
        tester.getSemantics(item('Search')),
        matchesSemantics(
          label: 'Search',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      // Not "not selected" either: a destination that is not current says
      // nothing about it, as one without `aria-current` does.
      expect(
        tester.getSemantics(item('Home')),
        matchesSemantics(
          label: 'Home',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(inkOf(tester, 'Search'), primary.onTint);
      expect(inkOf(tester, 'Home'), tokens.mutedFg);
      semantics.dispose();
    });

    testWidgets('fills the current destination with the family', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(value: 'search', children: two));

      BoxDecoration fillOf(String label) {
        return tester
                .widget<DecoratedBox>(
                  find.descendant(of: item(label), matching: find.byType(DecoratedBox)).first,
                )
                .decoration
            as BoxDecoration;
      }

      expect(fillOf('Search').color, primary.soft);
      expect(fillOf('Home').color, edgeless);
    });

    testWidgets('reports the destination that was pressed', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(tester, NebaBottomNavigation<String>(onValueChange: changes.add, children: two));
      await tester.tap(find.text('Search'));

      expect(changes, <String>['search']);
    });

    testWidgets('calls the destination\'s own handler after the bar\'s', (
      WidgetTester tester,
    ) async {
      final List<String> calls = <String>[];

      await pump(
        tester,
        NebaBottomNavigation<String>(
          onValueChange: (String value) => calls.add('bar $value'),
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'home',
              onPressed: () => calls.add('item'),
              child: const Text('Home'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Home'));

      expect(calls, <String>['bar home', 'item']);
    });

    testWidgets('keeps the choice in an uncontrolled bar', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(defaultValue: 'home', children: two));
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(inkOf(tester, 'Search'), primary.onTint);
      expect(inkOf(tester, 'Home'), tokens.mutedFg);
    });

    testWidgets('leaves a controlled bar where it was put', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaBottomNavigation<String>(value: 'home', onValueChange: changes.add, children: two),
      );
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(changes, <String>['search']);
      expect(inkOf(tester, 'Home'), primary.onTint);
    });

    testWidgets('stops every destination answering when the bar is disabled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaBottomNavigation<String>(disabled: true, onValueChange: changes.add, children: two),
      );
      await tester.tap(find.text('Home'));

      expect(changes, isEmpty);
      expect(
        tester.getSemantics(item('Home')),
        matchesSemantics(label: 'Home', isButton: true, hasEnabledState: true),
      );
      expect(inkOf(tester, 'Home'), tokens.disabledFg);
      semantics.dispose();
    });

    testWidgets('disables one destination on its own', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaBottomNavigation<String>(
          onValueChange: changes.add,
          children: const <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(value: 'home', child: Text('Home')),
            NebaBottomNavigationItem<String>(
              value: 'search',
              disabled: true,
              child: Text('Search'),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Search'));
      await tester.tap(find.text('Home'));

      expect(changes, <String>['home']);
    });

    testWidgets('is a stop of its own in the focus order, destination by destination', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaBottomNavigation<String>(value: 'home', children: two));

      expect(Focus.of(tester.element(find.text('Home'))).canRequestFocus, isTrue);
      expect(Focus.of(tester.element(find.text('Search'))).skipTraversal, isFalse);
    });

    testWidgets('lights a destination under the pointer', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(value: 'home', children: two));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Search')));
      await tester.pumpAndSettle();

      expect(inkOf(tester, 'Search'), tokens.fg);
      await mouse.removePointer();
    });
  });

  group('labels', () {
    testWidgets('draws every name by default', (WidgetTester tester) async {
      await pump(tester, const NebaBottomNavigation<String>(value: 'home', children: two));

      expect(opacityOf(tester, 'Search'), 1);
    });

    testWidgets('draws no name with none, and still says each one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBottomNavigation<String>(
          value: 'home',
          labels: NebaBottomNavigationLabels.none,
          children: two,
        ),
      );

      expect(find.text('Search'), findsNothing);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('draws only the current one with selected, keeping every line', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBottomNavigation<String>(
          value: 'home',
          labels: NebaBottomNavigationLabels.selected,
          children: two,
        ),
      );

      expect(opacityOf(tester, 'Home'), 1);
      expect(opacityOf(tester, 'Search'), 0);
      // Laid out, so the glyph above it stays where it was.
      expect(tester.getSize(find.text('Search')).height, greaterThan(0));
      expect(tester.getSize(item('Search')).height, tester.getSize(item('Home')).height);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('lets a semantic label name a destination drawn as something else', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaBottomNavigation<String>(
          labels: NebaBottomNavigationLabels.none,
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'home',
              semanticLabel: 'Home',
              icon: SizedBox.square(dimension: 4),
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      semantics.dispose();
    });
  });
}
