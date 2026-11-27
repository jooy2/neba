import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

List<List<NebaChartValue>> _rows(List<List<double?>> numbers) {
  return <List<NebaChartValue>>[
    for (final List<double?> one in numbers)
      <NebaChartValue>[for (final double? value in one) NebaChartValue(value: value)],
  ];
}

double _length(Path path) {
  return path.computeMetrics().fold<double>(0, (double sum, PathMetric one) => sum + one.length);
}

void main() {
  group('chartValueScale', () {
    test('rounds the top outward to a tick, so the tallest mark stops short of the frame', () {
      final NebaChartScale scale = chartValueScale((min: 0, max: 4830));

      expect(scale.max, greaterThan(4830));
      expect(scale.ticks.last, scale.max);
    });

    test('rounds the ends to the step the data already sits on', () {
      final NebaChartScale low = chartValueScale((min: 2.4, max: 3.4), includeZero: false);

      expect(low.min, 2.4);
      expect(low.ticks.first, 2.4);

      final NebaChartScale high = chartValueScale((min: 0.2, max: 0.28), includeZero: false);

      expect(high.max, 0.28);
      expect(high.ticks.last, 0.28);
    });

    test('opens a band around a flat series rather than dividing by zero', () {
      final NebaChartScale scale = chartValueScale((min: 40, max: 40), includeZero: false);

      expect(scale.min, lessThan(40));
      expect(scale.max, greaterThan(40));
      expect(scale.fraction(40).isFinite, isTrue);

      final NebaChartScale zero = chartValueScale((min: 0, max: 0));

      expect(zero.max, greaterThan(zero.min));
    });

    test('answers a scale with no data at all', () {
      final NebaChartScale scale = chartValueScale(null);

      expect(scale.max, greaterThan(scale.min));
      expect(scale.ticks.length, greaterThan(1));
    });

    test('keeps zero in range unless an end was pinned', () {
      expect(chartValueScale((min: 20, max: 90)).min, 0);
      expect(chartValueScale((min: 20, max: 90), min: 20).min, 20);
    });

    test('prints no tick as a floating-point smear, and keeps the last one', () {
      final NebaChartScale scale = chartValueScale((min: 0, max: 0.5));

      for (final double tick in scale.ticks) {
        expect(tick.toString().length, lessThan(8));
      }

      expect(scale.ticks.last, 0.5);
    });

    test('runs the fraction from 0 at the bottom to 1 at the top', () {
      final NebaChartScale scale = chartValueScale((min: 0, max: 100), min: 0, max: 100);

      expect(scale.fraction(0), 0);
      expect(scale.fraction(100), 1);
      expect(scale.fraction(50), closeTo(0.5, 1e-10));
    });

    test('handles a range entirely below zero', () {
      final NebaChartScale scale = chartValueScale((min: -900, max: -100));

      expect(scale.min, lessThanOrEqualTo(-900));
      expect(scale.max, 0);
    });

    test('keeps both ends of a pinned range and divides it on a step that lands on both', () {
      final NebaChartScale scale = chartValueScale(
        (min: 99.7, max: 99.99),
        min: 99.5,
        max: 100,
        tickCount: 5,
      );

      expect(scale.ticks.first, 99.5);
      expect(scale.ticks.last, 100);
    });

    test('keeps a pinned end when every value lies past it', () {
      final NebaChartScale below = chartValueScale(
        (min: -50, max: -10),
        min: 0,
        includeZero: false,
      );

      expect(below.min, 0);
      expect(below.max, greaterThan(0));
      expect(below.ticks.every((double tick) => tick.isFinite), isTrue);

      final NebaChartScale bars = chartValueScale((min: 2, max: 5), min: 10);

      expect(bars.min, 10);
      expect(bars.max, greaterThan(10));
    });

    test('finds a power of ten where a logarithm alone falls short of it', () {
      // `log(1000) / ln 10` is 2.9999999999999996.
      expect(chartValueScale((min: 0, max: 5000), tickCount: 5).ticks, <double>[
        0,
        1000,
        2000,
        3000,
        4000,
        5000,
      ]);
    });
  });

  group('chartAlignedScale', () {
    test('cuts the range into exactly the intervals it is given, and covers the data', () {
      for (final int intervals in <int>[4, 5, 7]) {
        final NebaChartScale scale = chartAlignedScale((min: 2, max: 4), intervals);
        final double step = scale.ticks[1] - scale.ticks[0];

        expect(scale.ticks, hasLength(intervals + 1));

        for (int index = 0; index < scale.ticks.length; index++) {
          expect(scale.ticks[index], closeTo(scale.ticks.first + index * step, 1e-9));
        }

        expect(scale.min, lessThanOrEqualTo(0));
        expect(scale.max, greaterThanOrEqualTo(4));
      }
    });

    test('steps in clean numbers, and starts on a multiple of the step', () {
      final NebaChartScale scale = chartAlignedScale((min: 3, max: 41), 5, includeZero: false);
      final double step = scale.ticks[1] - scale.ticks[0];

      expect(<double>[1, 2, 5, 10, 20, 50], contains(step));
      expect(scale.min % step, 0);
      expect(scale.max, greaterThanOrEqualTo(41));
    });

    test('keeps an end the caller pinned, and divides a range pinned at both', () {
      expect(chartAlignedScale((min: 2, max: 4), 5, min: 1).ticks.first, 1);
      expect(chartAlignedScale((min: 2, max: 4), 5, max: 10).ticks[5], 10);
      expect(chartAlignedScale((min: 2, max: 4), 3, min: 0, max: 9).ticks, <double>[0, 3, 6, 9]);
    });
  });

  group('chartExtentOf', () {
    test('ignores a gap rather than counting it as zero', () {
      expect(
        chartExtentOf(
          _rows(<List<double?>>[
            <double?>[50, null, 70],
          ]),
          stacked: false,
        ),
        (min: 50.0, max: 70.0),
      );
    });

    test('answers null when there is nothing to measure', () {
      expect(
        chartExtentOf(
          _rows(<List<double?>>[
            <double?>[null, null],
          ]),
          stacked: false,
        ),
        isNull,
      );
      expect(chartExtentOf(const <List<NebaChartValue>>[], stacked: false), isNull);
    });

    test('sums a stack, and sums the two signs apart', () {
      expect(
        chartExtentOf(
          _rows(<List<double?>>[
            <double?>[10, -5],
            <double?>[20, -5],
          ]),
          stacked: true,
        ),
        (min: -10.0, max: 30.0),
      );
    });

    test('leaves a gap out of a stack without shortening the column', () {
      expect(
        chartExtentOf(
          _rows(<List<double?>>[
            <double?>[10, 10],
            <double?>[null, 10],
          ]),
          stacked: true,
        ),
        (min: 0.0, max: 20.0),
      );
    });
  });

  group('chartValueOf', () {
    test('reads the three ways a datum can be written', () {
      expect(chartValueOf(12).value, 12);
      expect(chartValueOf(null).value, isNull);

      final NebaChartValue point = chartValueOf(const NebaChartPoint(y: 3, x: 'Jan'));

      expect(point.value, 3);
      expect(point.x, 'Jan');
    });

    test('treats a number that is not one as a gap, and anything else too', () {
      expect(chartValueOf(double.nan).value, isNull);
      expect(chartValueOf(double.infinity).value, isNull);
      expect(chartValueOf(const NebaChartPoint(y: double.nan)).value, isNull);
      expect(chartValueOf('12').value, isNull);
    });

    test('keeps a point’s own label and category beside a null value', () {
      final NebaChartValue value = chartValueOf(
        const NebaChartPoint(y: null, x: 'Feb', label: 'no reading'),
      );

      expect(value.value, isNull);
      expect(value.x, 'Feb');
      expect(value.label, 'no reading');
    });

    test('counts the widest series rather than the first', () {
      expect(
        chartCategoryCount(const <NebaChartSeries>[
          NebaChartSeries(data: <num>[1, 2, 3]),
          NebaChartSeries(data: <num>[1]),
        ]),
        3,
      );
      expect(chartCategoryCount(const <NebaChartSeries>[]), 0);
    });
  });

  group('chartZeroGaps', () {
    test('turns every shape of gap into a nought and keeps the rest of a point', () {
      final List<NebaChartSeries> zeroed = chartZeroGaps(const <NebaChartSeries>[
        NebaChartSeries(
          name: 'Web',
          color: NebaColor.danger,
          data: <Object?>[
            1,
            null,
            NebaChartPoint(y: null, x: 'Jan'),
            NebaChartPoint(y: 3),
            double.nan,
          ],
        ),
      ]);

      expect(zeroed.single.name, 'Web');
      expect(zeroed.single.color, NebaColor.danger);
      expect(zeroed.single.data, <Object?>[
        1,
        0,
        const NebaChartPoint(y: 0, x: 'Jan'),
        const NebaChartPoint(y: 3),
        0,
      ]);
    });
  });

  group('chartFullShares', () {
    test('shares each category out of a hundred and keeps the original as the label', () {
      final List<List<NebaChartValue>> shares = chartFullShares(
        _rows(<List<double?>>[
          <double?>[30, 10],
          <double?>[70, 30],
        ]),
        <bool>[true, true],
        (double value) => '#$value',
      );

      expect(shares[0][0].value, 30);
      expect(shares[1][1].value, 75);
      expect(shares[0][0].label, '#30.0');
    });

    test('leaves a hidden series out of the total, and keeps a gap a gap', () {
      final List<List<NebaChartValue>> shares = chartFullShares(
        _rows(<List<double?>>[
          <double?>[50, null],
          <double?>[50, 10],
        ]),
        <bool>[false, true],
        (double value) => '$value',
      );

      expect(shares[1][0].value, 100);
      expect(shares[0][1].value, isNull);
    });
  });

  group('colour', () {
    final NebaTokens tokens = NebaTokens.light();

    test('follows the index in the list it was passed, not a position among the shown', () {
      const NebaChartSeries plain = NebaChartSeries(data: <num>[]);

      expect(chartSeriesColor(plain, 1, tokens), tokens.chart.series[1]);
      expect(chartSeriesColor(plain, 9, tokens), tokens.chart.series[1]);
    });

    test('hands the eight slots out in order', () {
      const NebaChartSeries plain = NebaChartSeries(data: <num>[]);
      final Set<Color> first = <Color>{
        for (int index = 0; index < 8; index++) chartSeriesColor(plain, index, tokens),
      };

      expect(first, hasLength(8));
    });

    test('lets a series name its own colour, a family or a colour of its own', () {
      expect(
        chartSeriesColor(const NebaChartSeries(data: <num>[], color: NebaColor.danger), 3, tokens),
        tokens.roles(NebaColor.danger).accent,
      );
      expect(
        chartSeriesColor(const NebaChartSeries(data: <num>[], color: Color(0xFF663399)), 3, tokens),
        const Color(0xFF663399),
      );
    });

    test('mixes a value label toward the page ink rather than using the mark raw', () {
      final Color mark = tokens.chart.series.first;

      expect(chartLabelInk(mark, tokens), mixOklab(mark, 0.85, tokens.fg));
      expect(contrastRatio(chartLabelInk(mark, tokens), tokens.surface), greaterThan(4.5));
    });
  });

  group('paths', () {
    const List<Offset?> points = <Offset?>[Offset(0, 10), Offset(10, 20), Offset(20, 30)];

    test('draws one run through every point', () {
      final Path path = chartLinePath(points, NebaChartCurve.linear);

      expect(path.computeMetrics().length, 1);
      expect(_length(path), closeTo(2 * math.sqrt(200), 1e-6));
    });

    test('breaks at a gap instead of drawing through it', () {
      final Path path = chartLinePath(<Offset?>[points[0], null, points[2]], NebaChartCurve.linear);

      expect(path.computeMetrics().length, 2);
    });

    test('draws a lone point between two gaps as a dot rather than nothing', () {
      final Path path = chartLinePath(<Offset?>[null, points[1], null], NebaChartCurve.linear);

      expect(path.getBounds().center.dx, closeTo(10, 0.01));
      expect(path.getBounds().width, lessThan(0.1));
    });

    test('draws nothing at all when every point is a gap', () {
      expect(chartLinePath(<Offset?>[null, null], NebaChartCurve.linear).getBounds(), Rect.zero);
    });

    test('steps between points rather than sloping', () {
      // Across to the middle, down, and across again.
      expect(_length(chartLinePath(points.sublist(0, 2), NebaChartCurve.step)), closeTo(20, 1e-6));
    });

    test('smooths without passing a value both of its neighbours are above', () {
      final Path path = chartLinePath(const <Offset?>[
        Offset(0, 50),
        Offset(10, 0),
        Offset(20, 0),
        Offset(30, 50),
      ], NebaChartCurve.smooth);

      expect(path.getBounds().top, closeTo(0, 1e-6));
    });

    test('breaks an area with its line, run by run', () {
      final Path area = chartAreaPath(
        <Offset?>[points[0], null, points[2]],
        NebaChartCurve.linear,
        baseline: 40,
      );

      expect(area.computeMetrics().length, 2);
    });

    test('rounds a bar only at its data end, and shrinks the radius to fit', () {
      final Path bar = chartBarPath(const Rect.fromLTWH(0, 0, 10, 2), 4, NebaChartBarEnd.up);

      expect(bar.getBounds(), const Rect.fromLTWH(0, 0, 10, 2));
      expect(bar.contains(const Offset(0.1, 1.9)), isTrue);
    });
  });

  group('the axis', () {
    test('centres a category in its own slot and survives none', () {
      final NebaChartBand band = NebaChartBand(4, 400, 1);

      expect(band.step, 100);
      expect(band.centre(0), 50);
      expect(band.centre(3), 350);
      expect(NebaChartBand(0, 400, 1).step.isFinite, isTrue);
      expect(NebaChartBand(4, 400, 0.5).band, lessThan(band.band));
    });

    test('labels every category that fits and skips enough of the rest', () {
      expect(chartTickStride(4, 400, 40), 1);
      expect(chartTickStride(40, 400, 40), greaterThan(1));
      expect(chartTickStride(0, 0, 0), 1);
      expect(chartTickStride(100, -10, 0), 1);
    });

    test('keeps the last label only when it clears the one before it', () {
      expect(chartShowsTick(13, 14, 2, roomForLast: true), isTrue);
      expect(chartShowsTick(13, 14, 2, roomForLast: false), isFalse);
      expect(chartFitsLast(14, 2, 40, 20), isTrue);
      expect(chartFitsLast(14, 2, 10, 20), isFalse);
    });

    test('cuts a label that does not fit and marks the cut', () {
      expect(chartTruncate('Jan', 200, 12), 'Jan');
      expect(chartTruncate('September 2026', 30, 12), endsWith('…'));
      expect(chartTruncate('September', 1, 12), '…');
      expect(chartTruncate('September', 0, 12), 'September');
    });

    test('takes a Hangul character as a whole em and a Latin one as six tenths', () {
      expect(chartTextWidth('가나', 10), 20);
      expect(chartTextWidth('ab', 10), 12);
    });

    test('turns labels so a neighbour only has to clear their height', () {
      final NebaChartTurn flat = chartTurnedAxis(0, 12);
      final NebaChartTurn turned = chartTurnedAxis(-45, 12);

      expect(flat.tilted, isFalse);
      expect(flat.room(100), 112);
      expect(turned.room(100), lessThan(flat.room(100)));
      expect(turned.anchor, -1);
      expect(chartTurnedAxis(-120, 12).angle, -90);
    });

    test('writes a whole number as an integer and a date as its month and day', () {
      expect(chartNumber(100), 100);
      expect(chartNumber(100) is int, isTrue);
      expect(chartNumber(2.5), 2.5);
      expect(chartCategoryText(DateTime(2026, 6, 1)), 'Jun 1');
      expect(chartCategoryText(2024), '2024');
      expect(chartCategoryText('Mon'), 'Mon');
    });
  });

  group('chartLabelledPoints', () {
    final List<NebaChartValue> one = _rows(<List<double?>>[
      <double?>[3, 9, null, 1, 9, null],
    ]).single;

    test('names the high and the low, every time either value appears', () {
      final bool Function(int) labelled = chartLabelledPoints(one, NebaChartValueLabels.extremes);

      expect(
        <int>[
          for (int index = 0; index < one.length; index++)
            if (labelled(index)) index,
        ],
        <int>[1, 3, 4],
      );
    });

    test('takes the last value that exists rather than the last slot', () {
      final bool Function(int) labelled = chartLabelledPoints(one, NebaChartValueLabels.last);

      expect(labelled(4), isTrue);
      expect(labelled(5), isFalse);
    });

    test('names nothing in a series that is all gaps, and every point with all', () {
      final List<NebaChartValue> gaps = _rows(<List<double?>>[
        <double?>[null, null],
      ]).single;

      expect(chartLabelledPoints(gaps, NebaChartValueLabels.extremes)(0), isFalse);
      expect(chartLabelledPoints(one, NebaChartValueLabels.all)(2), isTrue);
      expect(chartLabelledPoints(one, NebaChartValueLabels.none)(1), isFalse);
    });
  });

  group('arcs', () {
    const Offset centre = Offset(100, 100);

    test('measures an angle clockwise from twelve o’clock', () {
      Offset round(Offset point) => Offset(point.dx.roundToDouble(), point.dy.roundToDouble());

      expect(round(chartPolar(centre, 50, 0)), const Offset(100, 50));
      expect(round(chartPolar(centre, 50, 90)), const Offset(150, 100));
      expect(round(chartPolar(centre, 50, 180)), const Offset(100, 150));
      expect(round(chartPolar(centre, 50, -90)), const Offset(50, 100));
    });

    test('runs a wedge in to the centre and a band along its hole', () {
      final Path wedge = chartArcPath(centre, 80, 0, 0, 90);
      final Path band = chartArcPath(centre, 80, 50, 0, 90);

      expect(wedge.contains(centre + const Offset(5, -5)), isTrue);
      expect(band.contains(centre + const Offset(5, -5)), isFalse);
      expect(band.contains(centre + const Offset(45, -45)), isTrue);
      // Nothing outside the quarter it was asked for.
      expect(band.contains(centre + const Offset(-45, -45)), isFalse);
      expect(wedge.getBounds().right, closeTo(180, 0.01));
    });

    test('draws a full turn as a whole disc, or a ring with its hole left out', () {
      final Path disc = chartArcPath(centre, 80, 0, -30, 330);
      final Path ring = chartArcPath(centre, 80, 50, 0, 360);

      expect(disc.contains(centre), isTrue);
      expect(disc.contains(centre + const Offset(0, -79)), isTrue);
      expect(ring.contains(centre), isFalse);
      expect(ring.contains(centre + const Offset(0, -65)), isTrue);
      expect(ring.contains(centre + const Offset(0, 65)), isTrue);
    });

    test('strokes a gauge along one open arc, a full turn included', () {
      final Path half = chartRingPath(centre, 50, -90, 90);
      final Path whole = chartRingPath(centre, 50, 0, 360);

      expect(half.computeMetrics().length, 1);
      expect(_length(half), closeTo(50 * math.pi, 0.5));
      // From nine o'clock over the top to three, never below the centre.
      expect(half.getBounds().bottom, closeTo(100, 0.01));
      expect(whole.computeMetrics().length, 1);
      expect(_length(whole), closeTo(100 * math.pi, 1));
    });

    test('writes a label on a slot in its own ink, and on a colour of its own by contrast', () {
      final NebaTokens tokens = NebaTokens.light();

      expect(chartInkOn(null, 9, tokens), tokens.ink(tokens.chart.seriesInk[1]));
      expect(chartInkOn(const Color(0xFFFFE066), 0, tokens), const Color(0xFF000000));
      expect(chartInkOn(const Color(0xFF1E2A5A), 0, tokens), const Color(0xFFFFFFFF));
      expect(chartInkOn(NebaColor.success, 0, tokens), tokens.surface);
    });
  });

  group('a category axis on numbers', () {
    test('reads a date as its milliseconds and a string as no place at all', () {
      final DateTime day = DateTime(2026, 3, 1);

      expect(chartToNumber(day), day.millisecondsSinceEpoch.toDouble());
      expect(chartToNumber(12), 12);
      expect(chartToNumber(double.nan), isNull);
      expect(chartToNumber('Seoul'), isNull);
    });

    test('places a point by its own x, then by the categories, then by its index', () {
      const NebaChartValue own = NebaChartValue(value: 1, x: 40);
      const NebaChartValue bare = NebaChartValue(value: 1);
      const NebaChartValue named = NebaChartValue(value: 1, x: 'Seoul');

      expect(chartPointX(own, 0, <Object>[7]), 40);
      expect(chartPointX(bare, 0, <Object>[7]), 7);
      expect(chartPointX(bare, 3, null), 3);
      expect(chartPointX(named, 0, <Object>[7]), isNull);
    });

    test('measures only the points that are drawn', () {
      final List<List<NebaChartValue>> values = <List<NebaChartValue>>[
        <NebaChartValue>[
          const NebaChartValue(value: 1, x: 10),
          const NebaChartValue(x: 99),
          const NebaChartValue(value: 2, x: -5),
        ],
      ];

      expect(chartCategoryExtent(values, null), (min: -5.0, max: 10.0));
      expect(
        chartCategoryExtent(<List<NebaChartValue>>[
          <NebaChartValue>[const NebaChartValue(value: 1, x: 'Seoul')],
        ], null),
        isNull,
      );
    });

    test('sizes a bubble by the square root of its share, with a floor', () {
      expect(chartBubbleRadius(64, 64, 40, 2), 40);
      expect(chartBubbleRadius(16, 64, 40, 2), 20);
      expect(chartBubbleRadius(0.001, 64, 40, 2), 2);
      expect(chartBubbleRadius(0, 64, 40, 2), 0);
    });

    test('draws every mark shape over the area of the circle of its radius', () {
      const Offset centre = Offset(50, 50);
      final double circle = math.pi * 10 * 10;
      final Rect square = chartMarkPath(NebaMarkShape.square, centre, 10).getBounds();
      final Rect diamond = chartMarkPath(NebaMarkShape.diamond, centre, 10).getBounds();
      final Rect triangle = chartMarkPath(NebaMarkShape.triangle, centre, 10).getBounds();

      expect(chartMarkPath(NebaMarkShape.circle, centre, 10).getBounds().width, closeTo(20, 1e-3));
      expect(square.width * square.height, closeTo(circle, 0.5));
      expect(diamond.width * diamond.height / 2, closeTo(circle, 0.5));
      // On its circumcircle: its apex a radius above the point, its base half
      // of one below.
      expect(centre.dy - triangle.top, closeTo(2 * (triangle.bottom - centre.dy), 1e-3));
      expect(chartMarkPath(NebaMarkShape.cross, centre, 0).getBounds().isEmpty, isTrue);
    });
  });

  group('magnitudes', () {
    test('puts the ends of a range on the palest and the deepest step', () {
      expect(chartRampStep(0, 0, 100, diverging: false), 0);
      expect(chartRampStep(100, 0, 100, diverging: false), 4);
      expect(chartRampStep(39, 0, 100, diverging: false), 1);
    });

    test('reads a range with nothing to spread against zero', () {
      expect(chartRampStep(0, 0, 0, diverging: false), 0);
      expect(chartRampStep(5, 5, 5, diverging: false), 4);
    });

    test('scales a diverging value by the longer arm, about its midpoint', () {
      expect(chartRampStep(-2, -2, 40, diverging: true), 2);
      expect(chartRampStep(40, -2, 40, diverging: true), 4);
      expect(chartRampStep(0, 0, 100, diverging: true, midpoint: 50), 0);
      expect(chartRampStep(50, 0, 100, diverging: true, midpoint: 50), 2);
    });

    test('packs tiles whose areas are their shares, largest first, into the whole box', () {
      final List<({int index, Rect rect})> tiles = chartSquarify(
        <double>[1, 3, 0, -2, 2],
        300,
        200,
      );
      double area(Rect rect) => rect.width * rect.height;

      expect(tiles.map((({int index, Rect rect}) tile) => tile.index), <int>[1, 4, 0]);
      expect(
        tiles.fold<double>(0, (double sum, ({int index, Rect rect}) tile) => sum + area(tile.rect)),
        closeTo(300 * 200, 1e-6),
      );
      expect(area(tiles[0].rect) / area(tiles[2].rect), closeTo(3, 1e-9));

      for (final ({int index, Rect rect}) tile in tiles) {
        expect(
          const Rect.fromLTWH(0, 0, 300, 200).inflate(1e-9).contains(tile.rect.topLeft),
          isTrue,
        );
      }

      expect(chartSquarify(<double>[0, -1], 300, 200), isEmpty);
    });
  });

  group('time', () {
    double at(DateTime date) => date.millisecondsSinceEpoch.toDouble();

    test('ticks on the first of each month across half a year', () {
      final NebaChartTimeScale scale = chartTimeScale((
        min: at(DateTime(2026, 1, 9)),
        max: at(DateTime(2026, 6, 20)),
      ));

      expect(scale.unit, NebaChartTimeUnit.month);
      expect(scale.ticks.first, at(DateTime(2026)));
      // Rounded outward at both ends, as a value scale is.
      expect(scale.min, at(DateTime(2026)));
      expect(scale.max, at(DateTime(2026, 7)));
      expect(
        scale.ticks.map((double tick) => DateTime.fromMillisecondsSinceEpoch(tick.round()).day),
        everyElement(1),
      );
    });

    test('steps in hours across a day, from the hour', () {
      final NebaChartTimeScale scale = chartTimeScale((
        min: at(DateTime(2026, 3, 2, 9, 20)),
        max: at(DateTime(2026, 3, 2, 17, 40)),
      ));

      expect(scale.unit, NebaChartTimeUnit.hour);
      expect(scale.ticks.first, at(DateTime(2026, 3, 2, 9)));
    });

    test('keeps a pinned start and still ticks on the calendar', () {
      final NebaChartTimeScale scale = chartTimeScale((
        min: at(DateTime(2026, 1, 31)),
        max: at(DateTime(2026, 5, 31)),
      ), min: at(DateTime(2026, 1, 31)));

      expect(scale.min, at(DateTime(2026, 1, 31)));
      expect(scale.ticks.first, at(DateTime(2026, 2)));
    });

    test('opens a day around a single instant', () {
      final NebaChartTimeScale scale = chartTimeScale((
        min: at(DateTime(2026, 3, 2, 12)),
        max: at(DateTime(2026, 3, 2, 12)),
      ));

      expect(scale.max - scale.min, greaterThanOrEqualTo(24 * 60 * 60 * 1000));
    });

    test('names the year once inside it, and on every tick across one', () {
      const NebaDateNames names = NebaDateNames.english;

      expect(
        chartTimeTicks(
          <double>[at(DateTime(2026)), at(DateTime(2026, 2)), at(DateTime(2026, 3))],
          NebaChartTimeUnit.month,
          names,
        ),
        <String>['Jan 2026', 'Feb', 'Mar'],
      );
      expect(
        chartTimeTicks(
          <double>[at(DateTime(2025, 12)), at(DateTime(2026))],
          NebaChartTimeUnit.month,
          names,
        ),
        <String>['Dec 2025', 'Jan 2026'],
      );
      expect(
        chartTimeTicks(<double>[at(DateTime(2026, 3, 2))], NebaChartTimeUnit.day, names),
        <String>['Mar 2, 2026'],
      );
    });

    test('writes an instant whole, with its time when asked', () {
      const NebaDateNames names = NebaDateNames.english;
      final double nine = at(DateTime(2026, 3, 3, 9, 5));

      expect(chartTimeValue(nine, NebaChartTimeUnit.day, names), 'Mar 3, 2026');
      expect(chartTimeValue(nine, NebaChartTimeUnit.day, names, clock: true), 'Mar 3, 2026, 09:05');
      expect(chartTimeValue(nine, NebaChartTimeUnit.minute, names), '09:05');
      expect(chartTimeValue(nine, NebaChartTimeUnit.second, names), '09:05:00');
      expect(chartTimeValue(nine, NebaChartTimeUnit.year, names), '2026');
    });
  });
}
