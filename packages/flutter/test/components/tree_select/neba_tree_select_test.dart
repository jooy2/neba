// NebaTreeSelect: the suite the React package runs on TreeSelect, asked the
// way Flutter asks it — what the trigger says and what a screen reader hears
// of it, the tree its popup holds, what a press, a key and a search do to
// it, and what the control reports — rather than the elements and the ARIA
// it writes.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/field.dart';
import 'package:neba/src/internal/notch.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  const List<NebaTreeSelectItem<String>> regions = <NebaTreeSelectItem<String>>[
    NebaTreeSelectItem<String>(
      value: 'asia',
      label: Text('Asia'),
      children: <NebaTreeSelectItem<String>>[
        NebaTreeSelectItem<String>(value: 'kr', label: Text('Korea')),
        NebaTreeSelectItem<String>(value: 'jp', label: Text('Japan')),
      ],
    ),
    NebaTreeSelectItem<String>(
      value: 'europe',
      label: Text('Europe'),
      children: <NebaTreeSelectItem<String>>[
        NebaTreeSelectItem<String>(value: 'fr', label: Text('France')),
        NebaTreeSelectItem<String>(value: 'de', label: Text('Germany'), disabled: true),
      ],
    ),
  ];

  Future<void> pump(WidgetTester tester, Widget select, {Widget? after}) {
    return tester.pumpWidget(
      host(
        Overlay.wrap(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[select, ?after]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(NebaFieldShell));
    await settle(tester);
  }

  Finder tree() => find.byType(NebaTreeView<String>);

  /// The text field the popup searches with.
  Finder searchField() => find.byType(EditableText);

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(searchField(), text);
    await settle(tester);
  }

  FocusNode triggerNode(WidgetTester tester) {
    return tester
        .widget<Focus>(
          find.byWidgetPredicate(
            (Widget widget) => widget is Focus && widget.focusNode?.debugLabel == 'NebaTreeSelect',
          ),
        )
        .focusNode!;
  }

  group('the trigger', () {
    testWidgets('is a button named by its label, with nothing open', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaTreeSelect<String>(label: Text('Region'), items: regions));

      expect(
        tester.getSemantics(find.byType(NebaFieldWidth)),
        matchesSemantics(
          label: 'Region',
          isButton: true,
          hasExpandedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(tree(), findsNothing);
      semantics.dispose();
    });

    testWidgets('writes the labels of what it holds, comma-joined, and says them', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeSelect<String>(
          label: Text('Region'),
          items: regions,
          multiple: true,
          defaultValue: <String>['kr', 'fr'],
        ),
      );

      expect(find.text('Korea, France'), findsOneWidget);
      expect(tester.getSemantics(find.byType(NebaFieldWidth)).value, 'Korea, France');
      semantics.dispose();
    });

    testWidgets('shows its placeholder while nothing is held', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeSelect<String>(items: regions, placeholder: Text('Pick a region')),
      );
      await settle(tester);

      expect(find.text('Pick a region'), findsOneWidget);
      expect(
        DefaultTextStyle.of(tester.element(find.text('Pick a region'))).style.color,
        tokens.mutedFg,
      );
    });

    testWidgets('writes the trigger through a format of its own', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          multiple: true,
          defaultValue: const <String>['kr', 'fr'],
          format: (List<NebaTreeSelectItem<String>> chosen) => Text('${chosen.length} regions'),
        ),
      );

      expect(find.text('2 regions'), findsOneWidget);
    });

    testWidgets('is as wide as what it writes, unless it is full width', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, placeholder: Text('Pick')));

      final double short = tester.getSize(find.byType(NebaFieldShell)).width;

      await pump(
        tester,
        const NebaTreeSelect<String>(items: regions, placeholder: Text('Pick a region to ship to')),
      );

      expect(tester.getSize(find.byType(NebaFieldShell)).width, greaterThan(short));

      await pump(
        tester,
        const SizedBox(width: 400, child: NebaTreeSelect<String>(items: regions, fullWidth: true)),
      );

      expect(tester.getSize(find.byType(NebaFieldShell)).width, 400);
    });

    testWidgets('names the trigger from a notched label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaTreeSelect<String>(
          items: regions,
          labelPlacement: NebaLabelPlacement.notch,
          label: Text('Region'),
        ),
      );

      expect(find.byType(NebaNotch), findsOneWidget);
      expect(tester.getSemantics(find.byType(NebaFieldWidth)).label, 'Region');
      semantics.dispose();
    });
  });

  group('choosing', () {
    testWidgets('opens the tree and reports the leaf that was chosen', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          label: const Text('Region'),
          items: regions,
          defaultExpanded: const <String>['asia'],
          onValueChange: reported.add,
        ),
      );
      await open(tester);

      expect(tree(), findsOneWidget);

      await tester.tap(find.text('Korea'));
      await settle(tester);

      expect(reported, <List<String>>[
        <String>['kr'],
      ]);
      expect(find.text('Korea'), findsOneWidget);
    });

    testWidgets('does not let a branch be chosen unless asked', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTreeSelect<String>(items: regions, onValueChange: reported.add));
      await open(tester);
      await tester.tap(find.text('Asia'));
      await settle(tester);

      expect(reported, isEmpty);
    });

    testWidgets('still opens a branch that cannot be chosen, and stays open to pick inside it', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTreeSelect<String>(items: regions, onValueChange: reported.add));
      await open(tester);
      await tester.tap(find.text('Asia'));
      await settle(tester);

      expect(find.text('Korea'), findsOneWidget);
      expect(reported, isEmpty);

      await tester.tap(find.text('Korea'));
      await settle(tester);

      expect(reported, <List<String>>[
        <String>['kr'],
      ]);
    });

    testWidgets('lets a branch be chosen when asked', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          selectableBranches: true,
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Asia'));
      await settle(tester);

      expect(reported.single, <String>['asia']);
    });

    testWidgets('lets an item of its own say otherwise', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          items: const <NebaTreeSelectItem<String>>[
            NebaTreeSelectItem<String>(
              value: 'asia',
              label: Text('Asia'),
              selectable: true,
              children: <NebaTreeSelectItem<String>>[
                NebaTreeSelectItem<String>(value: 'kr', label: Text('Korea')),
              ],
            ),
          ],
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Asia'));
      await settle(tester);

      expect(reported.single, <String>['asia']);
    });

    testWidgets('holds more than one when multiple, and stays open', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          multiple: true,
          defaultExpanded: const <String>['asia', 'europe'],
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Korea'));
      await settle(tester);
      await tester.tap(find.text('France'));
      await settle(tester);

      expect(reported.last, <String>['kr', 'fr']);
      expect(tree(), findsOneWidget);
    });

    testWidgets('closes after a single choice and gives the focus back', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaTreeSelect<String>(items: regions, defaultExpanded: <String>['asia']),
      );
      await open(tester);
      await tester.tap(find.text('Korea'));
      await settle(tester);

      expect(tree(), findsNothing);
      expect(triggerNode(tester).hasFocus, isTrue);
    });

    testWidgets('leaves a disabled node unchoosable', (WidgetTester tester) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          defaultExpanded: const <String>['europe'],
          onValueChange: reported.add,
        ),
      );
      await open(tester);
      await tester.tap(find.text('Germany'));
      await settle(tester);

      expect(reported, isEmpty);
    });

    testWidgets('stays where the controlled value puts it', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          value: const <String>['jp'],
          defaultExpanded: const <String>['asia'],
          onValueChange: (List<String> _) {},
        ),
      );
      await open(tester);
      await tester.tap(find.text('Korea'));
      await settle(tester);

      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('Korea'), findsNothing);
    });
  });

  group('the popup', () {
    testWidgets('is the frosted sheet at elevation 3, as wide as the tree it holds', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions));
      await open(tester);

      final Finder sheet = find.ancestor(of: tree(), matching: find.byType(NebaSheet)).last;
      final NebaSheet popup = tester.widget<NebaSheet>(sheet);

      expect(popup.fill, tokens.panelPress);
      expect(popup.edge, primary.line);
      expect(popup.elevation, 3);
      // 256 for the tree, ten of padding a side and the hairline.
      expect(tester.getSize(sheet).width, 256 + 20 + 2);
    });

    testWidgets('opens on Enter and takes the focus into the tree', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions));
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(tree(), findsOneWidget);
      expect(FocusManager.instance.primaryFocus, Focus.of(tester.element(find.text('Asia'))));
    });

    // The popup opened with the focus left on the trigger, so a searchable
    // one opened from the keyboard did not take what was typed next.
    testWidgets('takes the focus into the search field when there is one', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(
        FocusManager.instance.primaryFocus,
        tester.widget<EditableText>(searchField()).focusNode,
      );
    });

    testWidgets('closes on Escape and gives the focus back to the trigger', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions));
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);

      expect(tree(), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      expect(tree(), findsNothing);
      expect(triggerNode(tester).hasFocus, isTrue);
    });

    testWidgets('walks the tree with the arrow keys and chooses with Enter', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(tester, NebaTreeSelect<String>(items: regions, onValueChange: reported.add));
      triggerNode(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);

      expect(reported.single, <String>['kr']);
      expect(tree(), findsNothing);
    });

    testWidgets('does not open when read-only or disabled', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, readOnly: true));
      await open(tester);

      expect(tree(), findsNothing);

      await pump(tester, const NebaTreeSelect<String>(items: regions, disabled: true));
      await open(tester);

      expect(tree(), findsNothing);
    });

    testWidgets('reports opening and closing to a controlled caller', (WidgetTester tester) async {
      final List<bool> reported = <bool>[];

      await pump(
        tester,
        NebaTreeSelect<String>(items: regions, open: false, onOpenChange: reported.add),
      );
      await open(tester);

      expect(reported, <bool>[true]);
      expect(tree(), findsNothing);
    });
  });

  group('searching', () {
    testWidgets('keeps a match and every ancestor of it', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      await open(tester);
      await search(tester, 'fran');

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
      expect(find.text('Asia'), findsNothing);
    });

    testWidgets('opens what it kept, so a match is not folded away', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      await open(tester);
      await search(tester, 'korea');

      expect(find.text('Korea'), findsOneWidget);
    });

    testWidgets('keeps every child of a branch that matches', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      await open(tester);
      await search(tester, 'asia');

      expect(find.text('Korea'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('ignores case and accents at every depth', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeSelect<String>(
          searchable: true,
          items: <NebaTreeSelectItem<String>>[
            NebaTreeSelectItem<String>(
              value: 'europe',
              label: Text('Europe'),
              children: <NebaTreeSelectItem<String>>[
                NebaTreeSelectItem<String>(value: 'fr', label: Text('Île-de-France')),
              ],
            ),
            NebaTreeSelectItem<String>(
              value: 'asia',
              label: Text('Asia'),
              children: <NebaTreeSelectItem<String>>[
                NebaTreeSelectItem<String>(value: 'kr', label: Text('Korea')),
              ],
            ),
          ],
        ),
      );
      await open(tester);
      await search(tester, 'ILE-DE');

      expect(find.text('Île-de-France'), findsOneWidget);
      expect(find.text('Asia'), findsNothing);
    });

    testWidgets('matches a searchLabel when the label is not text', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeSelect<String>(
          searchable: true,
          items: <NebaTreeSelectItem<String>>[
            NebaTreeSelectItem<String>(value: 'kr', label: SizedBox(), searchLabel: 'Korea'),
            NebaTreeSelectItem<String>(value: 'jp', label: Text('Japan')),
          ],
        ),
      );
      await open(tester);
      await search(tester, 'kor');

      expect(find.text('Japan'), findsNothing);
      expect(tree(), findsOneWidget);
    });

    testWidgets('says so when nothing matched', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      await open(tester);
      await search(tester, 'atlantis');

      expect(find.text('No matches'), findsOneWidget);
      expect(tree(), findsNothing);
    });

    testWidgets('starts afresh each time it opens', (WidgetTester tester) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, searchable: true));
      await open(tester);
      await search(tester, 'fran');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      await open(tester);

      expect(find.text('Asia'), findsOneWidget);
      expect(tester.widget<EditableText>(searchField()).controller.text, isEmpty);
    });
  });

  group('clearing', () {
    testWidgets('empties through the ×, which does not open the popup', (
      WidgetTester tester,
    ) async {
      final List<List<String>> reported = <List<String>>[];

      await pump(
        tester,
        NebaTreeSelect<String>(
          items: regions,
          defaultValue: const <String>['kr'],
          clearable: true,
          onValueChange: reported.add,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await settle(tester);

      expect(reported, <List<String>>[<String>[]]);
      expect(tree(), findsNothing);
      expect(find.bySemanticsLabel('Clear'), findsNothing);
    });

    testWidgets('names the × in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaTreeSelect<String>(
          locale: Locale('ko'),
          items: regions,
          defaultValue: <String>['kr'],
          clearable: true,
        ),
      );

      expect(find.bySemanticsLabel('지우기'), findsOneWidget);
    });

    testWidgets('takes a name of its own for the ×', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTreeSelect<String>(
          locale: Locale('ko'),
          items: regions,
          defaultValue: <String>['kr'],
          clearable: true,
          clearLabel: 'Empty',
        ),
      );

      expect(find.bySemanticsLabel('Empty'), findsOneWidget);
    });

    testWidgets('offers no × while nothing is held, or while read-only', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaTreeSelect<String>(items: regions, clearable: true));

      expect(find.bySemanticsLabel('Clear'), findsNothing);

      await pump(
        tester,
        const NebaTreeSelect<String>(
          items: regions,
          defaultValue: <String>['kr'],
          clearable: true,
          readOnly: true,
        ),
      );

      expect(find.bySemanticsLabel('Clear'), findsNothing);
    });
  });
}
