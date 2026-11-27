// NebaDataList and NebaDataListItem: the suite the React package runs on
// DataList, asked the way Flutter asks it — what a screen reader hears for a
// pair, where each label and value lands, and the lines drawn between them —
// rather than the `<dl>`, `<dt>` and `<dd>` it writes.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';

import '../../support/host.dart';

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

  Future<void> pump(
    WidgetTester tester,
    Widget list, {
    double width = 360,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: list),
        ),
        textDirection: textDirection,
      ),
    );
  }

  Rect rectOf(WidgetTester tester, String text) => tester.getRect(find.text(text));

  TextStyle styleOf(WidgetTester tester, String text) {
    return tester
        .widget<RichText>(find.descendant(of: find.text(text), matching: find.byType(RichText)))
        .text
        .style!;
  }

  List<Border> rulesOf(WidgetTester tester) {
    return tester
        .widgetList<Container>(
          find.descendant(of: find.byType(NebaDataList), matching: find.byType(Container)),
        )
        .map((Container box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((BoxDecoration decoration) => decoration.border)
        .whereType<Border>()
        .where((Border border) => border.top.style != BorderStyle.none)
        .toList();
  }

  const List<Widget> plan = <Widget>[
    NebaDataListItem(label: Text('Plan'), child: Text('Team')),
    NebaDataListItem(label: Text('Seats'), child: Text('12 of 20')),
    NebaDataListItem(label: Text('Renews'), child: Text('1 April 2026')),
  ];

  group('rendering', () {
    testWidgets('reads each pair as one item, its label and then its value', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      for (final NebaOrientation orientation in NebaOrientation.values) {
        await pump(tester, NebaDataList(orientation: orientation, children: plan));

        expect(tester.getSemantics(find.text('Plan')), matchesSemantics(label: 'Plan\nTeam'));
        expect(
          tester.getSemantics(find.text('12 of 20')),
          matchesSemantics(label: 'Seats\n12 of 20'),
        );
      }

      semantics.dispose();
    });

    testWidgets('sets the label muted a step down, and the value in the control type', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataList(children: plan));

      expect(styleOf(tester, 'Plan').fontSize, NebaScale.metaText[NebaSize.md]);
      expect(styleOf(tester, 'Plan').color, tokens.mutedFg);
      expect(styleOf(tester, 'Team').fontSize, NebaScale.controlText[NebaSize.md]);
      expect(styleOf(tester, 'Team').color, tokens.fg);

      await pump(tester, const NebaDataList(size: NebaSize.xl, children: plan));
      expect(styleOf(tester, 'Plan').fontSize, NebaScale.metaText[NebaSize.xl]);
      expect(styleOf(tester, 'Team').fontSize, NebaScale.controlText[NebaSize.xl]);
    });

    testWidgets('takes a widget as the value, which keeps its own semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        NebaDataList(
          children: <Widget>[
            NebaDataListItem(
              label: const Text('Commit'),
              child: NebaTextLink(onPressed: () {}, child: const Text('8f2c1a')),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(find.text('Commit')).label, 'Commit');
      expect(
        tester.getSemantics(find.byType(NebaTextLink)),
        matchesSemantics(
          label: '8f2c1a',
          isLink: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      // A value narrower than its column keeps its own width.
      expect(
        tester.getSize(find.byType(NebaTextLink)).width,
        lessThan(tester.getSize(find.byType(NebaDataList)).width / 2),
      );

      semantics.dispose();
    });

    testWidgets('reflects a changed value on rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDataList(
          children: <Widget>[NebaDataListItem(label: Text('A'), child: Text('1'))],
        ),
      );
      await pump(
        tester,
        const NebaDataList(
          children: <Widget>[NebaDataListItem(label: Text('A'), child: Text('2'))],
        ),
      );

      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('keeps a pair\u2019s state when another is put in front of it', (
      WidgetTester tester,
    ) async {
      probeStarts = 0;

      await pump(
        tester,
        const NebaDataList(
          dividers: true,
          children: <Widget>[
            NebaDataListItem(key: ValueKey<String>('b'), label: Text('B'), child: _Probe()),
          ],
        ),
      );
      await pump(
        tester,
        NebaDataList(
          dividers: true,
          children: const <Widget>[
            NebaDataListItem(key: ValueKey<String>('a'), label: Text('A'), child: _Probe()),
            NebaDataListItem(key: ValueKey<String>('b'), label: Text('B'), child: _Probe()),
          ],
        ),
      );

      expect(probeStarts, 2);
    });
  });

  group('orientation', () {
    testWidgets('lays the labels beside the values, every value starting at one place', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataList(children: plan));

      final double gap = NebaDataList.columnGap[NebaDensity.standard]![NebaSize.md]!;
      final double widest = <String>['Plan', 'Seats', 'Renews']
          .map((String label) => rectOf(tester, label).width)
          .reduce((double a, double b) => a > b ? a : b);

      for (final String value in <String>['Team', '12 of 20', '1 April 2026']) {
        expect(rectOf(tester, value).left, widest + gap);
      }

      // On one baseline: a value 13 pixels tall and a label 12 pixels tall
      // end on the same line.
      double baselineOf(String text) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: text, style: styleOf(tester, text)),
          textDirection: TextDirection.ltr,
        )..layout();
        addTearDown(painter.dispose);

        return rectOf(tester, text).top +
            painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      }

      final double labelBaseline = baselineOf('Plan');
      final double valueBaseline = baselineOf('Team');
      expect(labelBaseline, moreOrLessEquals(valueBaseline, epsilon: 0.01));
    });

    testWidgets('puts the label column on the right under a right-to-left direction', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataList(children: plan), textDirection: TextDirection.rtl);

      expect(rectOf(tester, 'Plan').right, 360);
      expect(rectOf(tester, 'Team').right, lessThan(rectOf(tester, 'Renews').left));
    });

    testWidgets('stacks them when vertical, a label nearer its value than the pair before', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataList(orientation: NebaOrientation.vertical, children: plan));

      final Rect label = rectOf(tester, 'Plan');
      final Rect team = rectOf(tester, 'Team');
      final Rect seats = rectOf(tester, 'Seats');

      expect(team.left, label.left);
      expect(team.top, greaterThan(label.bottom));
      expect(seats.top - team.bottom, greaterThan(team.top - label.bottom));
      expect(seats.top - team.bottom, NebaDataList.rowGap[NebaDensity.standard]![NebaSize.md]);
    });

    testWidgets('rules between stacked pairs and never inside one', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaDataList(orientation: NebaOrientation.vertical, dividers: true, children: plan),
      );

      final List<Border> rules = rulesOf(tester);
      expect(rules, hasLength(2));
      expect(rules.first.top.color, tokens.border);

      // The gap, the hairline, and the same gap again above the label.
      final double gap = NebaDataList.rowGap[NebaDensity.standard]![NebaSize.md]!;
      expect(rectOf(tester, 'Seats').top - rectOf(tester, 'Team').bottom, gap + 1 + gap);
      expect(rectOf(tester, 'Team').top - rectOf(tester, 'Plan').bottom, 2);
    });
  });

  group('appearance', () {
    testWidgets('sizes the label column to the widest label, up to half the list', (
      WidgetTester tester,
    ) async {
      final double gap = NebaDataList.columnGap[NebaDensity.standard]![NebaSize.md]!;

      await pump(
        tester,
        const NebaDataList(
          children: <Widget>[
            NebaDataListItem(
              label: Text('A label long enough to wrap onto a second line'),
              child: Text('value'),
            ),
          ],
        ),
        width: 300,
      );

      expect(rectOf(tester, 'value').left, 150 + gap);
      expect(
        rectOf(tester, 'A label long enough to wrap onto a second line').height,
        greaterThan(NebaScale.controlLeading[NebaSize.md]! + 1),
      );
    });

    testWidgets('takes a label width of its own', (WidgetTester tester) async {
      final double gap = NebaDataList.columnGap[NebaDensity.standard]![NebaSize.md]!;

      await pump(tester, const NebaDataList(labelWidth: 140, children: plan));

      expect(rectOf(tester, 'Team').left, 140 + gap);
    });

    testWidgets('changes only the gaps with density', (WidgetTester tester) async {
      Future<double> rowGap(NebaDensity density) async {
        await pump(tester, NebaDataList(density: density, children: plan));

        return rectOf(tester, '12 of 20').top - rectOf(tester, 'Team').bottom;
      }

      final double standard = await rowGap(NebaDensity.standard);
      final double compact = await rowGap(NebaDensity.compact);

      expect(
        standard - compact,
        NebaDataList.rowGap[NebaDensity.standard]![NebaSize.md]! -
            NebaDataList.rowGap[NebaDensity.compact]![NebaSize.md]!,
      );
      expect(styleOf(tester, 'Team').fontSize, NebaScale.controlText[NebaSize.md]);
    });

    testWidgets('draws no hairlines unless asked, and one over each cell of a later row', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaDataList(children: plan));
      expect(rulesOf(tester), isEmpty);

      await pump(tester, const NebaDataList(dividers: true, children: plan));
      final List<Border> rules = rulesOf(tester);
      expect(rules, hasLength(4));
      expect(rules.every((Border rule) => rule.top.color == tokens.border), isTrue);
    });

    testWidgets('lays a pair out on its own, outside a list', (WidgetTester tester) async {
      await pump(tester, const NebaDataListItem(label: Text('Alone'), child: Text('value')));

      expect(rectOf(tester, 'value').left, greaterThan(rectOf(tester, 'Alone').right));
      expect(tester.takeException(), isNull);
    });
  });
}
