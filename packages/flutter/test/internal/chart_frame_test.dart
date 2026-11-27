// The frame every cartesian chart stands on: the React package's
// `chart-frame.test.tsx`, and the parts of the LineChart suite that are about
// the frame rather than the line, asked the way Flutter asks them.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/chart_line.dart';

import '../support/host.dart';

int _traces = 0;

/// A frame around plain lines, counting how often the marks are traced.
Widget _chart({
  required List<NebaChartSeries> series,
  List<Object>? categories,
  Object? legend,
  Object? tooltip,
  NebaChartAxis? xAxis,
  NebaChartAxis? yAxis,
  NebaChartAxis? secondaryAxis,
  List<NebaChartReference>? references,
  String? label,
  String Function(num value)? format,
  bool stacked = false,
}) {
  return NebaCartesianChart<NebaLineTrace>(
    series: series,
    categories: categories,
    legend: legend,
    tooltip: tooltip,
    xAxis: xAxis,
    yAxis: yAxis,
    secondaryAxis: secondaryAxis,
    references: references,
    label: label,
    format: format,
    stacked: stacked,
    inset: true,
    includeZero: false,
    trace: (NebaChartLayout layout) {
      _traces += 1;

      return chartTraceLines(
        layout,
        curve: NebaChartCurve.linear,
        filled: false,
        stacked: stacked,
        connectNulls: false,
        valueLabels: NebaChartValueLabels.none,
      );
    },
    traceKey: stacked,
    painter: (NebaChartMarks<NebaLineTrace> marks) => NebaLinePainter(
      marks: marks,
      filled: false,
      stacked: stacked,
      markers: NebaChartMarkers.auto,
      gradient: false,
    ),
  );
}

const List<NebaChartSeries> _two = <NebaChartSeries>[
  NebaChartSeries(name: 'Web', data: <num>[1820, 1960, 2140]),
  NebaChartSeries(name: 'Mobile', data: <num>[940, 1120, 1310]),
];

const List<Object> _months = <Object>['Jan', 'Feb', 'Mar'];

Finder _plot() => find.bySemanticsLabel('Weekly active users').first;

Finder _entry(String name) {
  return find.descendant(of: find.byType(NebaChartLegendBar), matching: find.text(name));
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

  Offset column(WidgetTester tester, int index, int count) {
    final Rect box = tester.getRect(find.byType(NebaChartBox));
    final NebaChartLayout layout = _layoutOf(tester);

    return box.topLeft + Offset(layout.plot.left + layout.categoryPx(index), layout.plot.center.dy);
  }

  group('the plot', () {
    testWidgets('is an image named by its label and described by one sentence', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, _chart(series: _two, categories: _months, label: 'Weekly active users'));

      expect(
        tester.getSemantics(_plot()),
        matchesSemantics(
          label: 'Weekly active users',
          hint: 'Data points: 6. Range: 940 to 2,140.',
          isImage: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('names itself when no label was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, _chart(series: _two, categories: _months));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('shows the empty state rather than an axis when there is nothing to draw', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(data: <num?>[null, null]),
          ],
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byType(NebaChartDataTable), findsNothing);
    });

    testWidgets('is as tall as the size ladder says, the legend outside it', (
      WidgetTester tester,
    ) async {
      await pump(tester, _chart(series: _two, categories: _months));

      expect(tester.getSize(find.byType(NebaChartBox)).height, chartPlotHeights[NebaSize.md]);
      expect(
        tester.getSize(find.byType(NebaCartesianChart<NebaLineTrace>)).height,
        greaterThan(220),
      );
    });
  });

  group('the table', () {
    testWidgets('writes the categories and the values, and leaves a gap empty', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Web', data: <num?>[1820, null, 2140]),
          ],
          categories: _months,
          label: 'Weekly active users',
        ),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.caption, 'Weekly active users');
      expect(table.columns, <String>['', 'Web']);
      expect(table.rows, <List<String>>[
        <String>['Jan', '1,820'],
        <String>['Feb', ''],
        <String>['Mar', '2,140'],
      ]);
    });

    testWidgets('reads as a table with its header cells', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, _chart(series: _two, categories: _months, label: 'Users'));

      // The legend names the series first; the table's header comes after it.
      final SemanticsNode header = tester.getSemantics(find.bySemanticsLabel('Mobile').last);

      expect(header.getSemanticsData().role, SemanticsRole.columnHeader);
      expect(
        tester.getSemantics(find.bySemanticsLabel('1,960')).getSemanticsData().role,
        SemanticsRole.cell,
      );

      semantics.dispose();
    });

    testWidgets('passes format through to the table', (WidgetTester tester) async {
      await pump(
        tester,
        _chart(series: _two, categories: _months, format: (num value) => '\$$value'),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.rows.first, <String>['Jan', r'$1820', r'$940']);
    });

    testWidgets('fills the rows of a long series in after the first frame', (
      WidgetTester tester,
    ) async {
      final List<num> long = <num>[for (int index = 0; index < 600; index++) index];

      await pump(
        tester,
        _chart(
          series: <NebaChartSeries>[NebaChartSeries(name: 'Load', data: long)],
        ),
      );

      expect(find.text('599'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('599'), findsWidgets);
    });

    testWidgets('reads a named reference out with the data', (WidgetTester tester) async {
      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          references: const <NebaChartReference>[
            NebaChartReference(value: 2500, label: 'Target'),
            NebaChartReference(
              value: 1,
              to: 2,
              axis: NebaChartReferenceAxis.category,
              label: 'Promo',
            ),
          ],
        ),
      );

      expect(find.text('Target: 2,500'), findsOneWidget);
      expect(find.text('Promo: Feb–Mar'), findsOneWidget);
    });
  });

  group('the legend', () {
    testWidgets('is left off for a single series and listed from two up, pressed', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, _chart(series: _two.sublist(0, 1), categories: _months));
      expect(find.byType(NebaChartLegendBar), findsNothing);

      await pump(tester, _chart(series: _two, categories: _months));
      expect(find.byType(NebaChartLegendBar), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Web').first),
        matchesSemantics(
          label: 'Web',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('hides a series when its entry is pressed, and keeps it in the list', (
      WidgetTester tester,
    ) async {
      await pump(tester, _chart(series: _two, categories: _months));
      await tester.tap(_entry('Mobile'));
      await tester.pump();

      expect(_layoutOf(tester).visible, <bool>[true, false]);
      expect(_entry('Mobile'), findsWidgets);

      // The scale is measured on what is shown.
      expect(_layoutOf(tester).scale.min, greaterThan(1000));

      await tester.tap(_entry('Mobile'));
      await tester.pump();

      expect(_layoutOf(tester).visible, <bool>[true, true]);
    });

    testWidgets('keeps the same series hidden when new data reorders the series', (
      WidgetTester tester,
    ) async {
      await pump(tester, _chart(series: _two, categories: _months));
      await tester.tap(_entry('Mobile'));
      await tester.pump();
      await pump(tester, _chart(series: <NebaChartSeries>[_two[1], _two[0]], categories: _months));

      expect(_layoutOf(tester).visible, <bool>[false, true]);
    });

    testWidgets('keeps each series its colour when another is hidden', (WidgetTester tester) async {
      await pump(tester, _chart(series: _two, categories: _months));

      final List<Color> before = _layoutOf(tester).colors;

      await tester.tap(_entry('Web'));
      await tester.pump();

      expect(_layoutOf(tester).colors, before);
      expect(before[1], NebaTokens.light().chart.series[1]);
    });

    testWidgets('starts a series hidden when it says so, and can be turned off', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Web', data: <num>[1, 2, 3]),
            NebaChartSeries(name: 'Mobile', data: <num>[3, 2, 1], hidden: true),
          ],
        ),
      );

      expect(_layoutOf(tester).visible, <bool>[true, false]);

      await pump(tester, _chart(series: _two, legend: false));

      expect(find.byType(NebaChartLegendBar), findsNothing);
    });

    testWidgets('fades the other series while one entry is pointed at, and lands at once '
        'under reduced motion', (WidgetTester tester) async {
      await pump(tester, _chart(series: _two, categories: _months), reduced: true);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(_entry('Web')));
      await tester.pump();

      final NebaChartEmphasis emphasis = _emphasisOf(tester);

      expect(emphasis.opacityOf(0), 1);
      expect(emphasis.opacityOf(1), chartDimmedOpacity);

      await mouse.moveTo(Offset.zero);
      await tester.pump();

      expect(emphasis.opacityOf(1), 1);
    });

    testWidgets('eases the fade over the house duration otherwise', (WidgetTester tester) async {
      await pump(tester, _chart(series: _two, categories: _months));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(_entry('Web')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));

      final double midway = _emphasisOf(tester).opacityOf(1);

      expect(midway, lessThan(1));
      expect(midway, greaterThan(chartDimmedOpacity));

      await tester.pumpAndSettle();

      expect(_emphasisOf(tester).opacityOf(1), chartDimmedOpacity);
    });
  });

  group('the tooltip', () {
    testWidgets('opens on an arrow key, names the category and reads it out', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, _chart(series: _two, categories: _months, label: 'Weekly active users'));

      _focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsOneWidget);
      expect(
        tester.widget<NebaChartTooltipPanel>(find.byType(NebaChartTooltipPanel)).heading,
        'Jan',
      );
      expect(find.bySemanticsLabel('Jan, Web: 1,820, Mobile: 940'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(
        tester.widget<NebaChartTooltipPanel>(find.byType(NebaChartTooltipPanel)).heading,
        'Mar',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(NebaChartTooltipPanel), findsNothing);

      semantics.dispose();
    });

    testWidgets('follows the pointer across the columns without tracing the marks again', (
      WidgetTester tester,
    ) async {
      await pump(tester, _chart(series: _two, categories: _months));

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      _traces = 0;

      for (int index = 0; index < 3; index++) {
        await mouse.moveTo(column(tester, index, 3));
        await tester.pump();

        expect(
          tester.widget<NebaChartTooltipPanel>(find.byType(NebaChartTooltipPanel)).heading,
          _months[index],
        );
      }

      expect(_traces, 0);

      await mouse.moveTo(Offset.zero);
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });

    testWidgets('narrows to the nearest series in item mode', (WidgetTester tester) async {
      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          tooltip: const NebaChartTooltip(mode: NebaChartTooltipMode.item),
        ),
      );

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      final Rect box = tester.getRect(find.byType(NebaChartBox));
      final NebaChartLayout layout = _layoutOf(tester);

      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(box.topLeft + layout.point(1, 1120, 1));
      await tester.pump();

      final NebaChartTooltipPanel panel = tester.widget(find.byType(NebaChartTooltipPanel));

      expect(panel.items.map((NebaChartTooltipItem item) => item.name), <String>['Mobile']);
    });

    testWidgets('pins a reading on a tap and puts it down on a press elsewhere', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          Column(
            children: <Widget>[
              SizedBox(
                width: 480,
                child: _chart(series: _two, categories: _months),
              ),
              const SizedBox(height: 40, width: 40, child: Text('Elsewhere')),
            ],
          ),
        ),
      );

      await tester.tapAt(column(tester, 2, 3));
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsOneWidget);

      await tester.tap(find.text('Elsewhere'));
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });

    testWidgets('reads nothing out when it is turned off', (WidgetTester tester) async {
      await pump(tester, _chart(series: _two, categories: _months, tooltip: false));

      _focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });

    testWidgets('draws a panel of the caller’s own from its builder', (WidgetTester tester) async {
      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          tooltip: NebaChartTooltip(
            builder: (BuildContext context, NebaChartTooltipContext reading) {
              return Text('At ${reading.category}: ${reading.items.length}');
            },
          ),
        ),
      );

      _focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(find.text('At Jan: 2'), findsOneWidget);
    });
  });

  group('the axes', () {
    testWidgets('writes each tick through tickFormat, and keeps both ends of a pinned scale', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Uptime', data: <num>[99.94, 99.72, 99.99]),
          ],
          yAxis: NebaChartAxis(
            min: 99.5,
            max: 100,
            tickCount: 5,
            tickFormat: (Object value, int index) => '$value%',
          ),
        ),
      );

      final List<String> labels = _labelsOf(tester);

      expect(labels, contains('99.5%'));
      expect(labels, contains('100%'));
    });

    testWidgets('drops the labels of a hidden axis and gives its band back to the plot', (
      WidgetTester tester,
    ) async {
      await pump(tester, _chart(series: _two, categories: _months));

      final double width = _layoutOf(tester).plot.width;

      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          xAxis: const NebaChartAxis(hidden: true),
          yAxis: const NebaChartAxis(hidden: true),
        ),
      );

      expect(_labelsOf(tester), isEmpty);
      expect(_layoutOf(tester).plot.width, greaterThan(width));
    });

    testWidgets('writes the value axis name above the plot, inside the box', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          yAxis: const NebaChartAxis(label: 'Users'),
        ),
      );

      expect(_labelsOf(tester), contains('Users'));
      expect(_layoutOf(tester).plot.top, greaterThan(chartMarkerRadii[NebaSize.md]! + 4));
    });

    testWidgets('turns the category labels by tickAngle and keeps long names whole', (
      WidgetTester tester,
    ) async {
      const List<Object> stages = <Object>[
        'Signed up',
        'Email verified',
        'Team invited',
        'Repo connected',
        'PR opened',
        'PR merged',
        'Deployed',
      ];
      const List<NebaChartSeries> reached = <NebaChartSeries>[
        NebaChartSeries(name: 'Accounts', data: <num>[4820, 4110, 2640, 2190, 1480, 1120, 640]),
      ];

      await pump(tester, _chart(series: reached, categories: stages));

      expect(_labelsOf(tester), isNot(contains('Email verified')));

      await pump(
        tester,
        _chart(series: reached, categories: stages, xAxis: const NebaChartAxis(tickAngle: -45)),
      );

      final List<NebaChartLabel> turned = _chromeLabels(
        tester,
      ).where((NebaChartLabel label) => label.angle == -45).toList();

      expect(turned, hasLength(7));
      expect(_labelsOf(tester), contains('Email verified'));
    });

    testWidgets('widens the scale to hold a reference past the data', (WidgetTester tester) async {
      await pump(
        tester,
        _chart(
          series: _two,
          categories: _months,
          references: const <NebaChartReference>[NebaChartReference(value: 5000, label: 'Goal')],
        ),
      );

      expect(_layoutOf(tester).scale.max, greaterThanOrEqualTo(5000));
      expect(_labelsOf(tester), contains('Goal'));
    });

    testWidgets('measures a series on the far edge against a scale of its own', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Revenue', data: <num>[182000, 196000, 214000]),
            NebaChartSeries(
              name: 'Conversion',
              data: <num>[2.4, 2.6, 2.5],
              axis: NebaChartSeriesAxis.secondary,
            ),
          ],
          categories: _months,
          secondaryAxis: NebaChartAxis(
            label: 'Conversion',
            tickFormat: (Object value, int index) => '$value%',
          ),
        ),
      );

      final NebaChartLayout layout = _layoutOf(tester);

      expect(layout.secondScale, isNotNull);
      expect(layout.secondScale!.ticks, hasLength(layout.scale.ticks.length));
      expect(layout.valuePx(2.5, 1), inInclusiveRange(layout.plot.top, layout.plot.bottom));
      expect(layout.formatFor(1)(2.5), '2.5%');

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.rows.first, <String>['Jan', '182K', '2.4%']);
    });

    testWidgets('puts everything back on one scale when the chart stacks', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        _chart(
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'A', data: <num>[1, 2]),
            NebaChartSeries(name: 'B', data: <num>[3, 4], axis: NebaChartSeriesAxis.secondary),
          ],
          secondaryAxis: const NebaChartAxis(),
          stacked: true,
        ),
      );

      expect(_layoutOf(tester).secondScale, isNull);
    });
  });

  testWidgets('answers a parent that measures it before laying it out', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      IntrinsicHeight(
        child: _chart(series: _two, categories: _months),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

NebaChartLayout _layoutOf(WidgetTester tester) {
  final NebaLinePainter painter = tester
      .widgetList<CustomPaint>(
        find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)),
      )
      .map((CustomPaint paint) => paint.painter)
      .whereType<NebaLinePainter>()
      .single;

  return painter.marks.layout;
}

NebaChartEmphasis _emphasisOf(WidgetTester tester) {
  final NebaLinePainter painter = tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((CustomPaint paint) => paint.painter)
      .whereType<NebaLinePainter>()
      .single;

  return painter.marks.emphasis;
}

FocusNode _focusOf(WidgetTester tester) {
  final Focus focus = tester.widget<Focus>(
    find.ancestor(of: find.byType(NebaChartBox), matching: find.byType(Focus)).first,
  );

  return focus.focusNode!;
}

List<NebaChartLabel> _chromeLabels(WidgetTester tester) {
  final RenderObject chrome = tester.renderObject(
    find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)).first,
  );
  final List<NebaChartLabel> labels = <NebaChartLabel>[];
  final dynamic painter = (chrome as RenderCustomPaint).painter;

  for (final Object op in (painter.model.chrome as List<Object>)) {
    if (op is NebaChartLabel) {
      labels.add(op);
    }
  }

  return labels;
}

List<String> _labelsOf(WidgetTester tester) {
  return <String>[
    for (final NebaChartLabel label in _chromeLabels(tester)) label.painter.plainText,
  ];
}
