// NebaHeatmapChart: the React package's HeatmapChart suite, asked the way
// Flutter asks it — the cells the painter lays out and the colours it fills
// them with instead of `<rect>` attributes, the names on its canvas instead of
// `<text>`, and the table it builds instead of the DOM's.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/live_region.dart';

import '../../support/host.dart';

const List<Object> _hours = <Object>['00', '06', '12', '18'];

const List<NebaChartSeries> _traffic = <NebaChartSeries>[
  NebaChartSeries(name: 'Mon', data: <num>[1, 20, 40, 8]),
  NebaChartSeries(name: 'Tue', data: <num>[2, 24, 48, 9]),
  NebaChartSeries(name: 'Wed', data: <num>[3, 28, 56, 11]),
];

/// A cell as the painter draws it.
typedef _Drawn = ({int row, int index, Rect slot, Rect? rect, Color fill, List<String> lines});

Finder _painted() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_HeatmapPainter',
  );
}

dynamic _layout(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_painted()).painter;

  return painter.layout;
}

/// Every cell laid out, in the order the keys walk them.
List<_Drawn> _cells(WidgetTester tester) {
  return <_Drawn>[
    for (final dynamic cell in _layout(tester).cells as List<dynamic>)
      (
        row: cell.row as int,
        index: cell.index as int,
        slot: cell.slot as Rect,
        rect: (cell.drawn as RRect?)?.outerRect,
        fill: cell.fill as Color,
        lines: <String>[
          for (final dynamic line in cell.lines as List<dynamic>)
            (line as NebaChartLabel).painter.plainText,
        ],
      ),
  ];
}

/// The names written around the cells.
List<NebaChartLabel> _names(WidgetTester tester) {
  return (_layout(tester).names as List<dynamic>).cast<NebaChartLabel>();
}

List<String> _nameTexts(WidgetTester tester) {
  return <String>[for (final NebaChartLabel name in _names(tester)) name.painter.plainText];
}

String _readout(WidgetTester tester) {
  return tester
          .widget<Text>(
            find.descendant(of: find.byType(NebaLiveRegion), matching: find.byType(Text)),
          )
          .data ??
      '';
}

Finder _scaleLegend() {
  return find.byWidgetPredicate((Widget widget) => widget.runtimeType.toString() == '_ScaleLegend');
}

void main() {
  final NebaTokens tokens = NebaTokens.light();

  Future<void> pump(WidgetTester tester, Widget chart, {double width = 480}) {
    return tester.pumpWidget(
      host(
        Center(
          child: SizedBox(width: width, child: chart),
        ),
        disableAnimations: true,
      ),
    );
  }

  NebaChartDataTable table(WidgetTester tester) => tester.widget(find.byType(NebaChartDataTable));

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

  Offset onScreen(WidgetTester tester, Offset local) {
    return tester.getTopLeft(find.byType(NebaChartBox)) + local;
  }

  group('rendering', () {
    testWidgets('exposes the plot as an image with its label, described by its range', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(
        tester,
        const NebaHeatmapChart(label: 'Sessions by hour', categories: _hours, series: _traffic),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Sessions by hour').first),
        matchesSemantics(
          label: 'Sessions by hour',
          hint: 'Data points: 12. Range: 1 to 56.',
          isImage: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('names itself when no label was given', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      expect(find.bySemanticsLabel('Chart'), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('draws a cell per row and column', (WidgetTester tester) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      expect(_cells(tester), hasLength(12));
    });

    testWidgets('leaves a gap undrawn rather than painting it as the bottom of the scale', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: _hours,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Mon', data: <num?>[1, null, 40, 8]),
          ],
        ),
      );

      expect(_cells(tester).map((_Drawn cell) => cell.index), <int>[0, 2, 3]);
    });

    testWidgets('names the rows and the columns, each in a band of its own', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      final Rect plot = _layout(tester).plot as Rect;

      expect(_nameTexts(tester), containsAll(<String>['Mon', '12']));

      for (final NebaChartLabel name in _names(tester)) {
        // Down the side, or along the bottom: never over a cell.
        expect(name.at.dx < plot.left || name.at.dy > plot.bottom, isTrue);
      }
    });

    testWidgets('thins the column labels on one stride', (WidgetTester tester) async {
      final List<Object> days = <Object>[
        for (int index = 0; index < 30; index++) index.isEven ? 'D$index' : 'Day number $index',
      ];

      await pump(
        tester,
        NebaHeatmapChart(
          categories: days,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Load',
              data: <num>[for (int index = 0; index < 30; index++) index],
            ),
          ],
        ),
        width: 360,
      );

      final List<int> drawn = <int>[
        for (final String text in _nameTexts(tester))
          if (days.contains(text)) days.indexOf(text),
      ];
      final Set<int> gaps = <int>{
        for (int at = 1; at < drawn.length; at++) drawn[at] - drawn[at - 1],
      };

      expect(drawn.length, greaterThan(1));
      expect(gaps, hasLength(1));
    });

    testWidgets('reflects a changed series on rebuild', (WidgetTester tester) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      expect(table(tester).rows.last, contains('56'));

      await pump(
        tester,
        const NebaHeatmapChart(
          categories: _hours,
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Wed', data: <num>[3, 28, 99, 11]),
          ],
        ),
      );

      expect(table(tester).rows.single, <String>['Wed', '3', '28', '99', '11']);
    });

    testWidgets('shows the empty state when there is nothing to draw', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(series: <NebaChartSeries>[], empty: Text('No sessions yet')),
      );

      expect(find.text('No sessions yet'), findsOneWidget);
      expect(find.byType(NebaChartDataTable), findsNothing);
      expect(_scaleLegend(), findsNothing);
    });
  });

  group('the two axes', () {
    testWidgets('names each axis where that axis is', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: _hours,
          series: _traffic,
          xAxis: NebaChartAxis(label: 'Hour'),
          yAxis: NebaChartAxis(label: 'Day'),
        ),
      );

      final Rect plot = _layout(tester).plot as Rect;
      final NebaChartLabel hour = _names(
        tester,
      ).firstWhere((NebaChartLabel name) => name.painter.plainText == 'Hour');
      final NebaChartLabel day = _names(
        tester,
      ).firstWhere((NebaChartLabel name) => name.painter.plainText == 'Day');

      expect(hour.at.dy, greaterThan(plot.bottom));
      expect(day.at.dy, lessThan(plot.top));
    });

    testWidgets('drops a hidden axis and gives its band back to the cells', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      final double before = _cells(tester).first.slot.left;

      await pump(
        tester,
        const NebaHeatmapChart(
          categories: _hours,
          series: _traffic,
          xAxis: NebaChartAxis(hidden: true),
          yAxis: NebaChartAxis(hidden: true),
        ),
      );

      expect(_nameTexts(tester), isNot(contains('Mon')));
      expect(_nameTexts(tester), isNot(contains('12')));
      expect(_cells(tester).first.slot.left, lessThan(before));
    });

    testWidgets('writes each name through tickFormat', (WidgetTester tester) async {
      await pump(
        tester,
        NebaHeatmapChart(
          categories: _hours,
          series: _traffic,
          xAxis: NebaChartAxis(tickFormat: (Object value, int index) => '${value}h'),
          yAxis: NebaChartAxis(
            tickFormat: (Object value, int index) => value.toString().toUpperCase(),
          ),
        ),
      );

      expect(_nameTexts(tester), containsAll(<String>['12h', 'MON']));
    });

    testWidgets('turns the column names with tickAngle, and leaves the rows flat', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: _hours,
          series: _traffic,
          xAxis: NebaChartAxis(tickAngle: -45),
          yAxis: NebaChartAxis(tickAngle: -45),
        ),
      );

      expect(<String>[
        for (final NebaChartLabel name in _names(tester))
          if (name.angle == -45) name.painter.plainText,
      ], _hours);
    });

    testWidgets('is read by a grid and not by a treemap', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          categories: _hours,
          series: _traffic,
          xAxis: NebaChartAxis(label: 'Hour'),
          yAxis: NebaChartAxis(label: 'Day'),
        ),
      );

      expect(_cells(tester), isNotEmpty);
      expect(_names(tester), isEmpty);
    });
  });

  group('accessibility', () {
    testWidgets('keeps the readout outside the picture', (WidgetTester tester) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      expect(find.byType(NebaLiveRegion), findsOneWidget);
      expect(
        find.descendant(of: find.byType(NebaChartPlot), matching: find.byType(NebaLiveRegion)),
        findsNothing,
      );
    });
  });

  group('colour', () {
    testWidgets('takes the sequential ramp and not the categorical palette', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      for (final _Drawn cell in _cells(tester)) {
        expect(tokens.chart.sequential, contains(cell.fill));
        expect(tokens.chart.series, isNot(contains(cell.fill)));
      }
    });

    testWidgets('puts the smallest value on the palest step and the largest on the deepest', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[0, 100]),
          ],
        ),
      );

      expect(_cells(tester).map((_Drawn cell) => cell.fill), <Color>[
        tokens.chart.sequential.first,
        tokens.chart.sequential.last,
      ]);
    });

    testWidgets('scales one ladder across every row rather than one per row', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(name: 'Small', data: <num>[0, 1]),
            NebaChartSeries(name: 'Large', data: <num>[99, 100]),
          ],
        ),
      );

      final List<_Drawn> cells = _cells(tester);

      expect(cells[1].fill, tokens.chart.sequential.first);
      expect(cells[3].fill, tokens.chart.sequential.last);
    });

    testWidgets('turns over at the midpoint with a diverging scale, and moves with it', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          scale: NebaHeatmapScale.diverging,
          categories: <Object>['a', 'b', 'c'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[-10, 0, 10]),
          ],
        ),
      );

      expect(_cells(tester).map((_Drawn cell) => cell.fill), <Color>[
        tokens.chart.diverging[0],
        tokens.chart.diverging[2],
        tokens.chart.diverging[4],
      ]);

      await pump(
        tester,
        const NebaHeatmapChart(
          scale: NebaHeatmapScale.diverging,
          midpoint: 50,
          categories: <Object>['a', 'b', 'c'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[0, 50, 100]),
          ],
        ),
      );

      expect(_cells(tester)[1].fill, tokens.chart.diverging[2]);
    });

    testWidgets('lets a cell keep a colour of its own', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(
              data: <Object>[
                1,
                NebaChartPoint(x: 'b', y: 2, color: NebaColor.danger),
              ],
            ),
          ],
        ),
      );

      expect(_cells(tester)[1].fill, tokens.roles(NebaColor.danger).accent);
    });

    testWidgets('draws every cell back but the one being read', (WidgetTester tester) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      List<double> alphas() {
        final List<double> found = <double>[];

        expect(
          tester.renderObject(_painted()),
          paints..everything((Symbol method, List<dynamic> arguments) {
            if (method == #drawRRect) {
              found.add((arguments[1] as Paint).color.a);
            }

            return true;
          }),
        );

        return found;
      }

      expect(alphas(), everyElement(closeTo(0.94, 0.001)));

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(alphas().first, closeTo(1, 0.001));
      expect(alphas()[1], closeTo(0.94, 0.001));
    });
  });

  group('the scale legend', () {
    testWidgets('is a bar with its ends labelled, not a list of swatches', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[4, 96]),
          ],
        ),
      );

      expect(find.descendant(of: _scaleLegend(), matching: find.text('4')), findsOneWidget);
      expect(find.descendant(of: _scaleLegend(), matching: find.text('96')), findsOneWidget);

      // Five joined blocks of the ramp, as wide as the bar and as tall.
      final List<Size> blocks = <Size>[
        for (final Element block
            in find.descendant(of: _scaleLegend(), matching: find.byType(ColoredBox)).evaluate())
          block.size!,
      ];

      expect(<Color>[
        for (final ColoredBox block in tester.widgetList<ColoredBox>(
          find.descendant(of: _scaleLegend(), matching: find.byType(ColoredBox)),
        ))
          block.color,
      ], tokens.chart.sequential);
      expect(blocks.map((Size size) => size.height), everyElement(10));
      expect(
        blocks.fold<double>(0, (double sum, Size size) => sum + size.width),
        closeTo(96, 0.01),
      );
      // Nothing to press: there is no series to filter, only a magnitude.
      expect(find.byType(NebaChartLegendBar), findsNothing);
      expect(
        find.descendant(
          of: _scaleLegend(),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is Semantics && (widget.properties.button ?? false),
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('names the midpoint on a diverging scale', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          scale: NebaHeatmapScale.diverging,
          midpoint: 20,
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[0, 40]),
          ],
        ),
      );

      expect(
        <String>[
          for (final Text text in tester.widgetList<Text>(
            find.descendant(of: _scaleLegend(), matching: find.byType(Text)),
          ))
            text.data ?? '',
        ],
        <String>['0', '40', '20'],
      );
    });

    testWidgets('can be turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          legend: false,
          categories: <Object>['a', 'b'],
          series: <NebaChartSeries>[
            NebaChartSeries(data: <num>[4, 96]),
          ],
        ),
      );

      expect(_scaleLegend(), findsNothing);
    });
  });

  group('treemap', () {
    testWidgets('draws a tile per datum, sized by its share', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 200,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 'Builds', y: 300),
                NebaChartPoint(x: 'Logs', y: 100),
              ],
            ),
          ],
        ),
      );

      final List<double> areas = <double>[
        for (final _Drawn cell in _cells(tester)) cell.rect!.width * cell.rect!.height,
      ];

      expect(areas, hasLength(2));
      expect(areas[0] / areas[1], inInclusiveRange(2.4, 3.6));
    });

    testWidgets('fills the box', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 200,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 'a', y: 3),
                NebaChartPoint(x: 'b', y: 2),
                NebaChartPoint(x: 'c', y: 1),
              ],
            ),
          ],
        ),
      );

      final Size box = tester.getSize(find.byType(NebaChartBox));
      final double covered = _cells(
        tester,
      ).fold<double>(0, (double sum, _Drawn cell) => sum + cell.rect!.width * cell.rect!.height);

      expect(covered / (box.width * 200), greaterThan(0.9));
    });

    testWidgets('names each tile after itself rather than after its group', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 220,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 'Builds', y: 300),
                NebaChartPoint(x: 'Logs', y: 200),
              ],
            ),
          ],
        ),
      );

      final List<String> written = <String>[
        for (final _Drawn cell in _cells(tester)) ...cell.lines,
      ];

      expect(written, containsAll(<String>['Builds', 'Logs']));
      expect(written, isNot(contains('Platform')));
    });

    testWidgets('keeps a negative out of the picture and in the table', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 200,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 'a', y: 300),
                NebaChartPoint(x: 'b', y: -50),
              ],
            ),
          ],
        ),
      );

      expect(_cells(tester), hasLength(1));
      expect(table(tester).rows.single, <String>['Platform', '300', '-50']);
    });
  });

  group('valueLabels', () {
    testWidgets('writes nothing on a grid cell by default, and the value with all', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(categories: _hours, series: _traffic));

      expect(_cells(tester).expand((_Drawn cell) => cell.lines), isEmpty);

      await pump(
        tester,
        const NebaHeatmapChart(
          valueLabels: NebaChartValueLabels.all,
          categories: _hours,
          series: _traffic,
        ),
      );

      expect(_cells(tester).expand((_Drawn cell) => cell.lines), contains('40'));
    });
  });

  group('the table', () {
    testWidgets('is the grid, with the rows and the columns named', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(label: 'Sessions', categories: _hours, series: _traffic),
      );

      expect(table(tester).caption, 'Sessions');
      expect(table(tester).columns, <String>['', '00', '06', '12', '18']);
      expect(table(tester).rows[1], <String>['Tue', '2', '24', '48', '9']);
    });

    testWidgets('puts every treemap tile under a column of its own name', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 220,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[NebaChartPoint(x: 'Builds', y: 300)],
            ),
            NebaChartSeries(
              name: 'Product',
              data: <NebaChartPoint>[NebaChartPoint(x: 'Media', y: 120)],
            ),
          ],
        ),
      );

      expect(table(tester).columns, <String>['', 'Builds', 'Media']);
      expect(table(tester).rows, <List<String>>[
        <String>['Platform', '300', ''],
        <String>['Product', '', '120'],
      ]);
    });

    testWidgets('writes its rows after the first frame past five hundred cells', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaHeatmapChart(
          label: 'Load',
          series: <NebaChartSeries>[
            for (int row = 0; row < 7; row++)
              NebaChartSeries(
                name: 'Row ${row + 1}',
                data: <num>[for (int column = 0; column < 100; column++) row * 100 + column],
              ),
          ],
        ),
      );

      expect(table(tester).points, 700);
      expect(find.text('Row 7'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Row 7'), findsOneWidget);
    });

    testWidgets('writes every row at once at five hundred cells', (WidgetTester tester) async {
      await pump(
        tester,
        NebaHeatmapChart(
          label: 'Load',
          series: <NebaChartSeries>[
            for (int row = 0; row < 5; row++)
              NebaChartSeries(
                name: 'Row ${row + 1}',
                data: <num>[for (int column = 0; column < 100; column++) column],
              ),
          ],
        ),
      );

      expect(find.text('Row 5'), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('moves along the column with the vertical arrows on a grid', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(height: 200, categories: _hours, series: _traffic));

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(_readout(tester), 'Mon · 06, 20');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), startsWith('Tue · 06'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), startsWith('Wed · 06'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(_readout(tester), startsWith('Tue · 06'));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(_readout(tester), '');
    });

    testWidgets('walks a treemap largest tile first whichever arrow is pressed', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        const NebaHeatmapChart(
          shape: NebaHeatmapShape.treemap,
          height: 220,
          series: <NebaChartSeries>[
            NebaChartSeries(
              name: 'Platform',
              data: <NebaChartPoint>[
                NebaChartPoint(x: 'Logs', y: 100),
                NebaChartPoint(x: 'Builds', y: 300),
              ],
            ),
          ],
        ),
      );

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), startsWith('Platform · Builds'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), startsWith('Platform · Logs'));
    });
  });

  group('tooltip', () {
    testWidgets('names both coordinates of the cell under the pointer', (
      WidgetTester tester,
    ) async {
      await pump(tester, const NebaHeatmapChart(height: 200, categories: _hours, series: _traffic));

      final TestGesture pointer = await mouse(tester);

      // Row by row, four columns a row: the ninth is the third row's first.
      await pointer.moveTo(onScreen(tester, _cells(tester)[8].rect!.center));
      await tester.pump();

      expect(_readout(tester), 'Wed · 00, 3');
      expect(find.byType(NebaChartTooltipPanel), findsOneWidget);
    });

    testWidgets('lays no cell out again as the pointer moves from one to the next', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaHeatmapChart(
          height: 300,
          valueLabels: NebaChartValueLabels.all,
          series: <NebaChartSeries>[
            for (int row = 0; row < 10; row++)
              NebaChartSeries(
                name: 'R$row',
                data: <num>[for (int column = 0; column < 10; column++) row * 10 + column],
              ),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final Object before = _layout(tester) as Object;

      await pointer.moveTo(onScreen(tester, _cells(tester)[0].rect!.center));
      await tester.pump();
      await pointer.moveTo(onScreen(tester, _cells(tester)[55].rect!.center));
      await tester.pump();

      expect(_readout(tester), startsWith('R5'));
      expect(_layout(tester), same(before));
    });

    testWidgets('is not reachable when it is turned off', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaHeatmapChart(height: 200, tooltip: false, categories: _hours, series: _traffic),
      );

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(onScreen(tester, _cells(tester)[0].rect!.topLeft + const Offset(4, 4)));
      await tester.pump();

      expect(find.byType(NebaLiveRegion), findsNothing);
      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });
  });
}
