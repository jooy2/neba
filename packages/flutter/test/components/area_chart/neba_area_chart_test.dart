// NebaAreaChart: the React package's AreaChart suite, asked the way Flutter
// asks it — the bands, gaps and lines the painter traces and draws instead of
// SVG paths, and the table the frame builds instead of the DOM's.

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/chart_line.dart';
import 'package:neba/src/internal/color.dart';

import '../../support/host.dart';

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar'];

Finder _marks() {
  return find.byWidgetPredicate(
    (Widget widget) => widget is CustomPaint && widget.painter is NebaLinePainter,
  );
}

NebaLinePainter _painter(WidgetTester tester) {
  return tester.widget<CustomPaint>(_marks()).painter! as NebaLinePainter;
}

List<NebaLineSeriesTrace?> _traces(WidgetTester tester) => _painter(tester).marks.traced.series;

/// Every path the marks draw, with the paint it is drawn in.
List<(Path, Paint)> _paths(WidgetTester tester) {
  final List<(Path, Paint)> paths = <(Path, Paint)>[];

  expect(
    tester.renderObject(_marks()),
    paints..everything((Symbol method, List<dynamic> arguments) {
      if (method == #drawPath) {
        paths.add((arguments[0] as Path, arguments[1] as Paint));
      }

      return true;
    }),
  );

  return paths;
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget chart) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 480, child: chart))));
  }

  group('rendering', () {
    testWidgets('fills under each series as well as drawing it', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAreaChart(
          label: 'Storage',
          categories: _months,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Hot', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final List<(Path, Paint)> paths = _paths(tester);

      // The wash, fading downward, and the edge.
      expect(paths, hasLength(2));
      expect(paths.first.$2.style, PaintingStyle.fill);
      expect(paths.first.$2.shader, isNotNull);
      expect(paths.last.$2.style, PaintingStyle.stroke);
    });

    testWidgets('keeps zero on its value axis, where a line would crop', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAreaChart(
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[98, 99, 98.5]),
          ],
        ),
      );

      expect(_painter(tester).marks.layout.scale.min, 0);
    });

    testWidgets('writes its data into a table', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAreaChart(
          label: 'Storage by tier',
          categories: _months,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Hot', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.caption, 'Storage by tier');
      expect(table.rows[1], <String>['Feb', '20']);
    });

    testWidgets('reflects a changed curve on a rebuild', (WidgetTester tester) async {
      const List<NebaChartSeries> series = <NebaChartSeries>[
        NebaChartSeries(name: 'Hot', data: <num>[1, 3, 2]),
      ];

      await pump(tester, const NebaAreaChart(series: series));
      final Path before = _traces(tester).single!.area!;

      await pump(tester, const NebaAreaChart(series: series, curve: NebaChartCurve.smooth));
      final Path after = _traces(tester).single!.area!;

      double length(Path path) {
        return path.computeMetrics().fold<double>(
          0,
          (double sum, PathMetric one) => sum + one.length,
        );
      }

      expect(identical(before, after), isFalse);
      expect(length(after), isNot(closeTo(length(before), 0.01)));
    });
  });

  group('nulls', () {
    const List<NebaChartSeries> gappy = <NebaChartSeries>[
      NebaChartSeries(name: 'Hot', data: <num?>[10, 20, null, 40, 50]),
    ];

    testWidgets('breaks the band at a gap by default', (WidgetTester tester) async {
      await pump(tester, const NebaAreaChart(series: gappy));

      expect(_traces(tester).single!.area!.computeMetrics().length, 2);
    });

    testWidgets('closes the band across a gap with connect', (WidgetTester tester) async {
      await pump(tester, const NebaAreaChart(series: gappy, nulls: NebaChartNulls.connect));

      expect(_traces(tester).single!.area!.computeMetrics().length, 1);
    });

    testWidgets('reads the gap as a nought everywhere with zero', (WidgetTester tester) async {
      await pump(tester, const NebaAreaChart(series: gappy, nulls: NebaChartNulls.zero));

      expect(_traces(tester).single!.area!.computeMetrics().length, 1);

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.rows[2], <String>['2', '0']);
    });
  });

  group('stacked', () {
    const List<NebaChartSeries> two = <NebaChartSeries>[
      NebaChartSeries(name: 'Hot', data: <num>[10, 20, 30]),
      NebaChartSeries(name: 'Archive', data: <num>[40, 50, 60]),
    ];

    testWidgets('swaps the wash for a flat tint and separates the bands', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaAreaChart(stacked: NebaChartStacking.on, categories: _months, series: two),
      );

      final List<(Path, Paint)> paths = _paths(tester);
      final List<Paint> fills = <Paint>[
        for (final (Path _, Paint paint) in paths)
          if (paint.style == PaintingStyle.fill) paint,
      ];
      final List<Paint> strokes = <Paint>[
        for (final (Path _, Paint paint) in paths)
          if (paint.style == PaintingStyle.stroke) paint,
      ];

      expect(fills, hasLength(2));
      expect(fills.every((Paint paint) => paint.shader == null), isTrue);
      expect(
        fills.first.color,
        isSameColorAs(mixOklab(tokens.chart.series.first, 0.70, transparent)),
      );
      // No line along a band, and one surface-coloured rule between the two.
      expect(strokes, hasLength(1));
      expect(strokes.single.color, isSameColorAs(tokens.chartGap));
    });

    testWidgets('sets each band on the total of the ones below it', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAreaChart(stacked: NebaChartStacking.on, categories: _months, series: two),
      );

      final NebaChartLayout layout = _painter(tester).marks.layout;

      expect(_traces(tester)[1]!.tops.first!.dy, layout.valuePx(50));
      expect(layout.scale.max, greaterThanOrEqualTo(90));
    });

    testWidgets('turns the value axis into a percentage with full', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAreaChart(
          label: 'Mix',
          stacked: NebaChartStacking.full,
          categories: <Object>['Jan'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'New', data: <num>[40]),
            NebaChartSeries(name: 'Renewed', data: <num>[160]),
          ],
        ),
      );

      final NebaChartLayout layout = _painter(tester).marks.layout;

      expect(layout.scale.min, 0);
      expect(layout.scale.max, 100);
      expect(layout.values[0].single.value, 20);
    });

    testWidgets("keeps the caller's own numbers, through format, in the table", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaAreaChart(
          label: 'Mix',
          stacked: NebaChartStacking.full,
          format: (num value) => value.round().toString(),
          categories: const <Object>['Jan'],
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'New', data: <num>[1234.5678]),
            NebaChartSeries(name: 'Renewed', data: <num>[100]),
          ],
        ),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.rows.single, <String>['Jan', '1235', '100']);
      // And the share's label, which the tooltip reads.
      expect(_painter(tester).marks.layout.values[0].single.label, '1235');
    });

    testWidgets('puts a second axis back on one scale', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaAreaChart(
          stacked: NebaChartStacking.on,
          secondaryAxis: NebaChartAxis(),
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'A', data: <num>[1, 2]),
            NebaChartSeries(name: 'B', data: <num>[3, 4], axis: NebaChartSeriesAxis.secondary),
          ],
        ),
      );

      expect(_painter(tester).marks.layout.secondScale, isNull);
    });
  });

  testWidgets('draws no dots unless asked', (WidgetTester tester) async {
    int circles(WidgetTester tester) {
      int count = 0;

      expect(
        tester.renderObject(_marks()),
        paints..everything((Symbol method, List<dynamic> arguments) {
          if (method == #drawCircle) {
            count += 1;
          }

          return true;
        }),
      );

      return count;
    }

    const List<NebaChartSeries> series = <NebaChartSeries>[
      NebaChartSeries(data: <num>[1, 2, 3]),
    ];

    await pump(tester, const NebaAreaChart(series: series));
    expect(circles(tester), 0);

    await pump(tester, const NebaAreaChart(series: series, markers: NebaChartMarkers.all));
    expect(circles(tester), 6);
  });
}
