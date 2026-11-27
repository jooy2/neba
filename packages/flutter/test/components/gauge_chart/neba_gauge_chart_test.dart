// NebaGaugeChart: the React package's GaugeChart suite, asked the way Flutter
// asks it — the groove, the stroke and the marks the painter draws instead of
// SVG paths, the reading as a real `Text`, and a node with a label and a value
// instead of `role="meter"`.

import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';

import '../../support/host.dart';

Finder _dial() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_GaugePainter',
  );
}

dynamic _painter(WidgetTester tester) => tester.widget<CustomPaint>(_dial()).painter;

List<NebaChartLabel> _ends(WidgetTester tester) {
  return <NebaChartLabel>[..._painter(tester).ends as List<NebaChartLabel>];
}

/// Every call the dial's painter makes, as the method and its arguments.
List<(Symbol, List<dynamic>)> _calls(WidgetTester tester) {
  final List<(Symbol, List<dynamic>)> calls = <(Symbol, List<dynamic>)>[];

  expect(
    tester.renderObject(_dial()),
    paints..everything((Symbol method, List<dynamic> arguments) {
      calls.add((method, arguments));
      return true;
    }),
  );

  return calls;
}

int _count(WidgetTester tester, Symbol method) {
  return _calls(tester).where(((Symbol, List<dynamic>) call) => call.$1 == method).length;
}

double _fontSizeOf(WidgetTester tester, String text) {
  return tester.renderObject<RenderParagraph>(find.text(text)).text.style!.fontSize!;
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget gauge, {double width = 320}) {
    return tester.pumpWidget(
      host(
        Center(
          child: SizedBox(width: width, child: gauge),
        ),
      ),
    );
  }

  group('rendering', () {
    testWidgets('draws the reading as real text', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 64, label: 'CPU'));

      expect(find.text('64'), findsOneWidget);
    });

    testWidgets('is a meter named by its label, its value the reading', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaGaugeChart(value: 64, label: 'CPU'));

      expect(
        tester.getSemantics(find.bySemanticsLabel('CPU')),
        matchesSemantics(label: 'CPU', value: '64'),
      );

      semantics.dispose();
    });

    testWidgets('states a reading below zero with the caption after it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaGaugeChart(
          value: 0,
          min: -50,
          max: 50,
          caption: Text('degrees'),
          label: 'Offset',
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Offset')),
        matchesSemantics(label: 'Offset', value: '0 degrees'),
      );
      // Half way round a scale that starts below zero.
      expect(_painter(tester).fraction as double, closeTo(0.5, 1e-9));

      semantics.dispose();
    });

    testWidgets('is a plain box without a label, its reading read as text', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaGaugeChart(value: 64, caption: Text('of 8 vCPU')));

      expect(find.bySemanticsLabel('64'), findsOneWidget);
      expect(find.bySemanticsLabel('of 8 vCPU'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('writes the two ends of the scale', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 5, max: 8, label: 'Seats'));

      expect(
        <String>[for (final NebaChartLabel end in _ends(tester)) end.painter.plainText],
        <String>['0', '8'],
      );
    });

    testWidgets('leaves them off when asked', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 5, max: 8, showRange: false));

      expect(_ends(tester), isEmpty);
    });

    testWidgets('writes the value through format', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGaugeChart(value: 0.62, max: 1, format: (num value) => '${(value * 100).round()}%'),
      );

      expect(find.text('62%'), findsOneWidget);
      expect(
        <String>[for (final NebaChartLabel end in _ends(tester)) end.painter.plainText],
        <String>['0%', '100%'],
      );
    });

    testWidgets('takes a caption under the value', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 64, caption: Text('of 8 vCPU')));

      expect(find.text('of 8 vCPU'), findsOneWidget);
      expect(
        tester.getCenter(find.text('of 8 vCPU')).dy,
        greaterThan(tester.getCenter(find.text('64')).dy),
      );
    });

    testWidgets('takes something else in the middle entirely', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 64, center: Text('Healthy')));

      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('64'), findsNothing);
    });

    testWidgets('reflects a changed reading on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 64, label: 'CPU'));
      await pump(tester, const NebaGaugeChart(value: 91, label: 'CPU'));

      expect(find.text('91'), findsOneWidget);
    });

    testWidgets('takes its size and variant from NebaProvider when it has none', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.lg),
          child: NebaGaugeChart(value: 64),
        ),
      );

      expect(tester.getSize(find.byType(NebaChartBox)).height, 280);
    });
  });

  group('no reading', () {
    testWidgets('draws a dash rather than a zero, and only the groove', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: null, label: 'CPU'));

      expect(find.text('—'), findsOneWidget);
      expect(_count(tester, #drawPath), 1);
    });

    testWidgets('names itself with nothing but the label', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaGaugeChart(value: null, label: 'CPU'));

      expect(
        tester.getSemantics(find.bySemanticsLabel('CPU')),
        matchesSemantics(label: 'CPU', isImage: true),
      );

      semantics.dispose();
    });

    testWidgets('shows the empty state when the scale has no range', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 4, min: 4, max: 4, empty: Text('No scale')));

      expect(find.text('No scale'), findsOneWidget);
      expect(_dial(), findsNothing);
    });
  });

  group('thresholds', () {
    const List<NebaThreshold> thresholds = <NebaThreshold>[
      NebaThreshold(from: 70, color: NebaColor.warning),
      NebaThreshold(from: 90, color: NebaColor.danger),
    ];

    testWidgets('keeps its own family below every threshold', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 40, thresholds: thresholds));

      expect(_painter(tester).fill, tokens.roles(NebaColor.primary).fill);
      // The groove is the dial's own family whatever the reading has reached.
      expect(_painter(tester).track, tokens.roles(NebaColor.primary).soft);
    });

    testWidgets('takes the family of the last one it has reached', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 95, thresholds: thresholds));

      expect(_painter(tester).fill, tokens.roles(NebaColor.danger).fill);
      expect(_painter(tester).track, tokens.roles(NebaColor.primary).soft);
    });
  });

  group('the reading', () {
    double drawn(WidgetTester tester) {
      final List<(Symbol, List<dynamic>)> strokes = <(Symbol, List<dynamic>)>[
        for (final (Symbol, List<dynamic>) call in _calls(tester))
          if (call.$1 == #drawPath && (call.$2[1] as Paint).style == PaintingStyle.stroke) call,
      ];

      if (strokes.isEmpty) {
        return 0;
      }

      return (strokes.single.$2[0] as Path).computeMetrics().fold<double>(
        0,
        (double sum, PathMetric one) => sum + one.length,
      );
    }

    testWidgets('sweeps to a new value along the arc rather than jumping to it', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: 25, label: 'CPU'));

      expect(_painter(tester).fraction as double, closeTo(0.25, 1e-9));
      final double quarter = drawn(tester);

      await pump(tester, const NebaGaugeChart(value: 80, label: 'CPU'));
      await tester.pump(const Duration(milliseconds: 100));

      final double midway = _painter(tester).fraction as double;

      expect(midway, greaterThan(0.25));
      expect(midway, lessThan(0.8));

      await tester.pumpAndSettle();

      expect(_painter(tester).fraction as double, closeTo(0.8, 1e-9));
      // The same arc, drawn further along: what changed is how much of it.
      expect(drawn(tester) / quarter, closeTo(0.8 / 0.25, 0.01));
    });

    testWidgets('draws none of the arc at zero, and all of it at full', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: 0, label: 'CPU'));

      expect(drawn(tester), 0);

      await pump(tester, const NebaGaugeChart(value: 100, label: 'CPU'));
      await tester.pumpAndSettle();

      final dynamic dial = _painter(tester).dial;
      final double middle = ((dial.outer as double) + (dial.inner as double)) / 2;

      // Half a turn of the circle through the middle of the band.
      expect(drawn(tester), closeTo(middle * 3.14159265, 0.5));
    });

    testWidgets('lands at once when the platform asks for less motion', (
      WidgetTester tester,
    ) async {
      Future<void> reduced(double value) {
        return tester.pumpWidget(
          host(
            Center(
              child: SizedBox(width: 320, child: NebaGaugeChart(value: value)),
            ),
            disableAnimations: true,
          ),
        );
      }

      await reduced(10);
      await reduced(90);
      await tester.pump();

      expect(_painter(tester).fraction as double, closeTo(0.9, 1e-9));
    });
  });

  group('fitting the box', () {
    testWidgets('keeps the range labels inside the box', (WidgetTester tester) async {
      await pump(
        tester,
        NebaGaugeChart(
          value: 0.38,
          max: 1,
          format: (num value) => '${(value * 100).round()} percent of capacity',
          label: 'CPU',
        ),
      );

      final double width = tester.getSize(find.byType(NebaChartBox)).width;
      final List<NebaChartLabel> ends = _ends(tester);

      expect(ends, hasLength(2));

      // Measured by the estimate the dial is sized with, as React measures it:
      // the test font's glyphs are a whole em wide, which no real font is.
      for (final NebaChartLabel end in ends) {
        final double estimate = chartTextWidth(end.painter.plainText, chartFontSizes[NebaSize.md]!);
        final double left = end.at.dx - estimate * (end.anchor == 0 ? 0.5 : 0);

        expect(end.painter.plainText, endsWith('…'));
        expect(left, greaterThanOrEqualTo(-0.5));
        expect(left + estimate, lessThanOrEqualTo(width + 0.5));
      }
    });

    testWidgets('writes no range on a closed ring, where the two ends are one point', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: 64, sweep: 360, label: 'CPU'));

      expect(_ends(tester), isEmpty);
    });

    testWidgets('sets the ends of an instrument dial outward, below them', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: 64, sweep: 270));

      final List<NebaChartLabel> ends = _ends(tester);
      final dynamic dial = _painter(tester).dial;

      expect(ends.first.anchor, -1);
      expect(ends.last.anchor, 1);
      expect(ends.first.at.dy, greaterThan((dial.centre as Offset).dy));
    });

    testWidgets('shrinks a long reading rather than running it over the arc', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaGaugeChart(value: 64, label: 'CPU'), width: 150);

      final double short = _fontSizeOf(tester, '64');

      await pump(
        tester,
        NebaGaugeChart(
          value: 1234567,
          max: 2000000,
          format: (num value) => value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (Match match) => '${match[1]},',
          ),
          label: 'CPU',
        ),
        width: 150,
      );

      expect(_fontSizeOf(tester, '1,234,567'), lessThan(short));
    });
  });

  group('shape', () {
    testWidgets('draws no marks unless it is asked for them', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 40, label: 'CPU'));

      expect(_count(tester, #drawLine), 0);
    });

    testWidgets('draws the marks it was asked for', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 40, ticks: 5, label: 'CPU'));

      expect(_count(tester, #drawLine), 5);
    });

    testWidgets('fills a half dial to the width of a wide box', (WidgetTester tester) async {
      await pump(tester, const NebaGaugeChart(value: 40), width: 600);

      final dynamic dial = _painter(tester).dial;
      final double height = tester.getSize(find.byType(NebaChartBox)).height;

      // As tall as the box allows rather than as wide, centred in it.
      expect(dial.outer as double, lessThan(height));
      expect(dial.outer as double, greaterThan(height * 0.6));
    });
  });
}
