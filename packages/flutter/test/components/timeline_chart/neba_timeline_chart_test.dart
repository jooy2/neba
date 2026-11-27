// NebaTimelineChart: the React package's TimelineChart suite, asked the way
// Flutter asks it — the spans the painter lays out instead of `<rect>`
// attributes, the labels on the frame's canvas instead of `<text>`, and the
// table the chart builds instead of the DOM's. Dates are written with the
// English names `NebaDateNames` carries, in its order, where the React suite
// asks `Intl` for en-GB.

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neba/locales.dart';
import 'package:neba/neba.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/live_region.dart';

import '../../support/host.dart';

/// Two rows, three spans, all inside one quarter.
final List<NebaTimelineSeries> _plan = <NebaTimelineSeries>[
  NebaTimelineSeries(
    name: 'Design',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(
        start: DateTime(2026, 3, 2),
        end: DateTime(2026, 3, 16),
        label: 'Wireframes',
      ),
      NebaTimelinePoint(start: DateTime(2026, 3, 16), end: DateTime(2026, 4, 6), label: 'Visual'),
    ],
  ),
  NebaTimelineSeries(
    name: 'Build',
    data: <NebaTimelinePoint>[
      NebaTimelinePoint(start: DateTime(2026, 4, 6), end: DateTime(2026, 5, 18), label: 'API'),
    ],
  ),
];

Finder _painted() {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter.runtimeType.toString() == '_SpanPainter',
  );
}

NebaChartMarks<Object?> _marksOf(WidgetTester tester) {
  final dynamic painter = tester.widget<CustomPaint>(_painted()).painter;

  return painter.marks as NebaChartMarks<Object?>;
}

List<NebaChartMark> _marks(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;

  return (traced.marks as List<dynamic>).cast<NebaChartMark>();
}

/// Every bar drawn, in the order the data was given.
List<({Rect rect, Color color})> _bars(WidgetTester tester) {
  final dynamic traced = _marksOf(tester).traced;

  return <({Rect rect, Color color})>[
    for (final dynamic bar in traced.bars as List<dynamic>)
      if (bar != null) (rect: bar.rect as Rect, color: bar.color as Color),
  ];
}

List<String> _chromeTexts(WidgetTester tester) {
  final RenderObject chrome = tester.renderObject(
    find.descendant(of: find.byType(NebaChartBox), matching: find.byType(CustomPaint)).first,
  );
  final dynamic painter = (chrome as RenderCustomPaint).painter;

  return <String>[
    for (final Object op in (painter.model.chrome as List<dynamic>).cast<Object>())
      if (op is NebaChartLabel) op.painter.plainText,
  ];
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
  Future<void> pump(WidgetTester tester, Widget chart) {
    return tester.pumpWidget(
      host(Center(child: SizedBox(width: 600, child: chart)), disableAnimations: true),
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
    testWidgets('exposes the plot as an image described by its spans and when they run', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await pump(tester, NebaTimelineChart(label: 'Release plan', series: _plan));

      expect(
        tester.getSemantics(find.bySemanticsLabel('Release plan').first),
        matchesSemantics(
          label: 'Release plan',
          // Not the stand-in series, a one per row, which says nothing about
          // time.
          hint: 'Data points: 3. Range: Mar 2, 2026 to May 18, 2026.',
          isImage: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('widens the time axis to hold a reference past the spans', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: _plan,
          references: <NebaChartReference>[
            NebaChartReference(
              value: DateTime(2026, 8, 3).millisecondsSinceEpoch.toDouble(),
              label: 'Deadline',
            ),
          ],
        ),
      );

      // The spans end in May; an axis that stops there has no July on it.
      expect(_chromeTexts(tester), containsAll(<String>['Deadline', 'Jul']));
    });

    testWidgets('draws one bar per span', (WidgetTester tester) async {
      await pump(tester, NebaTimelineChart(series: _plan));

      expect(_bars(tester), hasLength(3));
    });

    testWidgets('starts each bar at its own date rather than at a baseline', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          min: DateTime(2026, 3),
          max: DateTime(2026, 5),
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3), end: DateTime(2026, 3, 15)),
                NebaTimelinePoint(start: DateTime(2026, 4), end: DateTime(2026, 4, 15)),
              ],
            ),
          ],
        ),
      );

      final Rect first = _bars(tester)[0].rect;
      final Rect second = _bars(tester)[1].rect;

      expect(second.left, greaterThan(first.right));
      expect(second.width, closeTo(first.width, 1));
    });

    testWidgets('draws a backwards span the right way round', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3, 15), end: DateTime(2026, 3)),
              ],
            ),
          ],
        ),
      );

      expect(_bars(tester).single.rect.width, greaterThan(1));
    });

    testWidgets('reflects a changed series on rebuild', (WidgetTester tester) async {
      await pump(tester, NebaTimelineChart(series: _plan));

      expect(table(tester).rows.last.first, 'Build');

      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[NebaTimelineSeries(name: 'Ship', data: _plan[1].data)],
        ),
      );

      expect(table(tester).rows.map((List<String> row) => row.first), <String>['Ship']);
    });

    testWidgets('shows the empty state when no row has a span', (WidgetTester tester) async {
      await pump(
        tester,
        const NebaTimelineChart(
          empty: Text('Nothing scheduled'),
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(name: 'Design', data: <NebaTimelinePoint>[]),
          ],
        ),
      );

      expect(find.text('Nothing scheduled'), findsOneWidget);
      expect(find.byType(NebaChartDataTable), findsNothing);
    });

    testWidgets('resolves a colour family on a span', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(
                  start: DateTime(2026, 3),
                  end: DateTime(2026, 3, 15),
                  color: NebaColor.success,
                ),
              ],
            ),
          ],
        ),
      );

      expect(_bars(tester).single.color, NebaTokens.light().roles(NebaColor.success).accent);
    });

    testWidgets('gives overlapping spans a lane each rather than stacking them', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          height: 200,
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3), end: DateTime(2026, 3, 20)),
                NebaTimelinePoint(start: DateTime(2026, 3, 10), end: DateTime(2026, 3, 30)),
              ],
            ),
          ],
        ),
      );

      final Rect first = _bars(tester)[0].rect;
      final Rect second = _bars(tester)[1].rect;

      expect(second.top, greaterThanOrEqualTo(first.bottom));
    });

    testWidgets('leaves a row whose spans do not overlap in one lane', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimelineChart(
          height: 200,
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3), end: DateTime(2026, 3, 10)),
                NebaTimelinePoint(start: DateTime(2026, 3, 10), end: DateTime(2026, 3, 20)),
              ],
            ),
          ],
        ),
      );

      final Rect first = _bars(tester)[0].rect;
      final Rect second = _bars(tester)[1].rect;

      expect(second.top, first.top);
      expect(second.height, first.height);
    });

    testWidgets('shows no legend: the rows are the axis', (WidgetTester tester) async {
      await pump(tester, NebaTimelineChart(series: _plan));

      expect(find.byType(NebaChartLegendBar), findsNothing);
    });

    testWidgets('rounds both ends of a span, or neither', (WidgetTester tester) async {
      RRect drawn() {
        late RRect found;

        expect(
          tester.renderObject(_painted()),
          paints..everything((Symbol method, List<dynamic> arguments) {
            if (method == #drawRRect) {
              found = arguments[0] as RRect;
            }

            return true;
          }),
        );

        return found;
      }

      final List<NebaTimelineSeries> one = <NebaTimelineSeries>[
        NebaTimelineSeries(
          name: 'Row',
          data: <NebaTimelinePoint>[
            NebaTimelinePoint(start: DateTime(2026, 3), end: DateTime(2026, 3, 20)),
          ],
        ),
      ];

      await pump(tester, NebaTimelineChart(series: one));

      expect(drawn().tlRadiusX, chartBarRadius);
      expect(drawn().brRadiusX, chartBarRadius);

      await pump(tester, NebaTimelineChart(series: one, rounded: false));

      expect(drawn().tlRadiusX, 0);
    });
  });

  group('the time axis', () {
    testWidgets('ticks where a calendar ticks, naming the year once inside one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(min: DateTime(2026), max: DateTime(2026, 7), series: _plan),
      );

      final List<String> texts = _chromeTexts(tester);
      final NebaChartTimeScale scale = _marksOf(tester).layout.scale as NebaChartTimeScale;

      expect(scale.unit, NebaChartTimeUnit.month);
      expect(scale.ticks.first, DateTime(2026).millisecondsSinceEpoch);
      expect(texts, contains('Jan 2026'));
      expect(texts.where((String text) => text.contains('2026')), hasLength(1));
      expect(texts.any((String text) => RegExp(r'^[\d,]{10,}$').hasMatch(text)), isFalse);
    });

    testWidgets('names the year on every tick once the axis crosses one', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(min: DateTime(2025, 10), max: DateTime(2026, 4), series: _plan),
      );

      final List<String> dates = <String>[
        for (final String text in _chromeTexts(tester))
          if (RegExp(r'\b(Oct|Nov|Dec|Jan|Feb|Mar|Apr)\b').hasMatch(text)) text,
      ];

      expect(dates.length, greaterThan(1));
      expect(dates, everyElement(matches(RegExp(r'20\d{2}'))));
      expect(dates, contains('Oct 2025'));
    });

    testWidgets('steps in hours across a working day', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimelineChart(
          min: DateTime(2026, 3, 2, 9),
          max: DateTime(2026, 3, 2, 18),
          series: _plan,
        ),
      );

      expect(_chromeTexts(tester), containsAll(<String>['09:00', '12:00']));
    });

    testWidgets('names the rows down the side', (WidgetTester tester) async {
      await pump(tester, NebaTimelineChart(series: _plan));

      expect(_chromeTexts(tester), containsAll(<String>['Design', 'Build']));
    });

    testWidgets('takes a tickFormat of its own on yAxis, the value axis', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          min: DateTime(2026),
          max: DateTime(2026, 7),
          yAxis: NebaChartAxis(
            tickFormat: (Object value, int index) =>
                'w${DateTime.fromMillisecondsSinceEpoch((value as num).toInt()).month}',
          ),
          series: _plan,
        ),
      );

      expect(_chromeTexts(tester), contains('w1'));
      expect(_chromeTexts(tester), isNot(contains('Jan 2026')));
    });
  });

  group('the table', () {
    testWidgets('gives every span a row of its own, under its row name', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimelineChart(label: 'Plan', series: _plan));

      expect(table(tester).caption, 'Plan');
      expect(table(tester).columns, <String>['', 'Label', 'Start', 'End']);
      expect(table(tester).rows, <List<String>>[
        <String>['Design', 'Wireframes', 'Mar 2, 2026', 'Mar 16, 2026'],
        <String>['Design', 'Visual', 'Mar 16, 2026', 'Apr 6, 2026'],
        <String>['Build', 'API', 'Apr 6, 2026', 'May 18, 2026'],
      ]);
    });

    testWidgets('writes its rows after the first frame past five hundred spans', (
      WidgetTester tester,
    ) async {
      final List<NebaTimelineSeries> plan = <NebaTimelineSeries>[
        for (int row = 0; row < 3; row++)
          NebaTimelineSeries(
            name: 'Team ${row + 1}',
            data: <NebaTimelinePoint>[
              for (int index = 0; index < 200; index++)
                NebaTimelinePoint(
                  start: DateTime(2026, 1, 5 + index),
                  end: DateTime(2026, 1, 6 + index),
                ),
            ],
          ),
      ];

      await pump(tester, NebaTimelineChart(label: 'Plan', series: plan));

      expect(table(tester).points, 600);
      expect(find.text('Team 3'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Team 3'), findsWidgets);
      expect(table(tester).rows.sublist(199, 201).map((List<String> row) => row.first), <String>[
        'Team 1',
        'Team 2',
      ]);
    });

    testWidgets('writes a span to the day on an axis that ticks in months', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Design',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3, 2), end: DateTime(2026, 3, 16)),
              ],
            ),
            NebaTimelineSeries(
              name: 'Build',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 1, 5), end: DateTime(2026, 12, 20)),
              ],
            ),
          ],
        ),
      );

      expect(table(tester).rows.first, <String>['Design', 'Mar 2, 2026', 'Mar 16, 2026']);
    });

    testWidgets('writes a span to the minute on an axis that ticks in hours', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Standup',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3, 2, 9), end: DateTime(2026, 3, 2, 9, 15)),
              ],
            ),
            NebaTimelineSeries(
              name: 'Review',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(
                  start: DateTime(2026, 3, 2, 14),
                  end: DateTime(2026, 3, 2, 16, 30),
                ),
              ],
            ),
          ],
        ),
      );

      expect(table(tester).rows, <List<String>>[
        <String>['Standup', '09:00', '09:15'],
        <String>['Review', '14:00', '16:30'],
      ]);
    });

    testWidgets('writes every span with its time once one starts or ends away from midnight', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Build',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3, 2), end: DateTime(2026, 3, 9)),
              ],
            ),
            NebaTimelineSeries(
              name: 'Meeting',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3, 3, 9), end: DateTime(2026, 3, 3, 11)),
              ],
            ),
          ],
        ),
      );

      expect(table(tester).rows, <List<String>>[
        <String>['Build', 'Mar 2, 2026, 00:00', 'Mar 9, 2026, 00:00'],
        <String>['Meeting', 'Mar 3, 2026, 09:00', 'Mar 3, 2026, 11:00'],
      ]);
    });

    testWidgets('drops the label column when no span carries one', (WidgetTester tester) async {
      await pump(
        tester,
        NebaTimelineChart(
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(start: DateTime(2026, 3), end: DateTime(2026, 3, 15)),
              ],
            ),
          ],
        ),
      );

      expect(table(tester).columns, <String>['', 'Start', 'End']);
    });

    testWidgets('names its columns in the language it was given', (WidgetTester tester) async {
      registerNebaMessages('ko', ko);

      await pump(tester, NebaTimelineChart(locale: const Locale('ko'), series: _plan));

      expect(table(tester).columns, <String>['', '레이블', '시작', '끝']);
    });
  });

  group('tooltip', () {
    testWidgets('names the span the pointer is on, its row and its dates', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimelineChart(height: 200, series: _plan));

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(onScreen(tester, _bars(tester).first.rect.center));
      await tester.pump();

      expect(_readout(tester), 'Wireframes, Design: Mar 2, 2026 – Mar 16, 2026');
      expect(find.byType(NebaChartTooltipPanel), findsOneWidget);
    });

    testWidgets('leaves a span outside a pinned min out of the keyboard walk', (
      WidgetTester tester,
    ) async {
      await pump(tester, NebaTimelineChart(height: 200, min: DateTime(2026, 3, 20), series: _plan));

      focusOf(tester).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();

      expect(_readout(tester), startsWith('Visual'));

      // The keys follow the rows, down the side.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(_readout(tester), startsWith('API'));
    });

    testWidgets('picks the span the pointer is inside, not the one with the nearer centre', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        NebaTimelineChart(
          height: 160,
          min: DateTime(2026),
          max: DateTime(2026, 12, 31),
          series: <NebaTimelineSeries>[
            NebaTimelineSeries(
              name: 'Row',
              data: <NebaTimelinePoint>[
                NebaTimelinePoint(
                  start: DateTime(2026, 1, 5),
                  end: DateTime(2026, 8),
                  label: 'Long',
                ),
                NebaTimelinePoint(
                  start: DateTime(2026, 8, 20),
                  end: DateTime(2026, 9),
                  label: 'Short',
                ),
              ],
            ),
          ],
        ),
      );

      final TestGesture pointer = await mouse(tester);
      final Rect long = _bars(tester).first.rect;

      // Just inside the long bar's end: far from its own centre and close to
      // the short bar's.
      await pointer.moveTo(onScreen(tester, Offset(long.right - 4, long.center.dy)));
      await tester.pump();

      expect(_readout(tester), startsWith('Long'));
      expect(_marksOf(tester).activeMark, same(_marks(tester).first));
    });

    testWidgets('is not reachable when it is turned off', (WidgetTester tester) async {
      await pump(tester, NebaTimelineChart(height: 200, tooltip: false, series: _plan));

      final TestGesture pointer = await mouse(tester);

      await pointer.moveTo(onScreen(tester, _bars(tester).first.rect.topLeft + const Offset(4, 4)));
      await tester.pump();

      expect(find.byType(NebaLiveRegion), findsNothing);
      expect(find.byType(NebaChartTooltipPanel), findsNothing);
    });
  });
}
