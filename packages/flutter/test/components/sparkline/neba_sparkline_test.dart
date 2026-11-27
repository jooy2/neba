// NebaSparkline: the suite the React package runs on Sparkline, asked the way
// Flutter asks it — the paths and circles a painter actually draws instead of
// the SVG elements, and what a screen reader is told instead of `role="img"`.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';

import '../../support/host.dart';

/// Every call the strip's painter makes, as the method and its arguments.
List<(Symbol, List<dynamic>)> _calls(WidgetTester tester) {
  final List<(Symbol, List<dynamic>)> calls = <(Symbol, List<dynamic>)>[];
  final RenderObject strip = tester.renderObject(
    find.descendant(of: find.byType(NebaSparkline), matching: find.byType(CustomPaint)),
  );

  expect(
    strip,
    paints..everything((Symbol method, List<dynamic> arguments) {
      calls.add((method, arguments));
      return true;
    }),
  );

  return calls;
}

List<Path> _paths(WidgetTester tester, {PaintingStyle? style}) {
  return <Path>[
    for (final (Symbol method, List<dynamic> arguments) in _calls(tester))
      if (method == #drawPath && (style == null || (arguments[1] as Paint).style == style))
        arguments[0] as Path,
  ];
}

int _runs(Path path) => path.computeMetrics().length;

void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 200, child: child))));
  }

  group('rendering', () {
    testWidgets('draws a single stroked path for a line', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num>[1, 3, 2, 5]));

      final List<Path> paths = _paths(tester);

      expect(paths, hasLength(1));
      expect(_runs(paths.single), 1);
    });

    testWidgets('adds a fill under an area', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSparkline(data: <num>[1, 3, 2, 5], shape: NebaSparklineShape.area),
      );

      expect(_paths(tester, style: PaintingStyle.fill), hasLength(1));
      expect(_paths(tester, style: PaintingStyle.stroke), hasLength(1));
    });

    testWidgets('draws one path per bar, and none for a gap', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSparkline(data: <num?>[1, 3, null, 5], shape: NebaSparklineShape.bar),
      );

      expect(_paths(tester), hasLength(3));
    });

    testWidgets('adds a dot at the end when asked', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num?>[1, 3, 2, null], endDot: true));

      final List<List<dynamic>> circles = <List<dynamic>>[
        for (final (Symbol method, List<dynamic> arguments) in _calls(tester))
          if (method == #drawCircle) arguments,
      ];

      // The fill and its ring, on the last point that has a value.
      expect(circles, hasLength(2));
      expect((circles.first[0] as Offset).dx, closeTo(200 * 2 / 3, 0.01));
    });

    testWidgets('adds a rule at the baseline', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num>[1, 3, 2, 5], baseline: 2));

      final NebaTokens tokens = NebaTokens.light();

      expect(
        find.descendant(of: find.byType(NebaSparkline), matching: find.byType(CustomPaint)),
        paints..line(color: tokens.chartBaseline),
      );
    });

    testWidgets('breaks the line at a gap rather than drawing a zero', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num?>[1, 3, null, 2, 5]));

      final Path line = _paths(tester).single;

      expect(_runs(line), 2);
      // The lowest point is the lowest value, half a stroke off the floor, and
      // not a nought at the gap.
      expect(line.getBounds().bottom, closeTo(27, 0.01));
    });

    testWidgets('bridges the gap with nulls: connect', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaSparkline(data: <num?>[1, 3, null, 2, 5], nulls: NebaChartNulls.connect),
      );

      expect(_runs(_paths(tester).single), 1);
    });

    testWidgets('reads the gap as a nought everywhere with nulls: zero', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSparkline(
          data: <num?>[1, 3, null, 2, 5],
          nulls: NebaChartNulls.zero,
          label: 'Readings',
        ),
      );

      expect(_runs(_paths(tester).single), 1);
      expect(find.text('1, 3, 0, 2, 5'), findsOneWidget);
    });

    testWidgets('reflects changed data on a rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num>[1, 2], label: 'Trend'));
      expect(find.text('1, 2'), findsOneWidget);

      await pump(tester, const NebaSparkline(data: <num>[5, 4, 3], label: 'Trend'));
      expect(find.text('5, 4, 3'), findsOneWidget);
    });

    testWidgets('fills its parent, or the width it is given', (WidgetTester tester) async {
      await pump(tester, const NebaSparkline(data: <num>[1, 2, 3]));
      expect(tester.getSize(find.byType(NebaSparkline)), const Size(200, 28));

      await pump(tester, const NebaSparkline(data: <num>[1, 2, 3], width: 80));
      expect(tester.getSize(find.byType(CustomPaint).last).width, 80);
    });

    testWidgets('is as tall as its size says, against the line of text', (
      WidgetTester tester,
    ) async {
      for (final NebaSize size in NebaSize.values) {
        await pump(tester, NebaSparkline(data: const <num>[1, 2], size: size));

        expect(tester.getSize(find.byType(NebaSparkline)).height, sparklineHeights[size]);
      }
    });

    testWidgets('draws in its colour, a family or a colour of its own', (
      WidgetTester tester,
    ) async {
      final NebaTokens tokens = NebaTokens.light();

      await pump(tester, const NebaSparkline(data: <num>[1, 2], color: NebaColor.danger));
      expect(
        find.descendant(of: find.byType(NebaSparkline), matching: find.byType(CustomPaint)),
        paints..path(color: tokens.roles(NebaColor.danger).accent),
      );

      await pump(tester, const NebaSparkline(data: <num>[1, 2]));
      expect(
        find.descendant(of: find.byType(NebaSparkline), matching: find.byType(CustomPaint)),
        paints..path(color: tokens.chart.series.first),
      );
    });
  });

  group('scale', () {
    testWidgets('keeps the bars of an all-negative strip inside the box', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaSparkline(data: <num>[-4, -2, -6], shape: NebaSparklineShape.bar),
      );

      for (final Path bar in _paths(tester)) {
        expect(bar.getBounds().top, greaterThanOrEqualTo(0));
        expect(bar.getBounds().bottom, lessThanOrEqualTo(28 + 0.01));
      }
    });

    testWidgets('draws equal bars at full height rather than as one pixel', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSparkline(data: <num>[3, 3, 3], shape: NebaSparklineShape.bar));

      for (final Path bar in _paths(tester)) {
        expect(bar.getBounds().height, closeTo(28, 0.01));
      }
    });

    testWidgets('puts a level line in the middle of the strip rather than on its floor', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSparkline(data: <num>[5, 5, 5]));

      expect(_paths(tester).single.getBounds().center.dy, closeTo(14, 0.01));
    });

    testWidgets('draws two strips on one scale when they share their ends', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaSparkline(data: <num>[10, 20], min: 0, max: 40));

      // Half the stroke and nothing else comes off each end of the band.
      final Rect bounds = _paths(tester).single.getBounds();
      const double usable = 28 - 2;

      expect(bounds.bottom, closeTo(1 + usable * 0.75, 0.01));
      expect(bounds.top, closeTo(1 + usable * 0.5, 0.01));
    });
  });

  group('accessibility', () {
    testWidgets('is an image of its label, with its values read after it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaSparkline(data: <num?>[18, null, 19.5], label: 'Signups, last 12 weeks'),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Signups, last 12 weeks')),
        matchesSemantics(label: 'Signups, last 12 weeks', isImage: true),
      );
      expect(find.bySemanticsLabel('18, —, 19.5'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('is hidden entirely without one', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaSparkline(data: <num>[18, 22, 19]));

      expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
      expect(find.text('18, 22, 19'), findsNothing);

      semantics.dispose();
    });
  });

  testWidgets('takes its size from NebaProvider when it has none', (WidgetTester tester) async {
    await pump(
      tester,
      const NebaProvider(
        defaults: NebaDefaults(size: NebaSize.xl),
        child: NebaSparkline(data: <num>[1, 2]),
      ),
    );

    expect(tester.getSize(find.byType(NebaSparkline)).height, sparklineHeights[NebaSize.xl]);
  });

  testWidgets('answers a parent that measures it before laying it out', (
    WidgetTester tester,
  ) async {
    await pump(tester, const IntrinsicHeight(child: NebaSparkline(data: <num>[1, 2])));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(NebaSparkline)).height, 28);
  });
}
