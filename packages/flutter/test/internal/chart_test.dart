import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
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
}
