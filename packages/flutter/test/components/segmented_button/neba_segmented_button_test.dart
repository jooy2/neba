// NebaSegmentedButton: the suite the React package runs on SegmentedButton,
// asked the way Flutter asks it — the radio group a screen reader hears, the
// value it keeps, the one stop it makes in the focus order and where the arrow
// keys go, and the rectangle the tile is laid out at as it slides.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/glow.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/internal/tile.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<NebaSegment<String>> three = <NebaSegment<String>>[
    NebaSegment<String>(value: 'day', child: Text('Day')),
    NebaSegment<String>(value: 'week', child: Text('Week')),
    NebaSegment<String>(value: 'month', child: Text('Month')),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget set, {
    TextDirection direction = TextDirection.ltr,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      host(
        Center(child: set),
        textDirection: direction,
        disableAnimations: disableAnimations,
      ),
    );
  }

  Finder segment(String label) {
    return find.ancestor(of: find.text(label), matching: find.byType(NebaSegment<String>));
  }

  /// The tile: the one sheet inside the row. The trough is drawn beside it.
  Finder tile() {
    return find.descendant(of: find.byType(NebaTileRun), matching: find.byType(NebaSheet)).first;
  }

  /// The trough, drawn behind the row.
  Finder trough() {
    return find.descendant(of: find.byType(Positioned), matching: find.byType(NebaSheet));
  }

  Rect tileRect(WidgetTester tester) => tester.getRect(tile());

  FocusNode nodeOf(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label)));

  /// A segment that can be chosen and is not.
  Matcher unchecked(String label) {
    return matchesSemantics(
      label: label,
      isInMutuallyExclusiveGroup: true,
      hasCheckedState: true,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
    );
  }

  Color? inkOf(WidgetTester tester, String label) {
    return DefaultTextStyle.of(tester.element(find.text(label))).style.color;
  }

  group('rendering', () {
    testWidgets('is a radio group of radios, named by the caller', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          semanticLabel: 'Range',
          defaultValue: 'week',
          children: three,
        ),
      );

      final SemanticsNode set = tester.getSemantics(find.byType(NebaSegmentedButton<String>));
      expect(set.label, 'Range');
      expect(set.getSemanticsData().role, SemanticsRole.radioGroup);

      expect(
        tester.getSemantics(segment('Week')),
        matchesSemantics(
          label: 'Week',
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(tester.getSemantics(segment('Day')), unchecked('Day'));
      semantics.dispose();
    });

    testWidgets('reflects a changed label on rebuild', (WidgetTester tester) async {
      Widget set(String label) {
        return NebaSegmentedButton<String>(
          defaultValue: 'a',
          children: <NebaSegment<String>>[NebaSegment<String>(value: 'a', child: Text(label))],
        );
      }

      await pump(tester, set('Before'));
      await pump(tester, set('After'));

      expect(find.text('After'), findsOneWidget);
      expect(find.text('Before'), findsNothing);
    });

    testWidgets('places startIcon before and endIcon after the label', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(
          defaultValue: 'a',
          children: <NebaSegment<String>>[
            NebaSegment<String>(
              value: 'a',
              startIcon: Text('['),
              endIcon: Text(']'),
              child: Text('Day'),
            ),
          ],
        ),
      );

      expect(
        tester.getRect(find.text('[')).right,
        lessThanOrEqualTo(tester.getRect(find.text('Day')).left),
      );
      expect(
        tester.getRect(find.text(']')).left,
        greaterThanOrEqualTo(tester.getRect(find.text('Day')).right),
      );
    });

    testWidgets('lets a semantic label stand in for what is drawn', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          children: <NebaSegment<String>>[
            NebaSegment<String>(value: 'grid', semanticLabel: 'Grid view', child: Text('G')),
          ],
        ),
      );

      expect(tester.getSemantics(segment('G')).label, 'Grid view');
      semantics.dispose();
    });
  });

  group('choosing', () {
    testWidgets('changes the chosen segment when one is pressed, uncontrolled', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'day', children: three));

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(inkOf(tester, 'Month'), primary.onTint);
      expect(inkOf(tester, 'Day'), isNot(primary.onTint));
    });

    testWidgets('reports the chosen value, and not a press on the one already chosen', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          onValueChange: changes.add,
          children: three,
        ),
      );
      await tester.tap(find.text('Week'));
      await tester.pump();
      await tester.tap(find.text('Week'));
      await tester.pump();

      expect(changes, <String?>['week']);
    });

    testWidgets('leaves a controlled set where the caller put it', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(value: 'day', onValueChange: changes.add, children: three),
      );
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      expect(changes, <String?>['week']);
      expect(inkOf(tester, 'Day'), primary.onTint);
      expect(tileRect(tester), tester.getRect(segment('Day')));
    });

    testWidgets('follows a controlled value it is given', (WidgetTester tester) async {
      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));
      await pump(tester, const NebaSegmentedButton<String>(value: 'month', children: three));
      await tester.pumpAndSettle();

      expect(inkOf(tester, 'Month'), primary.onTint);
      expect(tileRect(tester), tester.getRect(segment('Month')));
    });

    testWidgets('starts with nothing chosen when no value is given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSegmentedButton<String>(children: three));

      for (final String label in <String>['Day', 'Week', 'Month']) {
        expect(tester.getSemantics(segment(label)), unchecked(label), reason: label);
      }
      semantics.dispose();
    });

    testWidgets('does not answer a press when disabled', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          disabled: true,
          onValueChange: changes.add,
          children: three,
        ),
      );
      await tester.tap(find.text('Week'), warnIfMissed: false);
      await tester.pump();

      expect(changes, isEmpty);
    });

    testWidgets('shows the chosen one but does not change it when read-only', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          readOnly: true,
          onValueChange: changes.add,
          children: three,
        ),
      );
      await tester.tap(find.text('Week'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
      expect(inkOf(tester, 'Day'), primary.onTint);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('draws no light and no hover under the pointer when read-only', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(defaultValue: 'day', readOnly: true, children: three),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Week')));
      await tester.pumpAndSettle();

      expect(find.descendant(of: segment('Week'), matching: find.byType(NebaGlow)), findsNothing);
      expect(inkOf(tester, 'Week'), tokens.mutedFg);
      expect(
        tester
            .widget<NebaInteractive>(
              find.descendant(of: segment('Week'), matching: find.byType(NebaInteractive)),
            )
            .cursor,
        SystemMouseCursors.basic,
      );
      await mouse.removePointer();
    });

    testWidgets('lights a segment and darkens its ink under the pointer', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'day', children: three));

      expect(find.descendant(of: segment('Week'), matching: find.byType(NebaGlow)), findsOneWidget);
      expect(inkOf(tester, 'Week'), tokens.mutedFg);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('Week')));
      await tester.pumpAndSettle();

      expect(inkOf(tester, 'Week'), tokens.fg);
      await mouse.removePointer();
    });

    testWidgets('leaves one disabled segment out without disabling the set', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          onValueChange: changes.add,
          children: const <NebaSegment<String>>[
            NebaSegment<String>(value: 'day', child: Text('Day')),
            NebaSegment<String>(value: 'week', disabled: true, child: Text('Week')),
            NebaSegment<String>(value: 'month', child: Text('Month')),
          ],
        ),
      );
      await tester.tap(find.text('Week'), warnIfMissed: false);
      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(changes, <String?>['month']);
      expect(inkOf(tester, 'Week'), tokens.disabledFg);
    });
  });

  group('disabled', () {
    testWidgets('drops the colour family from the trough, the tile and the labels', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(
          value: 'week',
          variant: NebaVariant.solid,
          disabled: true,
          children: three,
        ),
      );
      await tester.pumpAndSettle();

      final NebaSheet groove = tester.widget<NebaSheet>(trough());
      expect(groove.fill, edgeless);
      expect(groove.elevation, 0);
      expect(groove.plate, NebaPlate.none);

      final NebaSheet chosen = tester.widget<NebaSheet>(tile());
      expect(chosen.fill, tokens.disabledBg);
      expect(chosen.elevation, 0);

      for (final String label in <String>['Day', 'Week']) {
        expect(inkOf(tester, label), tokens.disabledFg, reason: label);
      }
    });

    testWidgets('keeps the outline hairline in the disabled border colour', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(value: 'week', disabled: true, children: three),
      );

      expect(tester.widget<NebaSheet>(trough()).edge, tokens.disabledBorder);
    });

    testWidgets('greys the tile under one disabled segment and not under the others', (
      WidgetTester tester,
    ) async {
      Widget set(String value) {
        return NebaSegmentedButton<String>(
          value: value,
          variant: NebaVariant.solid,
          children: const <NebaSegment<String>>[
            NebaSegment<String>(value: 'day', child: Text('Day')),
            NebaSegment<String>(value: 'week', disabled: true, child: Text('Week')),
          ],
        );
      }

      await pump(tester, set('week'));
      expect(tester.widget<NebaSheet>(tile()).fill, tokens.disabledBg);

      await pump(tester, set('day'));
      expect(tester.widget<NebaSheet>(tile()).fill, primary.fill);
    });
  });

  group('the tile', () {
    testWidgets('is measured onto the chosen segment from the first frame', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(value: 'week', children: three));

      expect(tileRect(tester), tester.getRect(segment('Week')));
    });

    testWidgets('is not drawn until something is chosen, and then appears in place', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(children: three));

      expect(tileRect(tester).size, Size.zero);

      await pump(tester, const NebaSegmentedButton<String>(value: 'week', children: three));

      // A first placement does not travel.
      expect(tileRect(tester), tester.getRect(segment('Week')));
    });

    testWidgets('slides by its rectangle to the next choice', (WidgetTester tester) async {
      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));

      final Rect day = tester.getRect(segment('Day'));
      final Rect month = tester.getRect(segment('Month'));

      await pump(tester, const NebaSegmentedButton<String>(value: 'month', children: three));
      await tester.pump(NebaScale.duration ~/ 2);

      final Rect midway = tileRect(tester);
      expect(midway.left, greaterThan(day.left));
      expect(midway.left, lessThan(month.left));
      // The width travels too: Day and Month are not the same width.
      expect(midway.width, greaterThan(day.width));
      expect(midway.width, lessThan(month.width));

      await tester.pump(NebaScale.duration);
      expect(tileRect(tester), month);
    });

    testWidgets('starts a move that interrupts another from where the tile is', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));
      await pump(tester, const NebaSegmentedButton<String>(value: 'month', children: three));
      await tester.pump(NebaScale.duration ~/ 2);
      final Rect midway = tileRect(tester);

      await pump(tester, const NebaSegmentedButton<String>(value: 'week', children: three));
      expect(tileRect(tester), midway);

      await tester.pumpAndSettle();
      expect(tileRect(tester), tester.getRect(segment('Week')));
    });

    testWidgets('lands at once for a reader who asked for less motion', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(value: 'day', children: three),
        disableAnimations: true,
      );
      await pump(
        tester,
        const NebaSegmentedButton<String>(value: 'month', children: three),
        disableAnimations: true,
      );

      expect(tileRect(tester), tester.getRect(segment('Month')));
    });

    testWidgets('goes for a value no segment carries, and comes back in place', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));
      await pump(tester, const NebaSegmentedButton<String>(value: 'year', children: three));
      await tester.pumpAndSettle();

      expect(tileRect(tester).size, Size.zero);
      // Nothing is announced as taken either.
      for (final String label in <String>['Day', 'Week', 'Month']) {
        expect(tester.getSemantics(segment(label)), unchecked(label), reason: label);
      }

      await pump(tester, const NebaSegmentedButton<String>(value: 'month', children: three));
      expect(tileRect(tester), tester.getRect(segment('Month')));
      semantics.dispose();
    });

    testWidgets('moves with the set when it resizes, without travelling', (
      WidgetTester tester,
    ) async {
      Widget set(double width) {
        return SizedBox(
          width: width,
          child: const NebaSegmentedButton<String>(
            value: 'month',
            fullWidth: true,
            children: three,
          ),
        );
      }

      await pump(tester, set(400));
      await pump(tester, set(600));

      expect(tileRect(tester), tester.getRect(segment('Month')));
    });

    testWidgets('lands a move at once when the set resizes during it', (WidgetTester tester) async {
      Widget set(double width, String value) {
        return SizedBox(
          width: width,
          child: NebaSegmentedButton<String>(value: value, fullWidth: true, children: three),
        );
      }

      await pump(tester, set(400, 'day'));
      await pump(tester, set(400, 'month'));
      await tester.pump(NebaScale.duration ~/ 2);
      await pump(tester, set(600, 'month'));

      expect(tileRect(tester), tester.getRect(segment('Month')));
    });

    testWidgets('follows the chosen segment when the set is reordered', (
      WidgetTester tester,
    ) async {
      Widget set(List<String> order) {
        return NebaSegmentedButton<String>(
          value: 'month',
          children: <NebaSegment<String>>[
            for (final String value in order)
              NebaSegment<String>(key: ValueKey<String>(value), value: value, child: Text(value)),
          ],
        );
      }

      await pump(tester, set(<String>['day', 'week', 'month']));
      final Rect before = tileRect(tester);

      await pump(tester, set(<String>['month', 'day', 'week']));
      await tester.pumpAndSettle();

      expect(tileRect(tester), tester.getRect(segment('month')));
      expect(tileRect(tester), isNot(before));
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));
      await pump(tester, const NebaSegmentedButton<String>(value: 'month', children: three));
      await tester.pump(NebaScale.duration ~/ 2);

      expect(
        find.descendant(
          of: find.byType(NebaSegmentedButton<String>),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });

    testWidgets('fills solid with the family and lights the others', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(
          value: 'day',
          variant: NebaVariant.solid,
          children: three,
        ),
      );
      final NebaSheet filled = tester.widget<NebaSheet>(tile());
      expect(filled.fill, primary.fill);
      expect(filled.plate, NebaPlate.solid);
      expect(filled.elevation, 1);

      await pump(tester, const NebaSegmentedButton<String>(value: 'day', children: three));
      final NebaSheet lit = tester.widget<NebaSheet>(tile());
      expect(lit.fill, primary.panelPress);
      expect(lit.plate, NebaPlate.glass);
    });
  });

  group('focus', () {
    testWidgets('is one stop in the focus order, at the chosen segment', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'week', children: three));

      expect(nodeOf(tester, 'Day').skipTraversal, isTrue);
      expect(nodeOf(tester, 'Week').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Month').skipTraversal, isTrue);
    });

    testWidgets('stops at the first segment that is not disabled when nothing is chosen', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(
          children: <NebaSegment<String>>[
            NebaSegment<String>(value: 'day', disabled: true, child: Text('Day')),
            NebaSegment<String>(value: 'week', child: Text('Week')),
          ],
        ),
      );

      expect(nodeOf(tester, 'Week').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Day').canRequestFocus, isFalse);
    });

    testWidgets('moves and chooses with the arrow keys, and wraps at the ends', (
      WidgetTester tester,
    ) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          onValueChange: changes.add,
          children: three,
        ),
      );

      nodeOf(tester, 'Day').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Week').hasPrimaryFocus, isTrue);
      expect(nodeOf(tester, 'Week').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Day').skipTraversal, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Day').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(nodeOf(tester, 'Month').hasPrimaryFocus, isTrue);

      expect(changes, <String?>['week', 'month', 'day', 'month']);
    });

    testWidgets('turns the horizontal keys round under RTL', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          onValueChange: changes.add,
          children: three,
        ),
        direction: TextDirection.rtl,
      );

      // The first segment is at the right.
      expect(
        tester.getCenter(find.text('Day')).dx,
        greaterThan(tester.getCenter(find.text('Week')).dx),
      );

      nodeOf(tester, 'Day').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(nodeOf(tester, 'Week').hasPrimaryFocus, isTrue);
      expect(changes, <String?>['week']);
    });

    testWidgets('passes over a segment that is disabled', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(
          defaultValue: 'day',
          children: <NebaSegment<String>>[
            NebaSegment<String>(value: 'day', child: Text('Day')),
            NebaSegment<String>(value: 'week', disabled: true, child: Text('Week')),
            NebaSegment<String>(value: 'month', child: Text('Month')),
          ],
        ),
      );

      nodeOf(tester, 'Day').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(nodeOf(tester, 'Month').hasPrimaryFocus, isTrue);
    });

    testWidgets('moves without choosing when read-only', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(
        tester,
        NebaSegmentedButton<String>(
          defaultValue: 'day',
          readOnly: true,
          onValueChange: changes.add,
          children: three,
        ),
      );

      nodeOf(tester, 'Day').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(nodeOf(tester, 'Week').hasPrimaryFocus, isTrue);
      expect(nodeOf(tester, 'Week').skipTraversal, isFalse);
      expect(changes, isEmpty);
      expect(inkOf(tester, 'Day'), primary.onTint);

      // Once the focus has left, the set's stop is the chosen segment again.
      nodeOf(tester, 'Week').unfocus();
      await tester.pumpAndSettle();
      expect(nodeOf(tester, 'Day').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Week').skipTraversal, isTrue);
    });

    testWidgets('chooses the focused segment with Space and Enter', (WidgetTester tester) async {
      final List<String?> changes = <String?>[];

      await pump(tester, NebaSegmentedButton<String>(onValueChange: changes.add, children: three));

      nodeOf(tester, 'Week').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      nodeOf(tester, 'Month').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(changes, <String?>['week', 'month']);
    });

    testWidgets('draws its focus ring inside the segment', (WidgetTester tester) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'day', children: three));

      final NebaFocusRing ring = tester.widget<NebaFocusRing>(
        find.descendant(of: segment('Day'), matching: find.byType(NebaFocusRing)),
      );
      expect(ring.offset, -focusRingWidth);
    });
  });

  group('style props', () {
    testWidgets('maps color onto the trough and the tile', (WidgetTester tester) async {
      final NebaColorRoles success = tokens.roles(NebaColor.success);

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          value: 'day',
          variant: NebaVariant.solid,
          color: NebaColor.success,
          children: three,
        ),
      );

      expect(tester.widget<NebaSheet>(trough()).fill, success.panel);
      expect(tester.widget<NebaSheet>(tile()).fill, success.fill);
    });

    testWidgets('changes the segment height with size and the padding with density', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(size: NebaSize.lg, children: three));
      final Size standard = tester.getSize(segment('Day'));
      expect(standard.height, 40);

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          size: NebaSize.lg,
          density: NebaDensity.compact,
          children: three,
        ),
      );
      final Size compact = tester.getSize(segment('Day'));
      expect(compact.height, 40);
      expect(
        standard.width - compact.width,
        2 *
            (NebaScale.paddingX[NebaDensity.standard]![NebaSize.lg]! -
                NebaScale.paddingX[NebaDensity.compact]![NebaSize.lg]!),
      );
    });

    testWidgets('takes its size and variant from NebaProvider', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg, variant: NebaVariant.text),
          child: NebaSegmentedButton<String>(children: three),
        ),
      );

      expect(tester.getSize(segment('Day')).height, 40);
      expect(trough(), findsNothing);
    });

    testWidgets('draws a trough for solid and outline and none for text', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'day', children: three));
      final NebaSheet outline = tester.widget<NebaSheet>(trough());
      expect(outline.edge, primary.line);
      expect(outline.fill, primary.panel);
      // The hairline and the padding around a segment of 32.
      expect(tester.getSize(find.byType(NebaSegmentedButton<String>)).height, 32 + 2 * (4 + 1));

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          defaultValue: 'day',
          variant: NebaVariant.solid,
          children: three,
        ),
      );
      expect(tester.widget<NebaSheet>(trough()).edge, isNull);
      expect(tester.getSize(find.byType(NebaSegmentedButton<String>)).height, 32 + 2 * 4);

      await pump(
        tester,
        const NebaSegmentedButton<String>(
          defaultValue: 'day',
          variant: NebaVariant.text,
          children: three,
        ),
      );
      expect(trough(), findsNothing);
      expect(tester.getSize(find.byType(NebaSegmentedButton<String>)).height, 32);
    });

    testWidgets('gives the trough its elevation and the tile one level', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSegmentedButton<String>(defaultValue: 'day', elevation: 2, children: three),
      );

      expect(tester.widget<NebaSheet>(trough()).elevation, 2);
      expect(tester.widget<NebaSheet>(tile()).elevation, 1);
    });

    testWidgets('stretches and divides the width when fullWidth is set', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const SizedBox(
          width: 400,
          child: NebaSegmentedButton<String>(defaultValue: 'day', fullWidth: true, children: three),
        ),
      );

      expect(tester.getSize(find.byType(NebaSegmentedButton<String>)).width, 400);

      final double share = (400 - 2 * 5) / 3;
      for (final String label in <String>['Day', 'Week', 'Month']) {
        expect(tester.getSize(segment(label)).width, moreOrLessEquals(share), reason: label);
      }
    });

    testWidgets('is as wide as its segments without fullWidth', (WidgetTester tester) async {
      await pump(tester, const NebaSegmentedButton<String>(defaultValue: 'day', children: three));

      final double segments =
          tester.getSize(segment('Day')).width +
          tester.getSize(segment('Week')).width +
          tester.getSize(segment('Month')).width;
      expect(tester.getSize(find.byType(NebaSegmentedButton<String>)).width, segments + 2 * 5);
    });
  });
}
