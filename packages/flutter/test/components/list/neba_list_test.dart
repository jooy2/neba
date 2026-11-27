// NebaList and NebaListItem: the suite the React package runs on List, asked
// the way Flutter asks it — the semantics a row carries, the sheet and the
// tint it is drawn with, and where the rows land — rather than the elements
// and classes it writes.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/focus_ring.dart';
import 'package:neba/src/internal/surface.dart';

import '../../support/host.dart';

void noop() {}

/// How many probes have been built from scratch, which is what a row losing
/// its place in the tree would show.
int probeStarts = 0;

class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    probeStarts++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 8);
}

void main() {
  final NebaTokens tokens = NebaTokens.light();
  final NebaColorRoles primary = tokens.roles(NebaColor.primary);

  Future<void> pump(WidgetTester tester, Widget list, {double width = 360}) {
    return tester.pumpWidget(
      host(
        Center(
          child: SizedBox(width: width, child: list),
        ),
      ),
    );
  }

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  /// The tint behind a row's label: the first decorated box above it.
  BoxDecoration tintOf(WidgetTester tester, String label) {
    return tester
            .widgetList<DecoratedBox>(
              find.ancestor(of: find.text(label), matching: find.byType(DecoratedBox)),
            )
            .first
            .decoration
        as BoxDecoration;
  }

  SemanticsNode nodeOf(WidgetTester tester, String label) {
    return tester.getSemantics(find.text(label));
  }

  group('rendering', () {
    testWidgets('is a list of items as far as semantics can say it', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaList(
          children: <Widget>[
            NebaListItem(child: Text('One')),
            NebaListItem(child: Text('Two')),
          ],
        ),
      );

      final SemanticsNode list = tester.getSemantics(find.byType(NebaList));
      expect(list.role, SemanticsRole.list);

      final List<SemanticsNode> items = <SemanticsNode>[];
      list.visitChildren((SemanticsNode child) {
        items.add(child);
        return true;
      });
      expect(items.map((SemanticsNode node) => node.role), <SemanticsRole>[
        SemanticsRole.listItem,
        SemanticsRole.listItem,
      ]);
      expect(items.map((SemanticsNode node) => node.label), <String>['One', 'Two']);

      semantics.dispose();
    });

    testWidgets('lays the description under the label, a step down the type scale', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[NebaListItem(description: Text('12 items'), child: Text('Documents'))],
        ),
      );

      final Rect label = tester.getRect(find.text('Documents'));
      final Rect description = tester.getRect(find.text('12 items'));

      expect(description.top, greaterThanOrEqualTo(label.bottom));
      expect(styleOf(tester, 'Documents').fontSize, NebaScale.sheetBodyText[NebaSize.md]);
      expect(styleOf(tester, '12 items').fontSize, NebaScale.metaText[NebaSize.md]);
      expect(styleOf(tester, '12 items').color, tokens.mutedFg);
    });

    testWidgets('cuts a long label short on one line', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[
            NebaListItem(child: Text('A label far too long to fit on one line of this list')),
          ],
        ),
        width: 160,
      );

      final RichText text = tester.widget<RichText>(find.byType(RichText));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reflects a changed label on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaList(children: <Widget>[NebaListItem(child: Text('Before'))]));
      await pump(tester, const NebaList(children: <Widget>[NebaListItem(child: Text('After'))]));

      expect(find.text('Before'), findsNothing);
      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('keeps a row\u2019s state when another is put in front of it', (
      WidgetTester tester,
    ) async {
      probeStarts = 0;

      await pump(
        tester,
        const NebaList(
          dividers: true,
          children: <Widget>[
            NebaListItem(key: ValueKey<String>('b'), action: _Probe(), child: Text('B')),
          ],
        ),
      );
      await pump(
        tester,
        NebaList(
          dividers: true,
          children: const <Widget>[
            NebaListItem(key: ValueKey<String>('a'), action: _Probe(), child: Text('A')),
            NebaListItem(key: ValueKey<String>('b'), action: _Probe(), child: Text('B')),
          ],
        ),
      );

      expect(probeStarts, 2);
    });
  });

  group('rows that do something', () {
    testWidgets('is inert until it is given something to do', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaList(children: <Widget>[NebaListItem(child: Text('Plain'))]));

      expect(nodeOf(tester, 'Plain'), matchesSemantics(label: 'Plain'));
      expect(
        find.descendant(of: find.byType(NebaList), matching: find.byType(Focus)),
        findsNothing,
      );

      semantics.dispose();
    });

    testWidgets('is a button when it can be pressed, on a tap, Enter and Space', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      int presses = 0;

      await pump(
        tester,
        NebaList(
          children: <Widget>[
            NebaListItem(onPressed: () => presses++, focusNode: focus, child: const Text('Open')),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Open'),
        matchesSemantics(
          label: 'Open',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      await tester.tap(find.text('Open'));
      expect(presses, 1);

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 3);

      semantics.dispose();
    });

    testWidgets('is a link to a safe address with an href, and Space leaves it alone', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final FocusNode focus = FocusNode();
      addTearDown(focus.dispose);
      int presses = 0;

      await pump(
        tester,
        NebaList(
          children: <Widget>[
            NebaListItem(
              onPressed: () => presses++,
              href: Uri.parse('/settings'),
              focusNode: focus,
              child: const Text('Settings'),
            ),
            NebaListItem(
              onPressed: noop,
              href: Uri.parse('javascript:alert(1)'),
              child: const Text('Unsafe'),
            ),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Settings'),
        matchesSemantics(
          label: 'Settings',
          isLink: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(nodeOf(tester, 'Settings').getSemanticsData().linkUrl, Uri.parse('/settings'));
      expect(nodeOf(tester, 'Unsafe').getSemanticsData().linkUrl, isNull);
      // An address that is not written leaves a button behind.
      expect(
        nodeOf(tester, 'Unsafe'),
        matchesSemantics(
          label: 'Unsafe',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(presses, 1);

      semantics.dispose();
    });

    testWidgets('stays inert when disabled, even with onPressed', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int presses = 0;

      await pump(
        tester,
        NebaList(
          children: <Widget>[
            NebaListItem(disabled: true, onPressed: () => presses++, child: const Text('Off')),
          ],
        ),
      );

      await tester.tap(find.text('Off'));
      expect(presses, 0);
      expect(
        nodeOf(tester, 'Off'),
        matchesSemantics(label: 'Off', hasEnabledState: true, isEnabled: false),
      );
      expect(styleOf(tester, 'Off').color, tokens.disabledFg);

      semantics.dispose();
    });

    testWidgets('keeps the action out of the pressable area', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int rows = 0;
      int actions = 0;

      await pump(
        tester,
        NebaList(
          children: <Widget>[
            NebaListItem(
              onPressed: () => rows++,
              action: GestureDetector(onTap: () => actions++, child: const Text('Toggle')),
              child: const Text('Row'),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Toggle'));
      expect(actions, 1);
      expect(rows, 0);

      // The action is beside the row's button, not inside it.
      expect(nodeOf(tester, 'Row').label, 'Row');
      expect(
        tester.getRect(find.text('Toggle')).left,
        greaterThan(tester.getRect(find.byType(NebaFocusRing)).right),
      );

      semantics.dispose();
    });
  });

  group('selection', () {
    testWidgets('tells a screen reader which row is the chosen one, pressable or not', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaList(
          children: <Widget>[
            NebaListItem(onPressed: noop, selected: true, child: const Text('Button')),
            NebaListItem(
              onPressed: noop,
              href: Uri.parse('#a'),
              selected: true,
              child: const Text('Link'),
            ),
            const NebaListItem(selected: true, child: Text('Inert')),
            const NebaListItem(child: Text('Other')),
          ],
        ),
      );

      expect(
        nodeOf(tester, 'Button'),
        matchesSemantics(
          label: 'Button',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(
        nodeOf(tester, 'Link'),
        matchesSemantics(
          label: 'Link',
          isLink: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(
        nodeOf(tester, 'Inert'),
        matchesSemantics(label: 'Inert', hasSelectedState: true, isSelected: true),
      );
      // A row nobody chose says nothing about being chosen.
      expect(nodeOf(tester, 'Other'), matchesSemantics(label: 'Other'));

      semantics.dispose();
    });

    testWidgets('deepens the tint and the weight when selected', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[
            NebaListItem(selected: true, child: Text('Chosen')),
            NebaListItem(child: Text('Other')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tintOf(tester, 'Chosen').color, primary.softPress);
      expect(styleOf(tester, 'Chosen').color, primary.onTint);
      expect(styleOf(tester, 'Chosen').fontWeight, FontWeight.w500);
      expect(tintOf(tester, 'Other').color, const Color(0x00000000));
      expect(styleOf(tester, 'Other').color, tokens.fg);
    });

    testWidgets('gives a selected row’s description the row ink, and the rest grey', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[
            NebaListItem(selected: true, description: Text('one'), child: Text('Chosen')),
            NebaListItem(description: Text('two'), child: Text('Other')),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(styleOf(tester, 'one').color, primary.onTint);
      expect(styleOf(tester, 'two').color, tokens.mutedFg);
    });

    testWidgets('tints a pressable row under the pointer, one step below the chosen one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[NebaListItem(onPressed: noop, child: Text('Hover'))],
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Hover')));
      await tester.pumpAndSettle();

      expect(tintOf(tester, 'Hover').color, primary.soft);
    });
  });

  group('what the row takes from the list', () {
    testWidgets('takes its size from the list', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaList(
          size: NebaSize.xl,
          children: <Widget>[NebaListItem(child: Text('Big'))],
        ),
      );

      expect(styleOf(tester, 'Big').fontSize, NebaScale.sheetBodyText[NebaSize.xl]);
    });

    testWidgets('takes its padding from the list’s density', (WidgetTester tester) async {
      Future<double> inset(NebaDensity density) async {
        await pump(
          tester,
          NebaList(
            variant: NebaVariant.text,
            density: density,
            children: const <Widget>[NebaListItem(child: Text('Row'))],
          ),
        );

        return tester.getRect(find.text('Row')).left -
            tester.getRect(find.byType(NebaListItem)).left;
      }

      expect(
        await inset(NebaDensity.standard),
        NebaBox.padding[NebaDensity.standard]![NebaSize.md],
      );
      expect(await inset(NebaDensity.compact), NebaBox.padding[NebaDensity.compact]![NebaSize.md]);
    });

    testWidgets('squares the rows off and rules between them when the list is ruled', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          dividers: true,
          children: <Widget>[
            NebaListItem(selected: true, child: Text('One')),
            NebaListItem(child: Text('Two')),
            NebaListItem(child: Text('Three')),
          ],
        ),
      );

      expect(tintOf(tester, 'One').borderRadius, BorderRadius.zero);

      final List<Border> rules = tester
          .widgetList<Container>(find.byType(Container))
          .map((Container box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((BoxDecoration decoration) => decoration.border)
          .whereType<Border>()
          .where((Border border) => border.top.style != BorderStyle.none)
          .toList();
      expect(rules, hasLength(2));
      expect(rules.first.top.color, primary.line);

      // No inner padding: the first row starts at the sheet's hairline.
      expect(
        tester.getRect(find.byType(NebaListItem).first).top -
            tester.getRect(find.byType(NebaSheet)).top,
        1,
      );
    });

    testWidgets('rounds the rows a step below the sheet when they are tiles', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(children: <Widget>[NebaListItem(selected: true, child: Text('One'))]),
      );

      expect(
        tintOf(tester, 'One').borderRadius,
        BorderRadius.circular(tokens.radius[NebaSize.sm]!),
      );
      expect(
        tester.getRect(find.byType(NebaListItem)).top - tester.getRect(find.byType(NebaSheet)).top,
        1 + NebaList.inset,
      );
    });
  });

  group('style', () {
    testWidgets('is an undyed outline sheet with an edge in the family by default', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          color: NebaColor.success,
          children: <Widget>[NebaListItem(child: Text('Row'))],
        ),
      );

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(sheet.fill, tokens.panel);
      expect(sheet.edge, tokens.roles(NebaColor.success).line);
      expect(sheet.elevation, 0);
    });

    testWidgets('lifts the sheet by its elevation', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaList(
          variant: NebaVariant.solid,
          elevation: 2,
          children: <Widget>[NebaListItem(child: Text('Row'))],
        ),
      );

      final NebaSheet sheet = tester.widget<NebaSheet>(find.byType(NebaSheet));
      expect(sheet.fill, tokens.panelHover);
      expect(sheet.elevation, 2);
    });

    testWidgets('lets the rows touch until spacing stands them apart, ruled or not', (
      WidgetTester tester,
    ) async {
      Future<double> gap({double? spacing, bool dividers = false}) async {
        await pump(
          tester,
          NebaList(
            spacing: spacing,
            dividers: dividers,
            children: const <Widget>[
              NebaListItem(child: Text('One')),
              NebaListItem(child: Text('Two')),
            ],
          ),
        );

        final Finder rows = find.byType(NebaListItem);

        return tester.getRect(rows.last).top - tester.getRect(rows.first).bottom;
      }

      expect(await gap(), 0);
      expect(await gap(spacing: 1), 4);
      // Ruled, the one pixel between the rows is the rule.
      expect(await gap(spacing: 1, dividers: true), 1);
    });

    testWidgets('rings a pressable row outside its tile, and inside its edge when ruled', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[NebaListItem(onPressed: noop, child: Text('Row'))],
        ),
      );
      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).offset, focusRingOffset);

      await pump(
        tester,
        const NebaList(
          dividers: true,
          children: <Widget>[NebaListItem(onPressed: noop, child: Text('Row'))],
        ),
      );
      expect(tester.widget<NebaFocusRing>(find.byType(NebaFocusRing)).offset, -focusRingWidth);
    });

    testWidgets('never applies a transform', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaList(
          children: <Widget>[NebaListItem(onPressed: noop, selected: true, child: Text('Row'))],
        ),
      );
      await tester.press(find.text('Row'));
      await tester.pump();

      expect(
        find.descendant(of: find.byType(NebaList), matching: find.byType(Transform)),
        findsNothing,
      );
    });

    testWidgets('lays out in a dark theme and right to left', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: SizedBox(
              width: 320,
              child: NebaList(
                children: <Widget>[
                  NebaListItem(startIcon: SizedBox.square(dimension: 8), child: Text('Row')),
                ],
              ),
            ),
          ),
          brightness: Brightness.dark,
          textDirection: TextDirection.rtl,
        ),
      );

      final Rect icon = tester.getRect(find.byType(SizedBox).last);
      expect(icon.left, greaterThan(tester.getRect(find.text('Row')).right));
      expect(styleOf(tester, 'Row').color, NebaTokens.dark().fg);
    });
  });
}
