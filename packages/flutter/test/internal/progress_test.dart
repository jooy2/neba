// The arithmetic the progress widgets share, checked directly: what a value
// means as a fraction, what a reading says, which family a reading has
// earned, and where a cycle stands at a moment.

import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/progress.dart';

void main() {
  group('progressFraction', () {
    test('is the share of the range, not of 100', () {
      expect(progressFraction(3, 0, 4), 0.75);
      expect(progressFraction(15, 10, 20), 0.5);
    });

    test('is null with no value, a value that is not a finite number, or an empty range', () {
      expect(progressFraction(null, 0, 100), isNull);
      expect(progressFraction(double.nan, 0, 100), isNull);
      expect(progressFraction(double.infinity, 0, 100), isNull);
      expect(progressFraction(0, 0, 0), isNull);
      expect(progressFraction(5, 10, 0), isNull);
      expect(progressFraction(5, 0, double.nan), isNull);
    });

    test('holds a value past either end of the range to it', () {
      expect(progressFraction(140, 0, 100), 1);
      expect(progressFraction(-20, 0, 100), 0);
    });
  });

  group('progressText', () {
    test('writes the share of the range as a whole percent', () {
      expect(progressText(fraction: 0.75, value: 3, min: 0, max: 4), '75%');
      expect(progressText(fraction: 0.005, value: 0.5, min: 0, max: 100), '1%');
    });

    test('says nothing without a fraction', () {
      expect(progressText(fraction: null, value: null, min: 0, max: 100), isNull);
    });

    test("hands a caller's format the value held to the range", () {
      final List<double> handed = <double>[];
      String format(double value) {
        handed.add(value);
        return '${value.round()} MB';
      }

      expect(
        progressText(fraction: 0.3, value: 1200, min: 0, max: 4000, format: format),
        '1200 MB',
      );
      expect(progressText(fraction: 1, value: 5000, min: 0, max: 4000, format: format), '4000 MB');
      expect(handed, <double>[1200, 4000]);
    });
  });

  group('progressClamp', () {
    test('holds a value to the range, answers min for one that is not a number', () {
      expect(progressClamp(120, 0, 100), 100);
      expect(progressClamp(-1, 0, 100), 0);
      expect(progressClamp(double.nan, 10, 100), 10);
    });

    test('does not throw on a range that runs backwards', () {
      expect(progressClamp(5, 10, 0), 0);
    });
  });

  group('thresholdColor', () {
    const List<NebaThreshold> thresholds = <NebaThreshold>[
      NebaThreshold(from: 70, color: NebaColor.warning),
      NebaThreshold(from: 90, color: NebaColor.danger),
    ];

    test('keeps its own colour below every threshold, and with none', () {
      expect(thresholdColor(40, NebaColor.primary, thresholds), NebaColor.primary);
      expect(thresholdColor(40, NebaColor.success, null), NebaColor.success);
      expect(thresholdColor(40, NebaColor.success, const <NebaThreshold>[]), NebaColor.success);
    });

    test('takes the family of the last threshold the value has reached', () {
      expect(thresholdColor(70, NebaColor.primary, thresholds), NebaColor.warning);
      expect(thresholdColor(95, NebaColor.primary, thresholds), NebaColor.danger);
    });

    test('reads the thresholds in the order they were given', () {
      final List<NebaThreshold> backwards = thresholds.reversed.toList();

      expect(thresholdColor(95, NebaColor.primary, backwards), NebaColor.warning);
    });
  });

  group('progressPhase', () {
    const Duration period = Duration(milliseconds: 1000);

    test('runs from 0 to 1 over a period and starts again', () {
      expect(progressPhase(Duration.zero, period), 0);
      expect(progressPhase(const Duration(milliseconds: 250), period), 0.25);
      expect(progressPhase(const Duration(milliseconds: 1250), period), 0.25);
    });

    test('waits out a delay before it starts', () {
      const Duration delay = Duration(milliseconds: 360);

      expect(progressPhase(const Duration(milliseconds: 100), period, delay: delay), isNull);
      expect(progressPhase(const Duration(milliseconds: 360), period, delay: delay), 0);
      expect(progressPhase(const Duration(milliseconds: 610), period, delay: delay), 0.25);
    });
  });

  group('progressKeyframe', () {
    const List<double> stops = <double>[0, 0.35, 0.7, 1];

    test('finds the span a point is in', () {
      expect(progressKeyframe(0.1, stops).span, 0);
      expect(progressKeyframe(0.35, stops).span, 1);
      expect(progressKeyframe(0.8, stops).span, 2);
      expect(progressKeyframe(1, stops).span, 2);
    });

    test('eases each span on its own, from its start to its end', () {
      expect(progressKeyframe(0, stops).t, 0);
      expect(progressKeyframe(0.35, stops).t, 0);
      expect(progressKeyframe(0.7, stops).t, 0);
      expect(progressKeyframe(1, stops).t, moreOrLessEquals(1));

      // Halfway through a span is past halfway once the house curve, which
      // starts fast, has eased it.
      expect(progressKeyframe(0.175, stops).t, greaterThan(0.5));
    });
  });
}
