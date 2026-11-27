// NebaPieChart: the React package's PieChart suite, asked the way Flutter asks
// it — the slices and labels the painter is handed instead of SVG paths and
// `<text>`, the table the frame builds instead of the DOM's, and semantics
// instead of `role="img"`.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/live_region.dart';

import '../../support/host.dart';

const List<Object> _plans = <Object>['Free', 'Pro', 'Team'];

Finder _marks() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_PiePainter',
  );
}

/// Every slice the painter is handed, as its place in `data`, its outline and
/// its colour.
List<({int index, Path path, Color color})> _slices(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_marks()).painter;

  return <({int index, Path path, Color color})>[
    for (final dynamic slice in painter.slices as List<dynamic>)
      (index: slice.index as int, path: slice.path as Path, color: slice.color as Color),
  ];
}

List<NebaChartLabel> _labels(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_marks()).painter;

  return <NebaChartLabel>[...painter.labels as List<NebaChartLabel>];
}

NebaChartEmphasis _emphasis(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_marks()).painter;

  return painter.emphasis as NebaChartEmphasis;
}

/// The middle of the plot, where the pie's centre is unless it is a semi.
Offset _middle(WidgetTester tester) =>
    tester.getSize(find.byType(NebaChartBox)).center(Offset.zero);

String _readout(WidgetTester tester) {
  return tester
          .widget<Text>(
            find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(Text)),
          )
          .data ??
      '';
}

FocusNode _focusOf(WidgetTester tester) {
  return tester
      .widget<Focus>(
        find.ancestor(of: find.byType(NebaChartBox), matching: find.byType(Focus)).first,
      )
      .focusNode!;
}

void main() {
  Future<void> pump(WidgetTester tester, Widget chart) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 320, child: chart))));
  }

  group('rendering', () {
    testWidgets('draws one slice per value', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts by plan', categories: _plans, data: <num>[50, 30, 20]),
      );

      expect(
        _slices(tester).map((({int index, Path path, Color color}) slice) => slice.index),
        <int>[0, 1, 2],
      );
    });

    testWidgets('leaves out a slice with no value', (WidgetTester tester) async {
      await pump(tester, const NebaPieChart(categories: _plans, data: <num?>[50, null, 20]));

      expect(_slices(tester), hasLength(2));
    });

    testWidgets('draws no slice for a negative value and keeps it in the table', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaPieChart(categories: _plans, data: <num>[50, -20, 30]));

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(_slices(tester), hasLength(2));
      expect(table.rows[1], <String>['Pro', '-20']);
    });

    testWidgets('names every slice in its table', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts by plan', categories: _plans, data: <num>[50, 30, 20]),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.caption, 'Accounts by plan');
      expect(table.columns, <String>['', 'Accounts by plan']);
      expect(table.rows, <List<String>>[
        <String>['Free', '50'],
        <String>['Pro', '30'],
        <String>['Team', '20'],
      ]);
    });

    testWidgets("takes a slice's name off its own point", (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          data: <Object>[
            NebaChartPoint(x: 'Passed', y: 90),
            NebaChartPoint(x: 'Failed', y: 10),
          ],
        ),
      );

      expect(
        find.descendant(of: find.byType(NebaChartLegendBar), matching: find.text('Passed')),
        findsOneWidget,
      );
    });

    testWidgets('colours a slice by its place in data, or by its own colour', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      await pump(
        tester,
        const NebaPieChart(
          data: <Object>[
            NebaChartPoint(x: 'Passed', y: 90, color: NebaColor.success),
            NebaChartPoint(x: 'Other', y: 10),
          ],
        ),
      );

      expect(_slices(tester)[0].color, tokens.roles(NebaColor.success).accent);
      expect(_slices(tester)[1].color, tokens.chart.series[1]);
    });

    testWidgets('shows the empty state when everything is zero', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          categories: _plans,
          data: <num>[0, 0, 0],
          empty: Text('Nothing to show'),
        ),
      );

      expect(find.text('Nothing to show'), findsOneWidget);
      expect(find.byType(NebaChartDataTable), findsNothing);
    });

    testWidgets('reflects changed data on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaPieChart(categories: _plans, data: <num>[50, 30, 20]));
      await pump(tester, const NebaPieChart(categories: _plans, data: <num>[50, 50]));

      expect(_slices(tester), hasLength(2));
    });
  });

  group('accessibility', () {
    testWidgets('names itself when no label was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaPieChart(categories: _plans, data: <num>[50, 30, 20]));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('is an image described by the slice count and range rather than by its table', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Accounts').first),
        matchesSemantics(
          label: 'Accounts',
          hint: 'Data points: 3. Range: 20 to 50.',
          isImage: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('keeps the readout outside the picture', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      expect(find.byType(NebaLiveRegion), findsOneWidget);
      expect(
        find.descendant(of: find.byType(NebaChartPlot), matching: find.byType(NebaLiveRegion)),
        findsNothing,
      );
    });

    testWidgets('steps with the arrows, jumps to the ends with Home and End and lets go with '
        'Escape', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      _focusOf(tester).requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_readout(tester), 'Team, Team: 20 · 20%');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_readout(tester), startsWith('Free'));

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(_readout(tester), startsWith('Free'));
      expect(
        tester.widget<NebaChartTooltipPanel>(find.byType(NebaChartTooltipPanel)).heading,
        'Free',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(_readout(tester), isEmpty);
      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });

    testWidgets('leaves the slices alone under the arrow keys when the tooltip is off', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPieChart(
          label: 'Accounts',
          categories: _plans,
          data: <num>[50, 30, 20],
          tooltip: false,
        ),
      );

      _focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      for (int index = 0; index < 3; index++) {
        expect(_emphasis(tester).opacityOf(index), 1);
      }

      expect(find.byType(NebaLiveRegion), findsNothing);
    });

    testWidgets('fades the slices not being read', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      _focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(_emphasis(tester).opacityOf(0), 1);
      expect(_emphasis(tester).opacityOf(1), closeTo(0.32, 1e-9));
    });

    testWidgets('reads the slice under the pointer, and lets go when it leaves', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final Rect box = tester.getRect(find.byType(NebaChartBox));

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      // A quarter of the way round, inside the first half of the circle.
      await mouse.moveTo(box.center + const Offset(40, 0));
      await tester.pump();
      expect(_readout(tester), 'Free, Free: 50 · 50%');

      // Straight down from the centre is a third of the way into Pro's 108°.
      await mouse.moveTo(box.center + const Offset(-20, 40));
      await tester.pump();
      expect(_readout(tester), startsWith('Pro'));

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(_readout(tester), isEmpty);
    });

    testWidgets('keeps a tapped slice until a press lands elsewhere', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: <Widget>[
              const SizedBox(
                width: 320,
                child: NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
              ),
              const SizedBox(height: 40, width: 40, child: Text('Elsewhere')),
            ],
          ),
        ),
      );

      await tester.tapAt(tester.getRect(find.byType(NebaChartBox)).center + const Offset(40, 0));
      await tester.pump();

      expect(_readout(tester), startsWith('Free'));

      await tester.tap(find.text('Elsewhere'));
      await tester.pump();

      expect(_readout(tester), isEmpty);
    });
  });

  group('shape', () {
    testWidgets('cuts a hole for a donut and none for a pie', (WidgetTester tester) async {
      await pump(tester, const NebaPieChart(categories: _plans, data: <num>[50, 30, 20]));

      // A pie's slice runs in to the centre; a donut's stops at the hole.
      expect(_slices(tester).first.path.contains(_middle(tester) + const Offset(1, -1)), isTrue);

      await pump(
        tester,
        const NebaPieChart(shape: NebaPieShape.donut, categories: _plans, data: <num>[50, 30, 20]),
      );

      expect(_slices(tester).first.path.contains(_middle(tester) + const Offset(1, -1)), isFalse);
    });

    testWidgets('draws a semicircle rather than a full one', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          shape: NebaPieShape.semi,
          data: <Object>[NebaChartPoint(x: 'All', y: 100)],
        ),
      );

      final Rect bounds = _slices(tester).single.path.getBounds();
      final Size box = tester.getSize(find.byType(NebaChartBox));

      // Twice as wide as it is tall, as wide as the box lets it be, and with
      // its flat edge half a radius below the middle of the box, which puts
      // the arc itself in the middle.
      expect(bounds.width / bounds.height, closeTo(2, 0.01));
      expect(bounds.width, closeTo(box.width - 4, 0.5));
      expect(bounds.bottom, closeTo(box.height / 2 + bounds.height / 2, 0.5));
    });
  });

  group('hole and gap', () {
    testWidgets('opens a hole in a pie, and widens the one a donut has', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPieChart(hole: 0.4, categories: _plans, data: <num>[50, 30, 20]),
      );

      final Offset middle = _middle(tester);
      final double outer = _slices(tester).first.path.getBounds().right - middle.dx;

      expect(_slices(tester).first.path.contains(middle + Offset(outer * 0.3, 0)), isFalse);
      expect(_slices(tester).first.path.contains(middle + Offset(outer * 0.5, 0)), isTrue);

      await pump(
        tester,
        const NebaPieChart(hole: 0.8, categories: _plans, data: <num>[50, 30, 20]),
      );

      expect(_slices(tester).first.path.contains(middle + Offset(outer * 0.5, 0)), isFalse);
    });

    testWidgets('is clamped rather than inverted by a hole of 1', (WidgetTester tester) async {
      await pump(tester, const NebaPieChart(hole: 1, categories: _plans, data: <num>[50, 30, 20]));

      final Offset middle = _middle(tester);
      final double outer = _slices(tester).first.path.getBounds().right - middle.dx;

      expect(_slices(tester).first.path.contains(middle + Offset(outer * 0.96, 0)), isTrue);
      expect(_slices(tester).first.path.contains(middle + Offset(outer * 0.9, 0)), isFalse);
    });

    testWidgets('draws a slice that is alone as a whole disc', (WidgetTester tester) async {
      await pump(tester, const NebaPieChart(categories: _plans, data: <num?>[50, null, 0]));

      final Path whole = _slices(tester).single.path;
      final Offset middle = _middle(tester);

      // No notch cut into it where it starts.
      for (final Offset at in <Offset>[
        const Offset(0, -60),
        const Offset(1, -60),
        const Offset(60, 0),
        const Offset(0, 60),
        const Offset(-60, 0),
      ]) {
        expect(whole.contains(middle + at), isTrue);
      }
    });

    testWidgets('parts the slices further, and closes the gap at zero', (
      WidgetTester tester,
    ) async {
      // Just clockwise of twelve o'clock, where the first slice starts.
      Future<bool> startsAtTwelve(double gap) async {
        await pump(
          tester,
          NebaPieChart(gap: gap, categories: _plans, data: const <num>[50, 30, 20]),
        );

        return _slices(tester).first.path.contains(_middle(tester) + const Offset(2, -80));
      }

      expect(await startsAtTwelve(0), isTrue);
      expect(await startsAtTwelve(2), isTrue);
      expect(await startsAtTwelve(10), isFalse);
    });
  });

  group('legend', () {
    testWidgets('hides a slice when its entry is pressed, and the rest fill the circle', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaPieChart(label: 'Accounts', categories: _plans, data: <num>[50, 30, 20]),
      );

      await tester.tap(
        find.descendant(of: find.byType(NebaChartLegendBar), matching: find.text('Pro')),
      );
      await tester.pump();

      expect(
        _slices(tester).map((({int index, Path path, Color color}) slice) => slice.index),
        <int>[0, 2],
      );
      // The colours stay with the slices.
      expect(_slices(tester).last.color, NebaTokens.light().chart.series[2]);
    });

    testWidgets('writes each value beside its name under showValue', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          categories: _plans,
          data: <num>[50, 30, 20],
          legend: NebaChartLegend(showValue: true),
        ),
      );

      expect(tester.widget<NebaChartLegendBar>(find.byType(NebaChartLegendBar)).values, <String?>[
        '50',
        '30',
        '20',
      ]);
    });
  });

  group('valueLabels', () {
    testWidgets("writes each slice's share on it", (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          valueLabels: NebaChartValueLabels.all,
          size: NebaSize.xl,
          categories: <Object>['Half', 'Quarter', 'Quarter again'],
          data: <num>[50, 25, 25],
        ),
      );

      expect(
        <String>[for (final NebaChartLabel label in _labels(tester)) label.painter.plainText],
        <String>['50%', '25%', '25%'],
      );
    });

    testWidgets('writes each share in the ink its slice reads best under', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      await pump(
        tester,
        const NebaPieChart(
          valueLabels: NebaChartValueLabels.all,
          size: NebaSize.xl,
          categories: <Object>['Slot', 'Yellow', 'Navy'],
          data: <Object>[
            50,
            NebaChartPoint(y: 25, color: Color(0xFFFFE066)),
            NebaChartPoint(y: 25, color: Color(0xFF1E2A5A)),
          ],
        ),
      );

      expect(
        <Color?>[
          for (final NebaChartLabel label in _labels(tester)) label.painter.text!.style!.color,
        ],
        <Color?>[
          tokens.ink(tokens.chart.seriesInk[0]),
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
        ],
      );
    });

    testWidgets('drops a label that does not fit its slice', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaPieChart(
          valueLabels: NebaChartValueLabels.all,
          size: NebaSize.xs,
          height: 120,
          categories: <Object>['Most', 'Sliver'],
          data: <num>[99, 1],
        ),
      );

      expect(
        <String>[for (final NebaChartLabel label in _labels(tester)) label.painter.plainText],
        <String>['99%'],
      );
    });
  });

  testWidgets('puts its center in the hole', (WidgetTester tester) async {
    await pump(
      tester,
      const NebaPieChart(
        shape: NebaPieShape.donut,
        categories: _plans,
        data: <num>[50, 30, 20],
        center: Text('100'),
      ),
    );

    final Rect box = tester.getRect(find.byType(NebaChartBox));

    expect(tester.getCenter(find.text('100')), box.center);
  });
}
