// NebaFloatingBottomNavigation: the suite the React package runs on
// FloatingBottomNavigation, asked the way Flutter asks it — the navigation
// region and the destinations a screen reader hears, where the stadium floats
// and how far above the edge, the tile laid out behind the current
// destination as it slides and lands, and the names that narrow and widen on
// the same clock without the bar changing height — rather than the classes and
// the custom properties it writes.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<NebaBottomNavigationItem<String>> two = <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(
      value: 'home',
      icon: SizedBox.square(dimension: 20),
      child: Text('Home'),
    ),
    NebaBottomNavigationItem<String>(
      value: 'search',
      icon: SizedBox.square(dimension: 20),
      child: Text('Search'),
    ),
  ];

  /// [bar] over an 800 by 600 region whose insets are [padding], as a floating
  /// bar is meant to be put: in a `Stack` over what it floats over.
  Future<void> pump(
    WidgetTester tester,
    Widget bar, {
    EdgeInsets padding = EdgeInsets.zero,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(800, 600),
          padding: padding,
          disableAnimations: disableAnimations,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: SizedBox(key: Key('page'))),
              bar,
            ],
          ),
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

  /// The stadium itself, without the space it floats in.
  Rect sheetRect(WidgetTester tester) {
    return tester.getRect(
      find
          .descendant(
            of: find.byType(NebaFloatingBottomNavigation<String>),
            matching: find.byType(NebaSheet),
          )
          .first,
    );
  }

  /// The tile: the one sheet inside the run.
  Finder tile() {
    return find.descendant(of: find.byType(NebaTileRun), matching: find.byType(NebaSheet)).first;
  }

  Rect tileRect(WidgetTester tester) => tester.getRect(tile());

  double opacityOf(WidgetTester tester, String label) {
    return tester
        .widgetList<Opacity>(find.ancestor(of: find.text(label), matching: find.byType(Opacity)))
        .fold<double>(1, (double a, Opacity layer) => a * layer.opacity);
  }

  group('rendering', () {
    testWidgets('is a navigation region named by its label, with a button per destination', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaFloatingBottomNavigation<String>(label: 'Main', children: two));

      // The region is the sheet, inside the space the bar floats in.
      final SemanticsNode bar = tester.getSemantics(find.bySemanticsLabel('Main'));
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

    testWidgets('takes the same item a full-width bar takes, with an href and all', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaFloatingBottomNavigation<String>(
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(
              value: 'home',
              href: Uri.parse('/home'),
              child: const Text('Home'),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(item('Home')).getSemanticsData().linkUrl, Uri.parse('/home'));
      semantics.dispose();
    });

    testWidgets('floats 16 pixels above the bottom, centred, as wide as its destinations', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(children: two));

      final Rect sheet = sheetRect(tester);
      expect(sheet.bottom, 600 - 16);
      expect(sheet.center.dx, 400);
      expect(sheet.width, lessThan(400));
    });

    testWidgets('floats as far as it is told to', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(offset: 24, safeArea: false, children: two),
      );

      expect(sheetRect(tester).bottom, 600 - 24);
    });

    testWidgets('adds the bottom inset to the offset, moving the whole sheet', (
      WidgetTester tester,
    ) async {
      const EdgeInsets padding = EdgeInsets.fromLTRB(11, 47, 13, 34);

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(children: two),
        padding: padding,
      );
      expect(sheetRect(tester).bottom, 600 - 16 - 34);

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(
          position: NebaFloatingBottomNavigationPosition.absolute,
          children: two,
        ),
        padding: padding,
      );
      expect(sheetRect(tester).bottom, 600 - 16);

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(safeArea: false, children: two),
        padding: padding,
      );
      expect(sheetRect(tester).bottom, 600 - 16);
    });

    testWidgets('goes back into the flow, centred, when it is static', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: <Widget>[
              NebaFloatingBottomNavigation<String>(
                position: NebaFloatingBottomNavigationPosition.static,
                children: two,
              ),
              Text('After'),
            ],
          ),
        ),
      );

      final Rect sheet = sheetRect(tester);
      expect(sheet.top, 0);
      expect(sheet.center.dx, 400);
      expect(tester.getRect(find.text('After')).top, sheet.bottom);
    });

    testWidgets('is a stadium, and cuts its destinations the same way', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));

      final NebaSheet sheet = tester.widget<NebaSheet>(
        find
            .descendant(
              of: find.byType(NebaFloatingBottomNavigation<String>),
              matching: find.byType(NebaSheet),
            )
            .first,
      );
      expect(sheet.borderRadius, BorderRadius.circular(9999));
      expect(sheet.edge, primary.line);
      expect(sheet.elevation, 2);
      expect(tester.widget<NebaSheet>(tile()).borderRadius, BorderRadius.circular(9999));
    });

    testWidgets('lets a press beside it through to what is underneath', (
      WidgetTester tester,
    ) async {
      int presses = 0;

      await tester.pumpWidget(
        host(
          Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => presses++,
                  child: const SizedBox.expand(),
                ),
              ),
              const NebaFloatingBottomNavigation<String>(children: two),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(100, 100));

      expect(presses, 1);
    });
  });

  group('choosing a destination', () {
    testWidgets('marks the current one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(value: 'search', children: two),
      );

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
      semantics.dispose();
    });

    testWidgets('reports the destination that was pressed', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaFloatingBottomNavigation<String>(
          labels: NebaBottomNavigationLabels.all,
          onValueChange: changes.add,
          children: two,
        ),
      );
      await tester.tap(find.text('Search'));

      expect(changes, <String>['search']);
    });

    testWidgets('keeps the choice in an uncontrolled bar', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(defaultValue: 'home', children: two),
      );
      await tester.tap(item('Search'));
      await tester.pumpAndSettle();

      expect(opacityOf(tester, 'Search'), 1);
      expect(opacityOf(tester, 'Home'), 0);
    });

    testWidgets('leaves a controlled bar where it was put', (WidgetTester tester) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaFloatingBottomNavigation<String>(
          value: 'home',
          onValueChange: changes.add,
          children: two,
        ),
      );
      await tester.tap(item('Search'));
      await tester.pumpAndSettle();

      expect(changes, <String>['search']);
      expect(opacityOf(tester, 'Home'), 1);
    });

    testWidgets('stops every destination answering when the bar is disabled', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];

      await pump(
        tester,
        NebaFloatingBottomNavigation<String>(
          disabled: true,
          labels: NebaBottomNavigationLabels.all,
          onValueChange: changes.add,
          children: two,
        ),
      );
      await tester.tap(find.text('Home'));

      expect(changes, isEmpty);
    });
  });

  group('the highlight', () {
    testWidgets('is laid out on the destination the reader is on', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(defaultValue: 'home', children: two),
      );

      expect(tileRect(tester), tester.getRect(item('Home')));
    });

    testWidgets('slides to the destination that was pressed, and lands on it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(defaultValue: 'home', children: two),
      );
      final Rect home = tester.getRect(item('Home'));

      await tester.tap(item('Search'));
      await tester.pump();
      await tester.pump(NebaScale.duration ~/ 2);

      final Rect midway = tileRect(tester);
      expect(midway.left, greaterThan(home.left));
      expect(midway.left, lessThan(tester.getRect(item('Search')).left));

      await tester.pumpAndSettle();
      // Where the destination finished, its name and all, not where it was
      // when the move began.
      expect(tileRect(tester), tester.getRect(item('Search')));
      expect(tester.getSize(item('Search')).width, greaterThan(tester.getSize(item('Home')).width));
    });

    testWidgets('lands at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(value: 'home', children: two),
        disableAnimations: true,
      );
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(value: 'search', children: two),
        disableAnimations: true,
      );

      expect(tileRect(tester), tester.getRect(item('Search')));
      expect(opacityOf(tester, 'Search'), 1);
    });

    testWidgets('goes away for a value no destination carries, and marks nothing', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(value: 'settings', children: two),
      );
      await tester.pumpAndSettle();

      expect(tileRect(tester).size, Size.zero);
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
      semantics.dispose();
    });

    testWidgets('is not drawn until a destination is current', (WidgetTester tester) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(children: two));

      expect(tileRect(tester).size, Size.zero);
    });

    testWidgets('follows a name that changes size', (WidgetTester tester) async {
      Widget bar(String name) {
        return NebaFloatingBottomNavigation<String>(
          value: 'home',
          labels: NebaBottomNavigationLabels.all,
          children: <NebaBottomNavigationItem<String>>[
            NebaBottomNavigationItem<String>(value: 'home', child: Text(name)),
            const NebaBottomNavigationItem<String>(value: 'search', child: Text('Search')),
          ],
        );
      }

      await pump(tester, bar('Home'));
      final double before = tileRect(tester).width;

      await pump(tester, bar('Home and everything in it'));
      await tester.pumpAndSettle();

      expect(tileRect(tester).width, greaterThan(before));
      expect(tileRect(tester), tester.getRect(item('Home and everything in it')));
    });

    testWidgets('follows the current destination when the bar is reordered', (
      WidgetTester tester,
    ) async {
      Widget bar(List<String> order) {
        return NebaFloatingBottomNavigation<String>(
          value: 'search',
          labels: NebaBottomNavigationLabels.all,
          children: <NebaBottomNavigationItem<String>>[
            for (final String value in order)
              NebaBottomNavigationItem<String>(
                key: ValueKey<String>(value),
                value: value,
                child: Text(value),
              ),
          ],
        );
      }

      await pump(tester, bar(<String>['home', 'inbox', 'search']));
      final Rect before = tileRect(tester);

      await pump(tester, bar(<String>['search', 'home', 'inbox']));
      await tester.pumpAndSettle();

      expect(tileRect(tester), tester.getRect(item('search')));
      expect(tileRect(tester).left, lessThan(before.left));
    });

    testWidgets('leaves the destination to carry the colour rather than a second fill', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));

      final BoxDecoration fill =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(of: item('Home'), matching: find.byType(DecoratedBox)).first,
                  )
                  .decoration
              as BoxDecoration;
      expect(fill.color, edgeless);
      expect(DefaultTextStyle.of(tester.element(find.text('Home'))).style.color, primary.onTint);
      expect(tester.widget<NebaSheet>(tile()).fill, primary.softHover);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));
      await tester.tap(item('Search'));
      await tester.pump(NebaScale.duration ~/ 2);

      expect(
        find.descendant(
          of: find.byType(NebaFloatingBottomNavigation<String>),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });
  });

  group('labels', () {
    testWidgets('draws only the current name by default', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));

      expect(opacityOf(tester, 'Home'), 1);
      expect(opacityOf(tester, 'Search'), 0);
      // Collapsed rather than hidden: the name takes no width, and is heard.
      expect(tester.getSize(item('Search')).width, lessThan(tester.getSize(item('Home')).width));
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('draws every name when it is asked to', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(
          value: 'home',
          labels: NebaBottomNavigationLabels.all,
          children: two,
        ),
      );

      expect(opacityOf(tester, 'Search'), 1);
    });

    // A name collapsed in both directions made a destination without one
    // shorter than one with one, and the bar's height dipped in the middle of
    // every move.
    testWidgets('holds every destination at one height, named or not', (WidgetTester tester) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));

      expect(tester.getSize(item('Search')).height, tester.getSize(item('Home')).height);
    });

    testWidgets('keeps the bar the same height as the current destination moves', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaFloatingBottomNavigation<String>(value: 'home', children: two));
      final double before = sheetRect(tester).height;

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(value: 'search', children: two),
      );

      for (int frame = 0; frame < 6; frame++) {
        await tester.pump(NebaScale.duration ~/ 6);
        expect(sheetRect(tester).height, before);
      }
    });

    testWidgets('keeps an undrawn name heard, so the destination still has one', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(
          labels: NebaBottomNavigationLabels.none,
          children: two,
        ),
      );

      expect(find.text('Home'), findsNothing);
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('puts the gap between one destination and the next', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaFloatingBottomNavigation<String>(
          labels: NebaBottomNavigationLabels.all,
          children: two,
        ),
      );

      expect(
        tester.getRect(item('Search')).left - tester.getRect(item('Home')).right,
        NebaFloatingBottomNavigation.gap[NebaSize.md],
      );
    });
  });
}
