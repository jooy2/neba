// NebaLineChart: the parts of the React package's LineChart suite that are
// about the line, asked the way Flutter asks them — the paths, circles and
// labels the painter actually draws instead of SVG elements. The frame around
// the line has a suite of its own in `test/internal/chart_frame_test.dart`.

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/chart_line.dart';

import '../../support/host.dart';

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar', 'Apr'];

Finder _marks() {
  return find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter is NebaLinePainter,
  );
}

NebaLinePainter _painter(WidgetTester tester) {
  return tester.widget<CustomPaint>(_marks()).painter! as NebaLinePainter;
}

List<NebaLineSeriesTrace?> _traces(WidgetTester tester) => _painter(tester).marks.traced.series;

int _runs(Path path) => path.computeMetrics().length;

/// Every circle the marks draw, as its centre and radius.
List<(Offset, double)> _circles(WidgetTester tester) {
  final List<(Offset, double)> circles = <(Offset, double)>[];

  expect(
    tester.renderObject(_marks()),
    paints..everything((Symbol method, List<dynamic> arguments) {
      if (method == #drawCircle && (arguments[2] as Paint).style == PaintingStyle.fill) {
        circles.add((arguments[0] as Offset, arguments[1] as double));
      }

      return true;
    }),
  );

  return circles;
}

void main() {
  Future<void> pump(WidgetTester tester, Widget chart, {bool reduced = false}) {
    return tester.pumpWidget(
      host(
        Center(child: SizedBox(width: 480, child: chart)),
        disableAnimations: reduced,
      ),
    );
  }

  Future<void> activate(WidgetTester tester, int index) async {
    final Focus focus = tester.widget<Focus>(
      find.ancestor(of: find.byType(NebaChartBox), matching: find.byType(Focus)).first,
    );

    focus.focusNode!.requestFocus();
    await tester.pump();

    for (int step = 0; step <= index; step++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }

    await tester.pump();
  }

  group('rendering', () {
    testWidgets('draws one line per shown series, and no band', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaLineChart(
          label: 'Sessions',
          categories: _months,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Web', data: <num>[1, 2, 3, 4]),
            NebaChartSeries(name: 'Mobile', data: <num>[4, 3, 2, 1]),
          ],
        ),
      );

      expect(_traces(tester), hasLength(2));

      for (final NebaLineSeriesTrace? trace in _traces(tester)) {
        expect(trace!.line, isNotNull);
        expect(trace.area, isNull);
      }
    });

    testWidgets('sits its first and last points on the ends of the plot', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaLineChart(
          categories: _months,
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[1, 2, 3, 4]),
          ],
        ),
      );

      final NebaChartLayout layout = _painter(tester).marks.layout;
      final List<Offset?> tops = _traces(tester).single!.tops;

      expect(tops.first!.dx, layout.plot.left);
      expect(tops.last!.dx, layout.plot.right);
    });

    testWidgets('crops its value axis to the data unless asked for zero', (
      WidgetTester tester,
    ) async {
      const List<NebaChartSeries> high = <NebaChartSeries>[
        NebaChartSeries(data: <num>[98, 99, 98.5]),
      ];

      await pump(tester, const NebaLineChart(series: high));
      expect(_painter(tester).marks.layout.scale.min, greaterThan(0));

      await pump(tester, const NebaLineChart(series: high, yAxis: NebaChartAxis(min: 0)));
      expect(_painter(tester).marks.layout.scale.min, 0);
    });

    testWidgets('reflects a changed series on a rebuild', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaLineChart(
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[1, 2]),
          ],
        ),
      );
      await pump(
        tester,
        const NebaLineChart(
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[1, 2, 3]),
          ],
        ),
      );

      expect(_traces(tester).single!.tops, hasLength(3));
    });

    testWidgets('takes its size and variant from NebaProvider when it has none', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg),
          child: NebaLineChart(
            series: <NebaChartSeries>[
              NebaChartSeries(data: <num>[1, 2]),
            ],
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaChartBox)).height, chartPlotHeights[NebaSize.lg]);
    });
  });

  group('curve', () {
    testWidgets('steps and smooths the same points', (WidgetTester tester) async {
      double length(WidgetTester tester) {
        return _traces(tester).single!.line!.computeMetrics().fold<double>(
          0,
          (double sum, PathMetric one) => sum + one.length,
        );
      }

      const List<NebaChartSeries> series = <NebaChartSeries>[
        NebaChartSeries(data: <num>[1, 3, 2, 4]),
      ];

      await pump(tester, const NebaLineChart(series: series));
      final double straight = length(tester);

      await pump(tester, const NebaLineChart(series: series, curve: NebaChartCurve.step));
      final double stepped = length(tester);

      await pump(tester, const NebaLineChart(series: series, curve: NebaChartCurve.smooth));
      final double smooth = length(tester);

      expect(stepped, greaterThan(straight));
      expect(smooth, isNot(straight));
    });
  });

  group('nulls', () {
    const List<NebaChartSeries> gappy = <NebaChartSeries>[
      NebaChartSeries(name: 'Readings', data: <num?>[42, 47, null, null, 51, 58]),
    ];

    testWidgets('breaks the path at a gap by default', (WidgetTester tester) async {
      await pump(tester, const NebaLineChart(series: gappy));

      expect(_runs(_traces(tester).single!.line!), 2);
    });

    testWidgets('bridges the gap with connect', (WidgetTester tester) async {
      await pump(tester, const NebaLineChart(series: gappy, nulls: NebaChartNulls.connect));

      expect(_runs(_traces(tester).single!.line!), 1);
    });

    testWidgets('reads a gap as a nought everywhere with zero', (WidgetTester tester) async {
      await pump(tester, const NebaLineChart(series: gappy, nulls: NebaChartNulls.zero));

      expect(_runs(_traces(tester).single!.line!), 1);
      expect(_painter(tester).marks.layout.scale.min, 0);

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.rows[2], <String>['2', '0']);
    });
  });

  group('markers', () {
    const List<NebaChartSeries> four = <NebaChartSeries>[
      NebaChartSeries(name: 'Web', data: <num>[1, 2, 3, 4]),
    ];
    final List<NebaChartSeries> long = <NebaChartSeries>[
      NebaChartSeries(name: 'Web', data: <num>[for (int index = 0; index < 20; index++) index]),
    ];

    testWidgets('draws a dot per point while there are fourteen or fewer', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaLineChart(series: four));
      expect(_circles(tester), hasLength(4));

      await pump(tester, NebaLineChart(series: long));
      expect(_circles(tester), isEmpty);
    });

    testWidgets('draws one on every point with all and none with none', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaLineChart(series: long, markers: NebaChartMarkers.all));
      expect(_circles(tester), hasLength(20));

      await pump(tester, const NebaLineChart(series: four, markers: NebaChartMarkers.none));
      expect(_circles(tester), isEmpty);
    });

    testWidgets('gives the active point a dot a pixel bigger whatever markers says', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaLineChart(series: four, markers: NebaChartMarkers.none));
      await activate(tester, 1);

      final List<(Offset, double)> circles = _circles(tester);

      expect(circles, hasLength(1));
      expect(circles.single.$2, chartMarkerRadii[NebaSize.md]! + 1);
    });

    testWidgets('grows the active dot over the house duration, and at once when asked', (
      WidgetTester tester,
    ) async {
      final double radius = chartMarkerRadii[NebaSize.md]!;

      await pump(tester, const NebaLineChart(series: four, markers: NebaChartMarkers.all));
      await activate(tester, 2);
      await tester.pump(const Duration(milliseconds: 40));

      final double midway = _circles(tester)[2].$2;

      expect(midway, greaterThan(radius));
      expect(midway, lessThan(radius + 1));

      await tester.pumpAndSettle();
      expect(_circles(tester)[2].$2, radius + 1);
      expect(_circles(tester)[1].$2, radius);

      await pump(
        tester,
        const NebaLineChart(
          key: ValueKey<String>('reduced'),
          series: four,
          markers: NebaChartMarkers.all,
        ),
        reduced: true,
      );
      await activate(tester, 0);

      expect(_circles(tester)[0].$2, radius + 1);
    });
  });

  group('valueLabels', () {
    const List<NebaChartSeries> series = <NebaChartSeries>[
      NebaChartSeries(name: 'Web', data: <num?>[3, 9, 1, null]),
      NebaChartSeries(name: 'Gaps', data: <num?>[null, null, null, null]),
    ];

    List<String> labels(WidgetTester tester, int index) {
      return <String>[
        for (final NebaChartLabel label in _traces(tester)[index]!.labels) label.painter.plainText,
      ];
    }

    testWidgets('labels only the last value that exists with last', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaLineChart(series: series, valueLabels: NebaChartValueLabels.last),
      );

      expect(labels(tester, 0), <String>['1']);
      expect(labels(tester, 1), isEmpty);
    });

    testWidgets('labels the high and the low with extremes, and every point with all', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaLineChart(series: series, valueLabels: NebaChartValueLabels.extremes),
      );
      expect(labels(tester, 0), <String>['9', '1']);

      await pump(
        tester,
        const NebaLineChart(series: series, valueLabels: NebaChartValueLabels.all),
      );
      expect(labels(tester, 0), <String>['3', '9', '1']);
    });

    testWidgets("writes a label in its own series' colour, one step toward the ink", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaLineChart(series: series, valueLabels: NebaChartValueLabels.last),
      );

      final NebaTokens tokens = NebaTokens.light();
      final TextSpan span = _traces(tester)[0]!.labels.single.painter.text! as TextSpan;

      expect(span.style!.color, chartLabelInk(tokens.chart.series.first, tokens));
    });

    testWidgets('makes room above the plot for the labels', (WidgetTester tester) async {
      await pump(tester, const NebaLineChart(series: series));
      final double top = _painter(tester).marks.layout.plot.top;

      await pump(
        tester,
        const NebaLineChart(series: series, valueLabels: NebaChartValueLabels.last),
      );

      expect(_painter(tester).marks.layout.plot.top, top + chartValueLabelHeadroom);
    });
  });

  group('gradient', () {
    testWidgets('fades the line across the plot, a flat one included', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaLineChart(
          gradient: true,
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[11, 11, 11, 11]),
          ],
        ),
      );

      final List<Paint> strokes = <Paint>[];

      expect(
        tester.renderObject(_marks()),
        paints..everything((Symbol method, List<dynamic> arguments) {
          if (method == #drawPath && (arguments[1] as Paint).style == PaintingStyle.stroke) {
            strokes.add(arguments[1] as Paint);
          }

          return true;
        }),
      );

      expect(strokes.single.shader, isNotNull);
    });
  });

  group('stacked', () {
    testWidgets('stacks a negative series down from zero and the positive ones above it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaLineChart(
          stacked: true,
          markers: NebaChartMarkers.all,
          categories: <Object>['Jan'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'In', data: <num>[10]),
            NebaChartSeries(name: 'Out', data: <num>[-5]),
            NebaChartSeries(name: 'More in', data: <num>[10]),
          ],
        ),
      );

      final double first = _traces(tester)[0]!.tops.single!.dy;
      final double negative = _traces(tester)[1]!.tops.single!.dy;
      final double top = _traces(tester)[2]!.tops.single!.dy;

      expect((first - top) / (negative - first), closeTo(10 / 15, 0.01));
    });
  });
}
