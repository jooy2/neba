// NebaScatterChart: the React package's ScatterChart suite, asked the way
// Flutter asks it — the marks the painter lays out and the paths it draws
// instead of SVG paths and their attributes, the labels and the rules on the
// frame's canvas instead of `<text>` and `<line>`, and the table the chart
// builds instead of the DOM's. The frame's category axis on numbers and its
// nearest-mark search are checked here, since a scatter is the chart that
// needs them.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/live_region.dart';

import '../../support/host.dart';

/// Four points, far enough apart that a hit test cannot be ambiguous.
const List<NebaChartPoint> _cloud = <NebaChartPoint>[
  NebaChartPoint(x: 10, y: 10),
  NebaChartPoint(x: 20, y: 40),
  NebaChartPoint(x: 30, y: 20),
  NebaChartPoint(x: 40, y: 50),
];

const List<NebaChartPoint> _bubbles = <NebaChartPoint>[
  NebaChartPoint(x: 10, y: 10, z: 4),
  NebaChartPoint(x: 20, y: 40, z: 16),
  NebaChartPoint(x: 30, y: 20, z: 64),
];

Finder _painted() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_ScatterPainter',
  );
}

NebaChartMarks<Object?> _marksOf(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_painted()).painter;

  return painter.marks as NebaChartMarks<Object?>;
}

/// Every mark, in the order the data was given.
List<NebaChartMark> _marks(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;

  return (traced.marks as List<dynamic>).cast<NebaChartMark>();
}

/// The radius of every mark, in the order it is painted.
List<double> _paintedRadii(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;
  final List<NebaChartMark> marks = _marks(tester);

  return <double>[for (final dynamic at in traced.order as List<dynamic>) marks[at as int].r];
}

/// The shape and the fill of every mark, in the order the data was given.
List<({NebaMarkShape shape, Color color})> _dots(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;

  return <({NebaMarkShape shape, Color color})>[
    for (final dynamic dot in traced.dots as List<dynamic>)
      (shape: dot.shape as NebaMarkShape, color: dot.color as Color),
  ];
}

/// What the frame painted around the marks: its labels and its rules.
List<Object> _chrome(WidgetTester tester) {
  final RenderObject chrome = tester.renderObject(
    find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)).first,
  );
  final dynamic painter = (chrome as RenderCustomPaint).painter;

  return (painter.model.chrome as List<dynamic>).cast<Object>();
}

List<String> _chromeTexts(WidgetTester tester) {
  return <String>[
    for (final Object op in _chrome(tester))
      if (op is NebaChartLabel) op.painter.plainText,
  ];
}

/// The rules the frame drew across the plot, as `(from, to)`.
List<(Offset, Offset)> _rules(WidgetTester tester) {
  return <(Offset, Offset)>[
    for (final dynamic op in _chrome(tester))
      if (op.runtimeType.toString() == '_Rule') (op.from as Offset, op.to as Offset),
  ];
}

String _readout(WidgetTester tester) {
  return tester
          .widget<Text>(
            find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(Text)),
          )
          .data ??
      '';
}

Finder _entry(String name) {
  return find.descendant(of: find.byType(NebaChartLegendBar), matching: find.text(name));
}

void main() {
  Future<void> pump(WidgetTester tester, Widget chart, {bool reduced = true}) {
    return tester.pumpWidget(
      host(
        Center(child: SizedBox(width: 480, child: chart)),
        disableAnimations: reduced,
      ),
    );
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    return gesture;
  }

  /// Where [local], a point in the chart's own pixels, is on the screen.
  Offset onScreen(WidgetTester tester, Offset local) {
    return tester.getTopLeft(find.byType(NebaChartBox)) + local;
  }

  FocusNode focusOf(WidgetTester tester) {
    return tester
        .widget<Focus>(
          find.ancestor(of: find.byType(NebaChartBox), matching: find.byType(Focus)).first,
        )
        .focusNode!;
  }

  group('rendering', () {
    testWidgets('exposes the plot as an image with its label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaScatterChart(
          label: 'Spend against revenue',
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Spend against revenue').first),
        matchesSemantics(
          label: 'Spend against revenue',
          hint: 'Data points: 4. Range: 10 to 50.',
          isImage: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('draws one mark per point, for every series', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_marks(tester), hasLength(4));

      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: _cloud),
            NebaChartSeries(name: 'Q2', data: _bubbles),
          ],
        ),
      );

      expect(_marks(tester), hasLength(7));
    });

    testWidgets('fills a mark in its series’ colour, or in a colour of its own', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      await pump(
        tester,
        NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'A',
              data: <NebaChartPoint>[
                _cloud[0],
                const NebaChartPoint(x: 20, y: 40, color: NebaColor.danger),
              ],
            ),
            const NebaChartSeries(name: 'B', data: <NebaChartPoint>[NebaChartPoint(x: 30, y: 20)]),
          ],
        ),
      );

      final List<Color> colors = <Color>[
        for (final ({NebaMarkShape shape, Color color}) dot in _dots(tester)) dot.color,
      ];

      expect(colors, <Color>[
        tokens.chart.series[0],
        tokens.roles(NebaColor.danger).accent,
        tokens.chart.series[1],
      ]);
    });

    testWidgets('draws no mark for a gap', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Q1',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 1, y: 1),
                NebaChartPoint(x: 2, y: null),
                NebaChartPoint(x: 3, y: 3),
              ],
            ),
          ],
        ),
      );

      expect(_marks(tester).map((NebaChartMark mark) => mark.index), <int>[0, 2]);
    });

    testWidgets('reflects a changed series on rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(find.text('50'), findsWidgets);

      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Q1',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 10, y: 10),
                NebaChartPoint(x: 20, y: 40),
                NebaChartPoint(x: 30, y: 20),
                NebaChartPoint(x: 40, y: 99),
              ],
            ),
          ],
        ),
      );

      expect(find.text('99'), findsWidgets);
    });

    testWidgets('shows the empty state rather than an axis when there is nothing to draw', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(series: <NebaChartSeries>[], empty: Text('No data yet')),
      );

      expect(find.text('No data yet'), findsOneWidget);
      expect(find.byType(NebaChartDataTable), findsNothing);
    });

    testWidgets('shows the empty state when x is not a number', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          empty: Text('No data yet'),
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Q1',
              data: <NebaChartPoint>[NebaChartPoint(x: 'Seoul', y: 10)],
            ),
          ],
        ),
      );

      expect(find.text('No data yet'), findsOneWidget);
      expect(_painted(), findsNothing);
    });
  });

  group('the value x axis', () {
    testWidgets('ticks at numbers rather than at the points', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(min: 0, max: 100, tickCount: 4),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_chromeTexts(tester), containsAll(<String>['0', '100']));
      expect(_marksOf(tester).layout.categoryScale?.ticks, <double>[0, 25, 50, 75, 100]);
    });

    testWidgets('writes each x tick through the axis tickFormat', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScatterChart(
          xAxis: NebaChartAxis(
            min: 2000,
            max: 2020,
            tickCount: 2,
            tickFormat: (Object value, int index) => 'Y$value',
          ),
          series: const <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_chromeTexts(tester), containsAll(<String>['Y2000', 'Y2020']));
    });

    testWidgets('does not drag the scale down to zero', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      // The data runs 10 to 40 on x and 10 to 50 on y: a scale forced
      // through zero would show it as a `0` on either axis.
      expect(_chromeTexts(tester), isNot(contains('0')));
    });

    testWidgets('places a mark by its own x rather than by its index', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          height: 200,
          yAxis: NebaChartAxis(hidden: true),
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Q1',
              data: <NebaChartPoint>[NebaChartPoint(x: 0, y: 5), NebaChartPoint(x: 100, y: 5)],
            ),
          ],
        ),
      );

      final List<NebaChartMark> marks = _marks(tester);
      final NebaChartLayout layout = _marksOf(tester).layout;

      expect(marks[1].centre.dx, greaterThan(marks[0].centre.dx));
      expect(marks[1].centre.dy, closeTo(marks[0].centre.dy, 1e-9));
      expect(marks[0].centre.dx, closeTo(layout.categoryValuePx(0), 1e-9));
    });

    testWidgets('keeps the biggest bubble clear of every edge of the box', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          maxRadius: 30,
          xAxis: NebaChartAxis(hidden: true),
          yAxis: NebaChartAxis(hidden: true),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _bubbles)],
        ),
      );

      final Rect plot = _marksOf(tester).layout.plot;
      final Size box = tester.getSize(find.byType(NebaChartBox));

      expect(plot.left, greaterThanOrEqualTo(30));
      expect(plot.top, greaterThanOrEqualTo(30));
      expect(box.width - plot.right, greaterThanOrEqualTo(30));
      expect(box.height - plot.bottom, greaterThanOrEqualTo(30));
    });

    testWidgets('casts a grid in both directions, and drops the x grid when told', (
      WidgetTester tester,
    ) async {
      bool upright((Offset, Offset) rule) => rule.$1.dx == rule.$2.dx;
      bool level((Offset, Offset) rule) => rule.$1.dy == rule.$2.dy;

      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(tickCount: 2),
          yAxis: NebaChartAxis(tickCount: 2),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_rules(tester).where(upright), isNotEmpty);
      expect(_rules(tester).where(level), isNotEmpty);

      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(grid: false),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_rules(tester).where(upright), isEmpty);
    });

    testWidgets('sets the two end labels inward rather than past the plot', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(min: 0, max: 100, tickCount: 4),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      final List<NebaChartLabel> labels = <NebaChartLabel>[
        for (final Object op in _chrome(tester))
          if (op is NebaChartLabel && <String>['0', '100'].contains(op.painter.plainText)) op,
      ];

      // The `0` and `100` of the x axis, which hang inward off their ticks.
      expect(labels.map((NebaChartLabel label) => label.anchor), containsAll(<int>[1, -1]));
    });

    testWidgets('draws a reference on the x axis at its number', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(min: 0, max: 100, grid: false),
          references: <NebaChartReference>[
            NebaChartReference(value: 25, axis: NebaChartReferenceAxis.category),
          ],
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      final NebaChartLayout layout = _marksOf(tester).layout;
      final Iterable<(Offset, Offset)> upright = _rules(
        tester,
      ).where(((Offset, Offset) rule) => rule.$1.dx == rule.$2.dx);

      expect(upright.map(((Offset, Offset) rule) => rule.$1.dx), <double>[
        layout.categoryValuePx(25),
      ]);
    });
  });

  group('bubbles', () {
    testWidgets('scales a radius by the square root of z, not by z', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          maxRadius: 40,
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _bubbles)],
        ),
      );

      // z of 4, 16 and 64 is a sixteenfold range, which as an area is a
      // fourfold range of radius.
      expect(_marks(tester).map((NebaChartMark mark) => mark.r), <double>[10, 20, 40]);
    });

    testWidgets('paints the largest first, so a nested bubble stays visible', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          maxRadius: 40,
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _bubbles)],
        ),
      );

      expect(_paintedRadii(tester), <double>[40, 20, 10]);
    });

    testWidgets('draws a point with no z at the plain radius', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          pointRadius: 7,
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(_marks(tester).map((NebaChartMark mark) => mark.r), <double>[7, 7, 7, 7]);
    });

    testWidgets('keeps the z scale steady when a series is hidden', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          maxRadius: 40,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Small',
              data: <NebaChartPoint>[NebaChartPoint(x: 1, y: 1, z: 4)],
            ),
            NebaChartSeries(
              name: 'Large',
              data: <NebaChartPoint>[NebaChartPoint(x: 2, y: 2, z: 64)],
            ),
          ],
        ),
      );

      expect(_marks(tester).map((NebaChartMark mark) => mark.r), <double>[10, 40]);

      await tester.tap(_entry('Large'));
      await tester.pump();

      // The largest z is gone from the picture and not from the scale.
      expect(_marks(tester).map((NebaChartMark mark) => mark.r), <double>[10]);
    });
  });

  group('shape', () {
    List<NebaMarkShape> shapes(WidgetTester tester) {
      return <NebaMarkShape>[
        for (final ({NebaMarkShape shape, Color color}) dot in _dots(tester)) dot.shape,
      ];
    }

    List<NebaChartSeries> lone(int count, {bool colored = false}) {
      return <NebaChartSeries>[
        for (int index = 0; index < count; index++)
          NebaChartSeries(
            name: 'ABCD'[index],
            color: colored ? NebaColor.values[index] : null,
            data: <NebaChartPoint>[NebaChartPoint(x: index + 1, y: index + 1.0)],
          ),
      ];
    }

    testWidgets('draws circles for three series', (WidgetTester tester) async {
      await pump(tester, NebaScatterChart(series: lone(3)));

      expect(shapes(tester), everyElement(NebaMarkShape.circle));
    });

    testWidgets('varies the shape from the fourth series on', (WidgetTester tester) async {
      await pump(tester, NebaScatterChart(series: lone(4)));

      expect(shapes(tester), <NebaMarkShape>[
        NebaMarkShape.circle,
        NebaMarkShape.square,
        NebaMarkShape.triangle,
        NebaMarkShape.diamond,
      ]);
    });

    testWidgets('leaves them circles when every series brought its own colour', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaScatterChart(series: lone(4, colored: true)));

      expect(shapes(tester), everyElement(NebaMarkShape.circle));
    });

    testWidgets('takes one shape for every mark when it is named', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          shape: NebaScatterShape.square,
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(shapes(tester), everyElement(NebaMarkShape.square));
    });

    testWidgets('gives the legend the same shape as the marks', (WidgetTester tester) async {
      await pump(tester, NebaScatterChart(shape: NebaScatterShape.varied, series: lone(2)));

      final Finder swatches = find.descendant(
        of: find.byType(NebaChartLegendBar),
        matching: find.byWidgetPredicate(
          (Widget widget) => widget.runtimeType.toString() == '_Swatch',
        ),
      );
      final List<NebaMarkShape> drawn = <NebaMarkShape>[
        for (final Widget swatch in tester.widgetList(swatches))
          (swatch as dynamic).shape as NebaMarkShape,
      ];

      expect(drawn, <NebaMarkShape>[NebaMarkShape.circle, NebaMarkShape.square]);
    });
  });

  group('the highlight', () {
    testWidgets('grows the mark under the pointer by a pixel', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'A', data: <NebaChartPoint>[NebaChartPoint(x: 1, y: 1)]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final NebaChartMark mark = _marks(tester).single;

      expect(_marksOf(tester).emphasis.growthOf(0), 0);

      await pointer.moveTo(onScreen(tester, mark.centre));
      await tester.pump();

      expect(_marksOf(tester).activeMark, same(mark));
      expect(_marksOf(tester).emphasis.growthOf(0), 1);
      expect(
        tester.renderObject(_painted()),
        paints..path(
          includes: <Offset>[mark.centre + Offset(mark.r + 0.5, 0)],
          excludes: <Offset>[mark.centre + Offset(mark.r + 1.5, 0)],
        ),
      );
    });

    testWidgets('moves the highlight from one mark to the next across a long series', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScatterChart(
          height: 240,
          xAxis: const NebaChartAxis(hidden: true),
          yAxis: const NebaChartAxis(hidden: true),
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'A',
              data: <NebaChartPoint>[
                for (int index = 0; index < 200; index++)
                  NebaChartPoint(x: index, y: index.toDouble()),
              ],
            ),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final List<NebaChartMark> marks = _marks(tester);

      await pointer.moveTo(onScreen(tester, marks[0].centre));
      await tester.pump();

      expect(_marksOf(tester).activeMark, same(marks[0]));

      await pointer.moveTo(onScreen(tester, marks[199].centre));
      await tester.pump();

      final NebaChartEmphasis emphasis = _marksOf(tester).emphasis;

      expect(_marksOf(tester).activeMark, same(marks[199]));
      expect(<double>[emphasis.growthOf(0), emphasis.growthOf(199)], <double>[0, 1]);
    });
  });

  group('the table', () {
    NebaChartDataTable table(WidgetTester tester) => tester.widget(find.byType(NebaChartDataTable));

    testWidgets('gives every point a row of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          label: 'Spend',
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(table(tester).caption, 'Spend');
      expect(table(tester).rows, <List<String>>[
        <String>['Q1', '10', '10'],
        <String>['Q1', '20', '40'],
        <String>['Q1', '30', '20'],
        <String>['Q1', '40', '50'],
      ]);
    });

    testWidgets('names its columns from the axis labels, and x and y without them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          xAxis: NebaChartAxis(label: 'Spend'),
          yAxis: NebaChartAxis(label: 'Revenue'),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(table(tester).columns, <String>['', 'Spend', 'Revenue']);

      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(table(tester).columns, <String>['', 'x', 'y']);
    });

    testWidgets('adds a size column only when a point has one', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _bubbles)],
        ),
      );

      expect(table(tester).columns, <String>['', 'x', 'y', 'Size']);
      expect(table(tester).rows.last, <String>['Q1', '30', '20', '64']);
    });

    testWidgets('names the size column in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(
        tester,
        const NebaScatterChart(
          locale: Locale('ko'),
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _bubbles)],
        ),
      );

      expect(table(tester).columns.last, '크기');
    });

    testWidgets('leaves a gap out rather than writing it as a zero', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Q1',
              data: <NebaChartPoint>[NebaChartPoint(x: 1, y: 1), NebaChartPoint(x: 2, y: null)],
            ),
          ],
        ),
      );

      expect(table(tester).rows, <List<String>>[
        <String>['Q1', '1', '1'],
        <String>['Q1', '2', ''],
      ]);
    });

    testWidgets('writes x and z as numbers of their own and y through format', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaScatterChart(
          format: (num value) => 'USD $value',
          series: const <NebaChartSeries>[
            NebaChartSeries(
              name: 'A',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 24000, y: 1200, z: 5000),
                NebaChartPoint(x: 0.1 + 0.2, y: 10),
              ],
            ),
          ],
        ),
      );

      expect(table(tester).rows, <List<String>>[
        <String>['A', '24,000', 'USD 1200', '5,000'],
        <String>['A', '0.3', 'USD 10', ''],
      ]);
    });

    testWidgets('writes a value the way the rest of the chart writes it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: <NebaChartPoint>[NebaChartPoint(x: 1, y: 24000)]),
          ],
        ),
      );

      expect(table(tester).rows.single[2], '24K');
    });

    testWidgets('writes its rows after the first frame past five hundred points', (
      WidgetTester tester,
    ) async {
      List<NebaChartPoint> cloud(int offset) {
        return <NebaChartPoint>[
          for (int index = 0; index < 300; index++)
            NebaChartPoint(x: index + offset, y: (index % 50).toDouble()),
        ];
      }

      await pump(
        tester,
        NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'A', data: cloud(0)),
            NebaChartSeries(name: 'B', data: cloud(1000)),
          ],
        ),
      );

      expect(table(tester).points, 600);
      expect(find.text('1,299'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('1,299'), findsOneWidget);
      expect(table(tester).rows.sublist(298, 302).map((List<String> row) => row.first), <String>[
        'A',
        'A',
        'B',
        'B',
      ]);
    });
  });

  group('tooltip', () {
    testWidgets('opens on the mark nearest the pointer and names its series', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          height: 200,
          xAxis: NebaChartAxis(hidden: true),
          yAxis: NebaChartAxis(hidden: true),
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'High', data: <NebaChartPoint>[NebaChartPoint(x: 50, y: 100)]),
            NebaChartSeries(name: 'Low', data: <NebaChartPoint>[NebaChartPoint(x: 50, y: 0)]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      // The two marks share an x, so the higher is the one nearer the top.
      final NebaChartMark high = _marks(tester).first;

      await pointer.moveTo(onScreen(tester, high.centre));
      await tester.pump();

      expect(_readout(tester), '50, High: 100');
      expect(
        tester.widget<NebaChartTooltipPanel>(find.byType(NebaChartTooltipPanel)).items,
        hasLength(1),
      );
    });

    testWidgets('does not build again for every pixel the pointer moves over one mark', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          height: 200,
          xAxis: NebaChartAxis(hidden: true),
          yAxis: NebaChartAxis(hidden: true),
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: <NebaChartPoint>[NebaChartPoint(x: 50, y: 50)]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final NebaChartMark mark = _marks(tester).single;

      await pointer.moveTo(onScreen(tester, mark.centre));
      await tester.pump();

      final CustomPainter? before = tester.widget<CustomPaint>(_painted()).painter;

      for (int dy = 1; dy <= 8; dy++) {
        await pointer.moveTo(onScreen(tester, mark.centre + Offset(0, dy.toDouble())));
        await tester.pump();
      }

      expect(tester.widget<CustomPaint>(_painted()).painter, same(before));
    });

    testWidgets('says nothing when the pointer is nowhere near a mark', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          height: 200,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: <NebaChartPoint>[NebaChartPoint(x: 0, y: 0)]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final NebaChartMark mark = _marks(tester).single;

      // Well past the reach, which is the mark's own size plus 24.
      await pointer.moveTo(onScreen(tester, mark.centre + const Offset(0, -80)));
      await tester.pump();

      expect(_readout(tester), '');
      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });

    testWidgets('draws no crosshair', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          height: 200,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: <NebaChartPoint>[NebaChartPoint(x: 50, y: 50)]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(onScreen(tester, _marks(tester).single.centre));
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is CustomPaint && widget.painter.runtimeType.toString() == '_CrosshairPainter',
        ),
        findsNothing,
      );
    });

    testWidgets('heads the panel with the mark’s own x, written whole', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'A', data: <NebaChartPoint>[NebaChartPoint(x: 24000, y: 2)]),
            NebaChartSeries(name: 'B', data: <NebaChartPoint>[NebaChartPoint(x: 30000, y: 4)]),
          ],
        ),
      );

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(_readout(tester), '30,000, B: 4');
    });

    testWidgets('is not reachable when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          tooltip: false,
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(onScreen(tester, _marks(tester).first.centre));
      await tester.pump();

      expect(find.byType(NebaLiveRegion), findsNothing);
      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });
  });

  group('keyboard', () {
    testWidgets('walks the marks in the order the data was given', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: _cloud),
            NebaChartSeries(name: 'Q2', data: <NebaChartPoint>[NebaChartPoint(x: 15, y: 5)]),
          ],
        ),
      );

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(_marksOf(tester).activeMark, same(_marks(tester).first));

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();

      expect(_readout(tester), '15, Q2: 5');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(_readout(tester), '40, Q1: 50');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(_readout(tester), '10, Q1: 10');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(_readout(tester), '');
    });
  });

  group('legend', () {
    testWidgets('is left off for a single series', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Q1', data: _cloud)],
        ),
      );

      expect(find.byType(NebaChartLegendBar), findsNothing);
    });

    testWidgets('hides a series when its entry is pressed', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: _cloud),
            NebaChartSeries(name: 'Q2', data: _bubbles),
          ],
        ),
      );

      expect(_marks(tester), hasLength(7));

      await tester.tap(_entry('Q2'));
      await tester.pump();

      expect(_marks(tester), hasLength(4));
    });

    testWidgets('fades a series of dots as one group', (WidgetTester tester) async {
      await pump(
        tester,
        NebaScatterChart(
          series: <NebaChartSeries>[
            const NebaChartSeries(name: 'Q1', data: _cloud),
            NebaChartSeries(
              name: 'Q2',
              data: <NebaChartPoint>[
                for (final NebaChartPoint point in _cloud)
                  NebaChartPoint(x: point.x, y: point.y! + 5),
              ],
            ),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(tester.getCenter(_entry('Q2')));
      await tester.pump();

      final NebaChartEmphasis emphasis = _marksOf(tester).emphasis;

      expect(<double>[emphasis.opacityOf(0), emphasis.opacityOf(1)], <double>[0.28, 1]);
      // One layer for the four marks of the series that fades.
      expect(tester.renderObject(_painted()), paintsExactlyCountTimes(#saveLayer, 1));
    });

    testWidgets('fades each mark on its own once the chart has bubbles', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaScatterChart(
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Q1', data: _cloud),
            NebaChartSeries(name: 'Q2', data: _bubbles),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(tester.getCenter(_entry('Q2')));
      await tester.pump();

      expect(tester.renderObject(_painted()), paintsExactlyCountTimes(#saveLayer, 4));
      // Still largest first.
      expect(_paintedRadii(tester).first, greaterThan(_paintedRadii(tester).last));
    });
  });
}
