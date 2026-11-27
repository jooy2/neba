// NebaToggleGroup: the suite the React package runs on ToggleGroup, asked the
// way Flutter asks it — the value it keeps, the stop it makes in the focus
// order and where the arrow keys go, and what each toggle inherits.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<Widget> three = <Widget>[
    NebaToggle(value: 'left', child: Text('Left')),
    NebaToggle(value: 'centre', child: Text('Centre')),
    NebaToggle(value: 'right', child: Text('Right')),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget group, {
    TextDirection direction = TextDirection.ltr,
  }) {
    return tester.pumpWidget(host(Center(child: group), textDirection: direction));
  }

  NebaSheet sheetOf(WidgetTester tester, String label) {
    return tester.widget<NebaSheet>(
      find.ancestor(of: find.text(label), matching: find.byType(NebaSheet)),
    );
  }

  bool on(WidgetTester tester, String label) => sheetOf(tester, label).fill == primary.panelPress;

  FocusNode nodeOf(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label)));

  group('value', () {
    testWidgets('starts with the default value on', (WidgetTester tester) async {
      await pump(tester, const NebaToggleGroup(defaultValue: <String>['centre'], children: three));

      expect(on(tester, 'Centre'), isTrue);
      expect(on(tester, 'Left'), isFalse);
    });

    testWidgets('replaces the toggle that was on, by default', (WidgetTester tester) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaToggleGroup(
          defaultValue: const <String>['left'],
          onValueChange: changes.add,
          children: three,
        ),
      );
      await tester.tap(find.text('Right'));
      await tester.pump();

      expect(on(tester, 'Right'), isTrue);
      expect(on(tester, 'Left'), isFalse);
      expect(changes.last, <String>['right']);

      await tester.tap(find.text('Right'));
      await tester.pump();
      expect(changes.last, isEmpty);
    });

    testWidgets('keeps several on with multiple', (WidgetTester tester) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaToggleGroup(multiple: true, onValueChange: changes.add, children: three),
      );
      await tester.tap(find.text('Left'));
      await tester.pump();
      await tester.tap(find.text('Right'));
      await tester.pump();

      expect(on(tester, 'Left'), isTrue);
      expect(on(tester, 'Right'), isTrue);
      expect(changes.last, <String>['left', 'right']);
    });

    testWidgets('stays where a controlled value puts it', (WidgetTester tester) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaToggleGroup(value: const <String>['left'], onValueChange: changes.add, children: three),
      );
      await tester.tap(find.text('Right'));
      await tester.pump();

      expect(changes.last, <String>['right']);
      expect(on(tester, 'Left'), isTrue);
      expect(on(tester, 'Right'), isFalse);
    });
  });

  group('focus', () {
    testWidgets('is one stop in the focus order, at the toggle that is on', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToggleGroup(defaultValue: <String>['centre'], children: three));

      expect(nodeOf(tester, 'Left').skipTraversal, isTrue);
      expect(nodeOf(tester, 'Centre').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Right').skipTraversal, isTrue);
    });

    testWidgets('moves with the arrow keys, wraps at the ends, and takes the stop along', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToggleGroup(children: three));

      nodeOf(tester, 'Left').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Centre').hasPrimaryFocus, isTrue);
      expect(nodeOf(tester, 'Centre').skipTraversal, isFalse);
      expect(nodeOf(tester, 'Left').skipTraversal, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(nodeOf(tester, 'Right').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(nodeOf(tester, 'Left').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(nodeOf(tester, 'Right').hasPrimaryFocus, isTrue);
    });

    testWidgets('stops at the ends without loopFocus, and turns the keys round under RTL', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaToggleGroup(loopFocus: false, children: three),
        direction: TextDirection.rtl,
      );

      nodeOf(tester, 'Left').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Left').hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(nodeOf(tester, 'Centre').hasPrimaryFocus, isTrue);
    });

    testWidgets('skips a toggle that is disabled', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToggleGroup(
          children: <Widget>[
            NebaToggle(value: 'left', child: Text('Left')),
            NebaToggle(value: 'centre', disabled: true, child: Text('Centre')),
            NebaToggle(value: 'right', child: Text('Right')),
          ],
        ),
      );

      nodeOf(tester, 'Left').requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodeOf(tester, 'Right').hasPrimaryFocus, isTrue);
    });
  });

  group('shared props', () {
    testWidgets('sets the size and disables every toggle at once', (WidgetTester tester) async {
      final List<List<String>> changes = <List<String>>[];

      await pump(
        tester,
        NebaToggleGroup(
          size: NebaSize.lg,
          disabled: true,
          onValueChange: changes.add,
          children: three,
        ),
      );
      await tester.tap(find.text('Left'), warnIfMissed: false);

      expect(changes, isEmpty);
      expect(
        tester
            .getSize(find.ancestor(of: find.text('Left'), matching: find.byType(NebaSheet)))
            .height,
        40,
      );
    });

    testWidgets('squares the corners that face a neighbour and shares one hairline', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaToggleGroup(children: three));

      expect(sheetOf(tester, 'Centre').borderRadius, BorderRadius.zero);
      expect(
        tester
            .getRect(find.ancestor(of: find.text('Centre'), matching: find.byType(NebaSheet)))
            .left,
        tester
                .getRect(find.ancestor(of: find.text('Left'), matching: find.byType(NebaSheet)))
                .right -
            1,
      );
    });

    testWidgets('turns the run on its side when vertical', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaToggleGroup(orientation: NebaOrientation.vertical, children: three),
      );

      expect(
        tester.getTopLeft(find.text('Centre')).dy,
        greaterThan(tester.getBottomLeft(find.text('Left')).dy),
      );
    });
  });
}
