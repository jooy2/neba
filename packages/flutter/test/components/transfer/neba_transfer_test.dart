// NebaTransfer: the suite the React package runs on Transfer, asked the way
// Flutter asks it — the lists and the counts it draws, what a screen reader
// hears of each list, the arrows and the live region, what a tick, a press
// and a search do, and what the transfer reports — rather than the elements,
// the classes and the hidden inputs it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/live_region.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<NebaTransferItem<String>> items = <NebaTransferItem<String>>[
    NebaTransferItem<String>(value: 'status', label: Text('Status')),
    NebaTransferItem<String>(value: 'duration', label: Text('Duration')),
    NebaTransferItem<String>(value: 'commit', label: Text('Commit')),
    NebaTransferItem<String>(value: 'author', label: Text('Author')),
    NebaTransferItem<String>(value: 'region', label: Text('Region'), disabled: true),
  ];

  Future<void> pump(
    WidgetTester tester,
    Widget transfer, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 640, child: transfer),
        ),
        textDirection: textDirection,
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder send() => find.bySemanticsLabel('Move to selected');

  Finder back() => find.bySemanticsLabel('Move to available');

  Future<void> tick(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
  }

  Future<void> press(WidgetTester tester, Finder button) async {
    await tester.tap(button);
    await settle(tester);
  }

  /// What the live region says.
  String spoken(WidgetTester tester) {
    return tester
        .getSemantics(
          find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(SizedBox)),
        )
        .label;
  }

  /// How far up a row has faded.
  double opacityOf(WidgetTester tester, String label) {
    return tester
        .widget<Opacity>(find.ancestor(of: find.text(label), matching: find.byType(Opacity)).first)
        .opacity;
  }

  group('rendering', () {
    testWidgets('draws both lists and the two arrows', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTransfer<String>(items: items));

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Selected'), findsOneWidget);
      expect(send(), findsOneWidget);
      expect(back(), findsOneWidget);
      semantics.dispose();
    });

    // The two lists hold identical controls, a "Select all" each and a
    // search field each, so each list is a group named by its heading.
    testWidgets('names each list by its heading, around a select-all of its own', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTransfer<String>(items: items, searchable: true));

      final Finder available = find.bySemanticsLabel('Available');
      final Finder selected = find.bySemanticsLabel('Selected');

      expect(available, findsOneWidget);
      expect(selected, findsOneWidget);
      expect(find.bySemanticsLabel('Select all'), findsNWidgets(2));
      expect(
        find.descendant(of: available, matching: find.bySemanticsLabel('Select all')),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('starts everything on the left', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items));

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('0/5'), findsOneWidget);
      expect(find.text('0/0'), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('puts the default value on the right', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTransfer<String>(items: items, defaultValue: <String>['commit', 'author']),
      );

      expect(find.text('0/3'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
    });

    testWidgets('takes headings of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTransfer<String>(
          items: items,
          sourceLabel: Text('All columns'),
          targetLabel: Text('Shown'),
        ),
      );

      expect(find.text('All columns'), findsOneWidget);
      expect(find.text('Shown'), findsOneWidget);
    });

    testWidgets('draws each list on a field sheet that rings while it holds the focus', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransfer<String>(items: items, searchable: true));

      NebaSheet sheet() => tester.widget<NebaSheet>(
        find.ancestor(of: find.text('Available'), matching: find.byType(NebaSheet)).last,
      );

      expect(sheet().fill, tokens.panel);
      expect(sheet().edge, primary.line);

      tester.widget<EditableText>(find.byType(EditableText).first).focusNode.requestFocus();
      await settle(tester);

      expect(sheet().edge, primary.ring);
    });

    testWidgets('holds each list to its height', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items, height: 120));

      expect(tester.getSize(find.byType(NebaScrollArea).first).height, 120);
    });
  });

  group('moving', () {
    testWidgets('sends the ticked rows across', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTransfer<String>(items: items, onValueChange: reported.add));
      await tick(tester, 'Status');
      await tick(tester, 'Commit');
      await press(tester, send());

      expect(reported.single, <String>['status', 'commit']);
      expect(find.text('0/3'), findsOneWidget);
      expect(find.text('0/2'), findsOneWidget);
    });

    testWidgets('tells a screen reader what moved, and says it again for the same move', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTransfer<String>(items: items, targetLabel: Text('Shown')));
      await tick(tester, 'Status');
      await tick(tester, 'Commit');
      await press(tester, send());

      expect(spoken(tester), '2 moved to Shown');

      await tick(tester, 'Status');
      await press(tester, back());

      expect(spoken(tester), '1 moved to Available');

      await tick(tester, 'Commit');
      await tester.tap(back());
      await tester.pump();

      // The same sentence again, so the region is emptied before it is
      // written.
      expect(spoken(tester), '');

      await tester.pump(const Duration(milliseconds: 150));

      expect(spoken(tester), '1 moved to Available');
      semantics.dispose();
    });

    // A value the items did not list vanished on the way right and stayed on
    // the way left.
    testWidgets('keeps a value it has no row for, whichever way rows move', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTransfer<String>(
          items: items,
          defaultValue: const <String>['status', 'ghost'],
          onValueChange: reported.add,
        ),
      );
      await tick(tester, 'Commit');
      await press(tester, send());

      expect(reported.last, <String>['status', 'commit', 'ghost']);

      await tick(tester, 'Status');
      await press(tester, back());

      expect(reported.last, <String>['commit', 'ghost']);
    });

    testWidgets('sends them back again', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTransfer<String>(
          items: items,
          defaultValue: const <String>['status'],
          onValueChange: reported.add,
        ),
      );
      await tick(tester, 'Status');
      await press(tester, back());

      expect(reported.single, <String>[]);
    });

    testWidgets('fades up the rows that just arrived, and only those', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items));
      await tick(tester, 'Status');
      await tester.tap(send());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(opacityOf(tester, 'Status'), lessThan(1));
      expect(opacityOf(tester, 'Commit'), 1);

      await tester.pump(const Duration(milliseconds: 400));

      expect(opacityOf(tester, 'Status'), 1);
    });

    // The load-bearing half: the rows also change on every keystroke in the
    // search field, and a filter that animates is a filter that feels slow.
    testWidgets('does not fade a row the search field merely uncovered', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransfer<String>(items: items, searchable: true));
      await tester.enterText(find.byType(EditableText).first, 'stat');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).first, '');
      await tester.pump();

      expect(opacityOf(tester, 'Commit'), 1);
    });

    testWidgets('keeps the order of items whichever side a row is on', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTransfer<String>(items: items, onValueChange: reported.add));
      await tick(tester, 'Commit');
      await tick(tester, 'Status');
      await press(tester, send());

      expect(reported.single, <String>['status', 'commit']);
    });

    testWidgets('leaves the arrows unavailable while nothing is ticked', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTransfer<String>(items: items));

      expect(
        tester.getSemantics(send()),
        matchesSemantics(
          label: 'Move to selected',
          isButton: true,
          hasEnabledState: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    // Moving every ticked row runs the arrow out, and a disabled button would
    // hand the focus to nothing.
    testWidgets('keeps the focus on an arrow the press ran out', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items));
      await tick(tester, 'Status');

      final FocusNode arrow = Focus.of(
        tester.element(
          find.descendant(of: find.byType(NebaIconButton).first, matching: find.byType(RotatedBox)),
        ),
      );

      arrow.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(find.text('0/1'), findsOneWidget);
      expect(arrow.hasFocus, isTrue);
    });

    testWidgets('takes both arrows out of reach when the whole transfer is disabled', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransfer<String>(items: items, disabled: true));

      for (final NebaIconButton button in tester.widgetList<NebaIconButton>(
        find.byType(NebaIconButton),
      )) {
        expect(button.disabled, isTrue);
        expect(button.focusableWhenDisabled, isFalse);
      }

      for (final NebaCheckbox box in tester.widgetList<NebaCheckbox>(find.byType(NebaCheckbox))) {
        expect(box.disabled, isTrue);
      }
    });

    testWidgets('never ticks or moves a disabled row', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items));

      final NebaCheckbox region = tester.widget<NebaCheckbox>(
        find.ancestor(of: find.text('Region'), matching: find.byType(NebaCheckbox)),
      );

      expect(region.disabled, isTrue);
    });

    testWidgets('stays where the controlled value puts it', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTransfer<String>(items: items, value: const <String>[], onValueChange: (_) {}),
      );
      await tick(tester, 'Status');
      await press(tester, send());

      expect(find.text('0/5'), findsOneWidget);
    });
  });

  group('select all', () {
    testWidgets('ticks every movable row on that side', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTransfer<String>(items: items, onValueChange: reported.add));
      await tester.tap(find.byType(NebaCheckbox).first);
      await tester.pump();

      expect(find.text('4/5'), findsOneWidget);

      await press(tester, send());

      expect(reported.single, <String>['status', 'duration', 'commit', 'author']);
    });

    testWidgets('says it is mixed while only some rows are ticked', (WidgetTester tester) async {
      await pump(tester, const NebaTransfer<String>(items: items));
      await tick(tester, 'Status');

      expect(tester.widget<NebaCheckbox>(find.byType(NebaCheckbox).first).indeterminate, isTrue);
    });
  });

  group('searchable', () {
    testWidgets('filters a list without changing what is on which side', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTransfer<String>(items: items, searchable: true));
      await tester.enterText(find.byType(EditableText).first, 'com');
      await tester.pump();

      expect(find.text('Commit'), findsOneWidget);
      expect(find.text('Status'), findsNothing);
      expect(find.text('0/1'), findsOneWidget);
    });

    // The same fold a DataTable's search field uses.
    testWidgets('ignores case and accents', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTransfer<String>(
          items: <NebaTransferItem<String>>[
            const NebaTransferItem<String>(value: 'region', label: Text('Région')),
            ...items.take(4),
          ],
          searchable: true,
        ),
      );
      await tester.enterText(find.byType(EditableText).first, 'REGION');
      await tester.pump();

      expect(find.text('Région'), findsOneWidget);
      expect(find.text('Commit'), findsNothing);
    });

    testWidgets('keeps a row whose label is not a Text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTransfer<String>(
          items: <NebaTransferItem<String>>[
            NebaTransferItem<String>(
              value: 'chip',
              label: Row(children: <Widget>[Text('Chipped')]),
            ),
            ...items,
          ],
          searchable: true,
        ),
      );
      await tester.enterText(find.byType(EditableText).first, 'zzzz');
      await tester.pump();

      expect(find.text('Status'), findsNothing);
      expect(find.text('Chipped'), findsOneWidget);
    });

    testWidgets('moves only what the filter left showing', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTransfer<String>(items: items, searchable: true, onValueChange: reported.add),
      );
      await tick(tester, 'Status');
      await tick(tester, 'Commit');
      await tester.enterText(find.byType(EditableText).first, 'com');
      await tester.pump();
      await press(tester, send());

      expect(reported.single, <String>['commit']);
    });
  });

  // Both arrows were drawn for a left-to-right layout only, so under RTL,
  // where the chosen list sits on the left, each pointed away from where it
  // moves.
  testWidgets('turns both arrows round right to left', (WidgetTester tester) async {
    List<int> turns() => <int>[
      for (final RotatedBox box in tester.widgetList<RotatedBox>(find.byType(RotatedBox)))
        box.quarterTurns,
    ];

    await pump(tester, const NebaTransfer<String>(items: items));

    expect(turns(), <int>[0, 2]);

    await pump(tester, const NebaTransfer<String>(items: items), textDirection: TextDirection.rtl);

    expect(turns(), <int>[2, 0]);
  });
}
