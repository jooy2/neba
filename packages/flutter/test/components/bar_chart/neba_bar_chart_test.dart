// NebaBarChart: the React package's BarChart suite, asked the way Flutter asks
// it — the bars the painter lays out and draws instead of SVG paths, the
// labels on the frame's canvas instead of `<text>`, and the table the frame
// builds instead of the DOM's. The frame turned on its side is checked here
// too, since a bar chart is the one chart that turns.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/live_region.dart';

import '../../support/host.dart';

const List<Object> _teams = <Object>['Platform', 'Payments', 'Growth'];

/// A bar as the painter was handed it.
typedef _Drawn = ({int series, int category, Rect rect, Color color, NebaChartLabel? label});

Finder _marks() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_BarPainter',
  );
}

NebaChartMarks<Object?> _marksOf(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_marks()).painter;

  return painter.marks as NebaChartMarks<Object?>;
}

NebaChartLayout _layout(WidgetTester tester) => _marksOf(tester).layout;

/// Every bar laid out, series by series.
List<_Drawn> _bars(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;

  return <_Drawn>[
    for (final dynamic one in traced.series as List<dynamic>)
      for (final dynamic bar in one.bars as List<dynamic>)
        (
          series: one.index as int,
          category: bar.category as int,
          rect: bar.rect as Rect,
          color: bar.color as Color,
          label: bar.label as NebaChartLabel?,
        ),
  ];
}

List<String> _written(WidgetTester tester) {
  return <String>[
    for (final _Drawn bar in _bars(tester))
      if (bar.label case final NebaChartLabel label) label.painter.plainText,
  ];
}

/// Every filled path the painter draws, with the paint it is drawn in.
List<(Path, Paint)> _fills(WidgetTester tester) {
  final List<(Path, Paint)> paths = <(Path, Paint)>[];

  expect(
    tester.renderObject(_marks()),
    paints..everything((Symbol method, List<dynamic> arguments) {
      if (method == #drawPath && (arguments[1] as Paint).style == PaintingStyle.fill) {
        paths.add((arguments[0] as Path, arguments[1] as Paint));
      }

      return true;
    }),
  );

  return paths;
}

/// What the frame wrote on its canvas around the bars.
List<NebaChartLabel> _chrome(WidgetTester tester) {
  final RenderObject chrome = tester.renderObject(
    find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)).first,
  );
  final dynamic painter = (chrome as RenderCustomPaint).painter;

  return <NebaChartLabel>[
    for (final Object op in (painter.model.chrome as List<Object>))
      if (op is NebaChartLabel) op,
  ];
}

List<String> _chromeTexts(WidgetTester tester) {
  return <String>[for (final NebaChartLabel label in _chrome(tester)) label.painter.plainText];
}

String _readout(WidgetTester tester) {
  return tester
          .widget<Text>(
            find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(Text)),
          )
          .data ??
      '';
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget chart) {
    return tester.pumpWidget(host(Center(child: SizedBox(width: 480, child: chart))));
  }

  FocusNode focusOf(WidgetTester tester) {
    return tester
        .widget<Focus>(
          find.ancestor(of: find.byType(NebaChartBox), matching: find.byType(Focus)).first,
        )
        .focusNode!;
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);

    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    return gesture;
  }

  group('rendering', () {
    testWidgets('draws one filled path per value', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          label: 'Deploys per team',
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      expect(_fills(tester), hasLength(3));
    });

    testWidgets('draws nothing for a gap', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num?>[10, null, 30]),
          ],
        ),
      );

      expect(_fills(tester), hasLength(2));
      expect(_bars(tester).map((_Drawn bar) => bar.category), <int>[0, 2]);
    });

    testWidgets('writes its data into a table', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          label: 'Deploys per team',
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      expect(table.caption, 'Deploys per team');
      expect(table.rows[1], <String>['Payments', '20']);
    });

    testWidgets('keeps zero on its value axis and sits each bar in the middle of its band', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[98, 99, 98.5]),
          ],
        ),
      );

      final NebaChartLayout layout = _layout(tester);
      final Rect first = _bars(tester).first.rect;

      expect(layout.scale.min, 0);
      expect(first.center.dx, closeTo(layout.plot.left + layout.band.step / 2, 0.01));
      expect(first.bottom, closeTo(layout.zeroPxOf(), 0.01));
    });

    testWidgets('reflects a changed orientation on a rebuild', (WidgetTester tester) async {
      const List<NebaChartSeries> series = <NebaChartSeries>[
        NebaChartSeries(name: 'Deploys', data: <num>[1, 2, 3]),
      ];

      await pump(tester, const NebaBarChart(categories: _teams, series: series));
      expect(_bars(tester).last.rect.height, greaterThan(_bars(tester).last.rect.width));

      await pump(
        tester,
        const NebaBarChart(
          orientation: NebaOrientation.horizontal,
          categories: _teams,
          series: series,
        ),
      );

      final NebaChartLayout layout = _layout(tester);
      final List<_Drawn> bars = _bars(tester);

      expect(_fills(tester), hasLength(3));
      // Out from the start edge, one row per category, in order down the plot.
      expect(bars.last.rect.width, greaterThan(bars.last.rect.height));
      expect(bars.first.rect.left, closeTo(layout.zeroPxOf(), 0.01));
      expect(bars.first.rect.center.dy, lessThan(bars.last.rect.center.dy));
    });

    testWidgets('caps a bar at barSize and rounds only its data end', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          barSize: 10,
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[10, 20, 30]),
          ],
        ),
      );

      final Rect rect = _bars(tester).first.rect;
      final Path path = _fills(tester).first.$1;

      expect(rect.width, 10);
      // The corner at the top is cut and the one at the baseline is not.
      expect(path.contains(rect.topLeft + const Offset(0.5, 0.5)), isFalse);
      expect(path.contains(rect.bottomLeft + const Offset(0.5, -0.5)), isTrue);

      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          barSize: 10,
          rounded: false,
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[10, 20, 30]),
          ],
        ),
      );

      expect(_fills(tester).first.$1.contains(rect.topLeft + const Offset(0.5, 0.5)), isTrue);
    });

    testWidgets('splits the band between the series shown, two pixels apart', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Web', data: <num>[10, 20, 30]),
            NebaChartSeries(name: 'Mobile', data: <num>[13, 24, 35]),
          ],
        ),
      );

      final List<_Drawn> bars = _bars(tester);
      final Rect web = bars.firstWhere((_Drawn bar) => bar.series == 0).rect;
      final Rect mobile = bars.firstWhere((_Drawn bar) => bar.series == 1).rect;

      expect(mobile.left - web.right, closeTo(chartMarkGap, 0.01));
    });

    testWidgets('takes its size from NebaProvider when it has none', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaProvider(
          defaults: NebaDefaults(size: NebaSize.xs),
          child: NebaBarChart(
            series: <NebaChartSeries>[
              NebaChartSeries(data: <num>[1234.5]),
            ],
          ),
        ),
      );

      expect(tester.getSize(find.byType(NebaChartBox)).height, chartPlotHeights[NebaSize.xs]);
      expect(_layout(tester).size, NebaSize.xs);
    });
  });

  group('axes', () {
    testWidgets("writes a horizontal chart's category axis name above the plot", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          orientation: NebaOrientation.horizontal,
          xAxis: NebaChartAxis(label: 'Team'),
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[1, 2, 3]),
          ],
        ),
      );

      final List<NebaChartLabel> labels = _chrome(tester);
      final NebaChartLabel name = labels.firstWhere(
        (NebaChartLabel label) => label.painter.plainText == 'Team',
      );
      final List<NebaChartLabel> rows = <NebaChartLabel>[
        for (final NebaChartLabel label in labels)
          if (_teams.contains(label.painter.plainText)) label,
      ];

      expect(name.at.dy, greaterThan(0));
      expect(rows, hasLength(3));
      // Each name on a row of its own, ending at the plot's start edge.
      for (final NebaChartLabel row in rows) {
        expect(row.anchor, -1);
        expect(row.at.dx, _layout(tester).plot.left - 8);
        expect(row.at.dy - row.painter.height / 2, greaterThanOrEqualTo(name.at.dy));
      }
    });

    testWidgets('lays the value axis along the bottom when turned on its side', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          orientation: NebaOrientation.horizontal,
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final NebaChartLayout layout = _layout(tester);
      final NebaChartLabel zero = _chrome(
        tester,
      ).firstWhere((NebaChartLabel label) => label.painter.plainText == '0');

      expect(zero.at.dy, greaterThan(layout.plot.bottom));
      expect(zero.at.dx, closeTo(layout.plot.left, 0.01));
      // The first tick is set inward from the end of the plot.
      expect(zero.anchor, 1);
    });
  });

  group('valueLabels', () {
    const List<NebaChartSeries> deploys = <NebaChartSeries>[
      NebaChartSeries(name: 'Deploys', data: <num>[11, 22, 33]),
    ];

    testWidgets('writes nothing on the bars by default', (WidgetTester tester) async {
      await pump(tester, const NebaBarChart(categories: _teams, series: deploys));

      expect(_written(tester), isEmpty);
    });

    testWidgets('labels the last value there is when the series ends in a gap', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          valueLabels: NebaChartValueLabels.last,
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num?>[37, 41, null]),
          ],
        ),
      );

      expect(_written(tester), <String>['41']);
    });

    testWidgets('writes every value with all, just past the data end', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          valueLabels: NebaChartValueLabels.all,
          categories: _teams,
          series: deploys,
        ),
      );

      final _Drawn bar = _bars(tester).first;

      expect(_written(tester), <String>['11', '22', '33']);
      expect(bar.label!.at.dy, bar.rect.top - 5);
      expect(bar.label!.at.dx, closeTo(bar.rect.center.dx, 0.01));
    });

    testWidgets('writes only the high and the low with extremes', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          valueLabels: NebaChartValueLabels.extremes,
          categories: _teams,
          series: deploys,
        ),
      );

      expect(_written(tester), <String>['11', '33']);
    });

    testWidgets("writes a label in its own bar's colour rather than in the page ink", (
      WidgetTester tester,
    ) async {
      const Color web = Color(0xFF2F6FEB);
      const Color mobile = Color(0xFFE0582F);
      const Color marked = Color(0xFF1F9D55);

      await pump(
        tester,
        const NebaBarChart(
          valueLabels: NebaChartValueLabels.all,
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Web',
              data: <Object>[
                11,
                NebaChartPoint(y: 22, color: marked),
                33,
              ],
              color: web,
            ),
            NebaChartSeries(name: 'Mobile', data: <num>[13, 24, 35], color: mobile),
          ],
        ),
      );

      Color? inkOf(String text) {
        return _bars(tester)
            .firstWhere((_Drawn bar) => bar.label?.painter.plainText == text)
            .label!
            .painter
            .text!
            .style!
            .color;
      }

      expect(inkOf('11'), chartLabelInk(web, tokens));
      expect(inkOf('13'), chartLabelInk(mobile, tokens));
      // A point's own colour holds for its bar and its label.
      expect(inkOf('22'), chartLabelInk(marked, tokens));
      expect(_bars(tester)[1].color, marked);
    });

    testWidgets('writes a bar on the far edge through that axis', (WidgetTester tester) async {
      await pump(
        tester,
        NebaBarChart(
          valueLabels: NebaChartValueLabels.all,
          categories: _teams,
          format: (num value) => '\$$value',
          secondaryAxis: NebaChartAxis(tickFormat: (Object value, int index) => '$value%'),
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Cost', data: <num>[1000, 1200, 1400]),
            NebaChartSeries(
              name: 'Failure rate',
              data: <num>[2, 3.7, 2.5],
              axis: NebaChartSeriesAxis.secondary,
            ),
          ],
        ),
      );

      expect(_written(tester), containsAll(<String>[r'$1200', '3.7%']));
    });

    testWidgets('writes a negative value below its bar, and beside it on its side', (
      WidgetTester tester,
    ) async {
      const List<NebaChartSeries> net = <NebaChartSeries>[
        NebaChartSeries(name: 'Net', data: <num>[12, -6, 8]),
      ];

      await pump(
        tester,
        const NebaBarChart(valueLabels: NebaChartValueLabels.all, categories: _teams, series: net),
      );

      _Drawn down = _bars(tester)[1];

      expect(down.label!.at.dy, greaterThan(down.rect.bottom));

      await pump(
        tester,
        const NebaBarChart(
          valueLabels: NebaChartValueLabels.all,
          orientation: NebaOrientation.horizontal,
          categories: _teams,
          series: net,
        ),
      );

      down = _bars(tester)[1];

      expect(down.label!.at.dx, lessThan(down.rect.left));
      expect(down.label!.anchor, -1);
      expect(down.label!.central, isTrue);
    });
  });

  group('references', () {
    // A bar's column is a band, and the plot reaches half an index past the
    // first and last centres, so a band of one column is as wide as one step.
    testWidgets('reaches a whole column with a band on the category axis', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          categories: _teams,
          references: <NebaChartReference>[
            NebaChartReference(value: -0.5, to: 0.5, axis: NebaChartReferenceAxis.category),
          ],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final NebaChartLayout layout = _layout(tester);
      final List<Rect> washes = <Rect>[];

      expect(
        tester.renderObject(
          find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)).first,
        ),
        paints..everything((Symbol method, List<dynamic> arguments) {
          if (method == #drawRect) {
            washes.add(arguments[0] as Rect);
          }

          return true;
        }),
      );

      expect(washes, hasLength(1));
      expect(washes.single.left, closeTo(layout.plot.left, 0.01));
      expect(washes.single.width, closeTo(layout.band.step, 0.01));
    });
  });

  group('stacked', () {
    testWidgets("keeps the caller's own numbers in the table when stacking to full", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          stacked: NebaChartStacking.full,
          categories: <Object>['Jan'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'New', data: <num>[40]),
            NebaChartSeries(name: 'Renewed', data: <num>[160]),
          ],
        ),
      );

      final NebaChartDataTable table = tester.widget(find.byType(NebaChartDataTable));

      // The bars are drawn as 20% and 80%; the table still says 40 and 160.
      expect(table.rows.single, <String>['Jan', '40', '160']);
      expect(_layout(tester).values.first.single.value, 20);
    });

    testWidgets("writes the caller's numbers through format when stacking to full", (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaBarChart(
          stacked: NebaChartStacking.full,
          valueLabels: NebaChartValueLabels.all,
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
      expect(_written(tester), <String>['1235', '100']);
    });

    testWidgets('shares the hundred between the series still shown', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaBarChart(
          stacked: NebaChartStacking.full,
          height: 200,
          categories: <Object>['Jan'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'New', data: <num>[1]),
            NebaChartSeries(name: 'Renewed', data: <num>[3]),
          ],
        ),
      );

      final double quarter = _bars(tester).first.rect.height;

      await tester.tap(
        find.descendant(of: find.byType(NebaChartLegendBar), matching: find.text('Renewed')),
      );
      await tester.pump();

      expect(_bars(tester).single.rect.height / quarter, greaterThan(3.5));
    });

    testWidgets('puts the percentage on the value axis in either orientation', (
      WidgetTester tester,
    ) async {
      Widget mix(NebaOrientation orientation) {
        return NebaBarChart(
          stacked: NebaChartStacking.full,
          orientation: orientation,
          categories: const <Object>['Seoul', 'Tokyo'],
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'New', data: <num>[1, 2]),
            NebaChartSeries(name: 'Renewed', data: <num>[3, 4]),
          ],
        );
      }

      await pump(tester, mix(NebaOrientation.vertical));
      expect(_chromeTexts(tester), contains('100%'));

      // `xAxis` is the category axis and `yAxis` the value axis whichever way
      // the bars run, so turning the chart must not send the tick format to
      // the axis holding the category names.
      await pump(tester, mix(NebaOrientation.horizontal));

      final List<String> turned = _chromeTexts(tester);

      expect(turned, containsAll(<String>['100%', 'Seoul']));
      expect(turned, isNot(contains('Seoul%')));
    });

    testWidgets('stacks a negative series down from zero and the positive ones on each other', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          stacked: NebaChartStacking.on,
          height: 240,
          categories: <Object>['Jan'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'In', data: <num>[10]),
            NebaChartSeries(name: 'Out', data: <num>[-5]),
            NebaChartSeries(name: 'More in', data: <num>[10]),
          ],
        ),
      );

      final List<Rect> boxes = <Rect>[for (final _Drawn bar in _bars(tester)) bar.rect];
      final (Rect first, Rect negative, Rect top) = (boxes[0], boxes[1], boxes[2]);

      expect(negative.top, greaterThanOrEqualTo(first.bottom - 1));
      expect(top.bottom, lessThanOrEqualTo(first.top + 1));
      expect(negative.height / first.height, closeTo(0.5, 0.05));
      // The seam between two segments is the surface, two pixels of it.
      expect(first.top - top.bottom, closeTo(chartMarkGap, 0.01));
    });

    testWidgets('narrows item mode to the segment under the pointer, either way up', (
      WidgetTester tester,
    ) async {
      Widget chart(NebaOrientation orientation) {
        return NebaBarChart(
          stacked: NebaChartStacking.on,
          orientation: orientation,
          height: 200,
          tooltip: const NebaChartTooltip(mode: NebaChartTooltipMode.item),
          categories: const <Object>['Platform'],
          series: const <NebaChartSeries>[
            NebaChartSeries(name: 'Manual', data: <num>[10]),
            NebaChartSeries(name: 'Scheduled', data: <num>[10]),
          ],
        );
      }

      final TestGesture pointer = await mouse(tester);

      Future<String> nameAt(int segment) async {
        final Rect box = tester.getRect(find.byType(NebaChartBox));

        await pointer.moveTo(box.topLeft + _bars(tester)[segment].rect.center);
        await tester.pump();

        return _readout(tester);
      }

      await pump(tester, chart(NebaOrientation.vertical));
      expect(await nameAt(1), contains('Scheduled'));
      expect(await nameAt(0), contains('Manual'));

      await pump(tester, chart(NebaOrientation.horizontal));
      expect(await nameAt(1), contains('Scheduled'));
      expect(await nameAt(0), contains('Manual'));
    });
  });

  group('the highlight', () {
    testWidgets('draws every bar back at rest and the column under the crosshair full', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Center(
            child: SizedBox(
              width: 480,
              child: NebaBarChart(
                categories: _teams,
                series: <NebaChartSeries>[
                  NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
                ],
              ),
            ),
          ),
          disableAnimations: true,
        ),
      );

      List<double> alphas() => <double>[
        for (final (Path _, Paint paint) in _fills(tester)) paint.color.a,
      ];

      expect(alphas(), everyElement(closeTo(0.92, 0.001)));

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(alphas()[0], closeTo(1, 0.001));
      expect(alphas()[1], closeTo(0.92, 0.001));
    });
  });

  group('the crosshair', () {
    testWidgets('lays out no bar again as it moves from one column to the next', (
      WidgetTester tester,
    ) async {
      final List<Object> categories = <Object>[for (int index = 0; index < 24; index++) 'C$index'];

      await pump(
        tester,
        NebaBarChart(
          height: 240,
          valueLabels: NebaChartValueLabels.all,
          categories: categories,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[for (int i = 0; i < 24; i++) i + 1]),
            NebaChartSeries(name: 'Rollbacks', data: <num>[for (int i = 0; i < 24; i++) i + 30]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final Rect box = tester.getRect(find.byType(NebaChartBox));

      await pointer.moveTo(box.topLeft + Offset(box.width * 0.2, 120));
      await tester.pump();

      final Object? before = _marksOf(tester).traced;
      final String reading = _readout(tester);

      await pointer.moveTo(box.topLeft + Offset(box.width * 0.7, 120));
      await tester.pump();

      expect(_readout(tester), isNot(reading));
      expect(identical(_marksOf(tester).traced, before), isTrue);
    });

    testWidgets('walks a horizontal chart with the up and down arrows, a row at a time', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          label: 'Deploys',
          orientation: NebaOrientation.horizontal,
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Right and left are not the category axis on its side.
      expect(_readout(tester), isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), 'Payments, Deploys: 20');

      // The panel hangs beside the end of the bar, at its row; this bar runs
      // past six tenths of the plot, so the panel is on its near side.
      final NebaChartLayout layout = _layout(tester);
      final Rect panel = tester.getRect(find.byType(NebaChartTooltipPanel));
      final Rect box = tester.getRect(find.byType(NebaChartBox));

      expect(panel.right - box.left, closeTo(_bars(tester)[1].rect.right - 10, 0.5));
      expect(panel.top - box.top, closeTo(layout.categoryAt(1), 0.5));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // A shorter bar keeps the panel past its end.
      expect(_readout(tester), 'Platform, Deploys: 10');
      expect(
        tester.getRect(find.byType(NebaChartTooltipPanel)).left - box.left,
        closeTo(_bars(tester)[0].rect.right + 10, 0.5),
      );
    });

    testWidgets('reads the row under the pointer on a horizontal chart', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaBarChart(
          orientation: NebaOrientation.horizontal,
          categories: _teams,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Deploys', data: <num>[10, 20, 30]),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final Rect box = tester.getRect(find.byType(NebaChartBox));
      final NebaChartLayout layout = _layout(tester);

      await pointer.moveTo(box.topLeft + Offset(layout.plot.center.dx, layout.categoryAt(2)));
      await tester.pump();

      expect(_readout(tester), 'Growth, Deploys: 30');
    });
  });
}
