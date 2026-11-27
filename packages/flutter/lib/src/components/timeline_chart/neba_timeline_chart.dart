/// `NebaTimelineChart`, work against time: a row per thing and a bar per
/// stretch of it.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/calendar/neba_date_names.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// How far a span the reader is not reading is drawn back.
const double _restOpacity = 0.92;

/// Work against time: a row per thing, a bar per stretch of it.
///
/// The two axes are a set of rows and a calendar, which makes this a
/// `NebaBarChart` turned on its side with the baseline taken away: every bar
/// starts where its own data says rather than at zero, so what the chart is
/// about is when rather than how much. A row that does two things at once
/// gives each overlapping span a lane of its own.
///
/// Not to be confused with `NebaTimeline`, which is a list of steps and draws
/// no axis at all.
///
/// ```dart
/// NebaTimelineChart(
///   label: 'Release plan',
///   series: <NebaTimelineSeries>[
///     NebaTimelineSeries(
///       name: 'Design',
///       data: <NebaTimelinePoint>[
///         NebaTimelinePoint(start: DateTime(2026, 3, 2), end: DateTime(2026, 3, 16)),
///       ],
///     ),
///   ],
/// )
/// ```
class NebaTimelineChart extends StatelessWidget {
  /// A timeline of [series].
  const NebaTimelineChart({
    required this.series,
    this.min,
    this.max,
    this.barSize,
    this.rounded = true,
    this.xAxis,
    this.yAxis,
    this.references,
    this.height,
    this.format,
    this.locale,
    this.label,
    this.tooltip,
    this.empty,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.padded = false,
    this.transition,
    super.key,
  }) : assert(min == null || min is DateTime || min is num),
       assert(max == null || max is DateTime || max is num),
       assert(tooltip == null || tooltip is bool || tooltip is NebaChartTooltip);

  /// One row per series, and the spans on it. A row's name is what the axis
  /// says down the side.
  final List<NebaTimelineSeries> series;

  /// Where the time axis starts: a [DateTime], or milliseconds since the
  /// epoch. Taken from the spans when left out, and rounded outward to a date
  /// a calendar has a name for.
  final Object? min;

  /// Where the time axis ends, as [min].
  final Object? max;

  /// How thick a bar may get, in logical pixels. Below the cap the bars fill
  /// their share of the row; above it the rest stays as air. The size ladder
  /// when left out: 14, 18, 24, 30 and 36.
  final double? barSize;

  /// Cuts the corners off both ends of a span: neither end is a baseline.
  final bool rounded;

  /// The row axis. `xAxis` is the category axis whichever way a chart runs.
  final NebaChartAxis? xAxis;

  /// The time axis, along the bottom, still the value axis. Its `tickFormat`
  /// is handed each tick as milliseconds since the epoch; its `min` and `max`
  /// are not read, since [min] and [max] are the chart's.
  final NebaChartAxis? yAxis;

  /// Moments drawn across the plot, a deadline or today, as milliseconds
  /// since the epoch. The axis widens to hold them.
  final List<NebaChartReference>? references;

  /// How tall the drawing is, the names inside it. The size ladder when left
  /// out: 120, 160, 220, 280 and 360 logical pixels.
  final double? height;

  /// How a number is written where the chart writes one of its own rather
  /// than a date: a reference's value in the hidden list under the table.
  final String Function(num value)? format;

  /// The language of the chart's own words and of its dates, as far as
  /// `registerNebaDateNames` was given that language's names. Defaults to
  /// `NebaProvider`'s, then the app's.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartTooltip]. Always about one span, the one
  /// the pointer is in or nearest, so `mode` and `crosshair` are not read.
  final Object? tooltip;

  /// What is drawn when no row has a span.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type, the bar thickness and the height. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet and the focus ring. A row's colour does not come
  /// from here.
  final NebaColor color;

  /// How much of each row the bars take, and the sheet's padding. Defaults to
  /// `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads the chart.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaDensity density = this.density ?? defaults.density ?? NebaDensity.standard;
    final NebaDateNames names = NebaDateNames.of(context, locale: locale);
    final Map<String, String> words = nebaMessages(context, 'chart', locale: locale);

    // The rows, as instants, in lanes: a fact about the data rather than the
    // pixels, and the axis has to be solved before anything is placed on it.
    final List<_Row> rows = <_Row>[for (final NebaTimelineSeries row in series) _pack(row, tokens)];

    // The extent of the spans, and of the moments referred to on the time
    // axis: a deadline past the last span is still on the plot.
    double low = double.infinity;
    double high = double.negativeInfinity;
    bool seen = false;

    for (final _Row row in rows) {
      for (final _Span? one in row.spans) {
        if (one != null) {
          seen = true;
          low = math.min(low, one.from);
          high = math.max(high, one.to);
        }
      }
    }

    for (final NebaChartReference one in references ?? const <NebaChartReference>[]) {
      if (one.axis != NebaChartReferenceAxis.value) {
        continue;
      }

      for (final double at in <double>[one.value, ?one.to]) {
        seen = true;
        low = math.min(low, at);
        high = math.max(high, at);
      }
    }

    final NebaChartTimeScale scale = chartTimeScale(
      seen ? (min: low, max: high) : null,
      min: chartToNumber(min),
      max: chartToNumber(max),
      tickCount: yAxis?.tickCount,
    );
    final List<String> tickTexts = chartTimeTicks(scale.ticks, scale.unit, names);
    final NebaChartTimeUnit unit = _spanUnit(scale.unit);
    // Whether the spans need their time: one that starts or ends away from
    // midnight on an axis that ticks in days was written as its date alone,
    // and one written with its time beside others without would be a table
    // whose columns disagree, so it is decided for them all.
    final bool clock =
        (unit == NebaChartTimeUnit.day || unit == NebaChartTimeUnit.week) &&
        rows.any(
          (_Row row) => row.spans.any(
            (_Span? one) => one != null && (_offMidnight(one.from) || _offMidnight(one.to)),
          ),
        );
    final List<String> rowNames = <String>[
      for (int index = 0; index < series.length; index++) series[index].name ?? '${index + 1}',
    ];
    final List<Color> colors = <Color>[
      for (int index = 0; index < series.length; index++)
        chartResolveColor(series[index].color, tokens) ??
            tokens.chart.series[index % tokens.chart.series.length],
    ];

    // The plot is described by how many spans it draws and when the first
    // starts and the last ends, rather than by the stand-in series below.
    int count = 0;
    double first = double.infinity;
    double last = double.negativeInfinity;

    for (final _Row row in rows) {
      for (final _Span? one in row.spans) {
        if (one != null) {
          count += 1;
          first = math.min(first, one.from);
          last = math.max(last, one.to);
        }
      }
    }

    final NebaChartAxis? given = yAxis;
    final NebaChartAxis valueAxis = NebaChartAxis(
      hidden: given?.hidden ?? false,
      label: given?.label,
      grid: given?.grid,
      tickCount: given?.tickCount,
      // The calendar's names for the ticks, unless the caller writes them.
      tickFormat:
          given?.tickFormat ??
          (Object value, int index) => index < tickTexts.length ? tickTexts[index] : '',
      tickAngle: given?.tickAngle ?? 0,
      thickness: given?.thickness,
    );
    final double thickness = barSize ?? chartBarMaxThickness[size ?? defaults.size ?? NebaSize.md]!;
    // The label column is there when any span names itself.
    final bool titled = series.any(
      (NebaTimelineSeries row) => row.data.any((NebaTimelinePoint point) => point.label != null),
    );

    return NebaCartesianChart<_Trace>(
      // The frame counts categories along the band axis and series within
      // each; a Gantt is the other way round, a row per thing with several
      // marks along it. So the rows are the categories, and one series stands
      // in with an entry per row, a `null` for a row with no span, which is
      // what makes a chart with none of them empty.
      series: <NebaChartSeries>[
        NebaChartSeries(
          data: <Object?>[
            for (final _Row row in rows) row.spans.any((_Span? one) => one != null) ? 1 : null,
          ],
        ),
      ],
      categories: rowNames,
      xAxis: xAxis,
      yAxis: valueAxis,
      references: references,
      // The rows run down the side and time runs along the bottom.
      horizontal: true,
      scale: scale,
      // A Gantt's rows are its axis, and a legend would restate them.
      legend: false,
      bandRatio: chartBarBandRatio[density]!,
      summary: count == 0
          ? (count: 0, min: '', max: '')
          : (
              count: count,
              min: chartTimeValue(first, unit, names, clock: clock),
              max: chartTimeValue(last, unit, names, clock: clock),
            ),
      height: height,
      format: format,
      locale: locale,
      label: label,
      tooltip: tooltip,
      empty: empty,
      variant: variant,
      size: size,
      color: color,
      density: this.density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      trace: (NebaChartLayout layout) => _traceSpans(
        layout,
        rows: rows,
        colors: colors,
        thickness: thickness,
        radius: rounded ? chartBarRadius : 0,
      ),
      traceKey: (series, thickness, rounded, tokens),
      marks: (_Trace traced) => traced.marks,
      markTooltip: (NebaChartMark mark) {
        final _Span? one = mark.series < rows.length && mark.index < rows[mark.series].spans.length
            ? rows[mark.series].spans[mark.index]
            : null;

        if (one == null) {
          return null;
        }

        // The span names itself when it can, and the row is then the second
        // line rather than a repeat of the first. Its value is a duration,
        // which is the one number a span has.
        return (
          heading: one.point.label ?? rowNames[mark.series],
          items: <NebaChartTooltipItem>[
            NebaChartTooltipItem(
              seriesIndex: mark.series,
              name: rowNames[mark.series],
              color: one.color ?? colors[mark.series],
              value: one.to - one.from,
              formatted:
                  '${chartTimeValue(one.from, unit, names, clock: clock)} – '
                  '${chartTimeValue(one.to, unit, names, clock: clock)}',
            ),
          ],
        );
      },
      painter: (NebaChartMarks<_Trace> marks) => _SpanPainter(marks: marks),
      // A row per span under the name of its row, rather than the frame's
      // grid: the third thing on one row and the third on another are
      // unrelated, and filing them side by side would invent a relationship.
      table: (String Function(double value) _) => NebaChartDataTable(
        caption: label,
        columns: <String>[
          xAxis?.label ?? '',
          if (titled) words['title']!,
          words['start']!,
          words['end']!,
        ],
        points: rows.fold<int>(0, (int sum, _Row row) => sum + row.spans.length),
        rows: <List<String>>[
          for (int index = 0; index < rows.length; index++)
            for (int at = 0; at < rows[index].spans.length; at++)
              <String>[
                rowNames[index],
                if (titled) series[index].data[at].label ?? '',
                switch (rows[index].spans[at]) {
                  final _Span one => chartTimeValue(one.from, unit, names, clock: clock),
                  null => '',
                },
                switch (rows[index].spans[at]) {
                  final _Span one => chartTimeValue(one.to, unit, names, clock: clock),
                  null => '',
                },
              ],
        ],
      ),
    );
  }
}

/// The precision a span's own dates are written at: the axis' unit, but never
/// coarser than a day, or a fortnight on an axis of months reads
/// `Mar 2026 – Mar 2026`.
NebaChartTimeUnit _spanUnit(NebaChartTimeUnit unit) {
  return unit == NebaChartTimeUnit.month ||
          unit == NebaChartTimeUnit.quarter ||
          unit == NebaChartTimeUnit.year
      ? NebaChartTimeUnit.day
      : unit;
}

/// Whether [time] falls anywhere but on the start of its own day.
bool _offMidnight(double time) {
  final DateTime at = DateTime.fromMillisecondsSinceEpoch(time.round());

  return at != DateTime(at.year, at.month, at.day);
}

/// A span once its two ends are numbers and it knows which lane it is in.
class _Span {
  _Span({required this.from, required this.to, required this.color, required this.point});

  final double from;
  final double to;
  final Color? color;
  final NebaTimelinePoint point;
  int lane = 0;
}

/// One row's spans, in the order they were given, `null` where an end is not
/// an instant, and how many lanes they take.
class _Row {
  _Row(this.spans, this.lanes);

  final List<_Span?> spans;
  final int lanes;
}

/// [row]'s spans placed, the overlapping ones moved onto lanes of their own.
///
/// The greedy packing every scheduler uses: walk the spans in start order and
/// drop each into the first lane whose last span has finished. A row with no
/// overlaps stays in one lane, and the lanes are stored against each span's
/// own place, since the order the data was written in is the order the keys
/// walk.
_Row _pack(NebaTimelineSeries row, NebaTokens tokens) {
  final List<_Span?> spans = <_Span?>[
    for (final NebaTimelinePoint point in row.data)
      if ((chartToNumber(point.start), chartToNumber(point.end)) case (
        final double start,
        final double end,
      ))
        // Either way round: a span written backwards is a typo, and drawn as
        // a bar of negative width it would be a blank row.
        _Span(
          from: math.min(start, end),
          to: math.max(start, end),
          color: chartResolveColor(point.color, tokens),
          point: point,
        )
      else
        null,
  ];
  final List<_Span> ordered = <_Span>[for (final _Span? one in spans) ?one];
  final List<double> ends = <double>[];

  // Sorted with the place as the tie-break, since a Dart sort is not stable.
  final List<int> order = List<int>.generate(ordered.length, (int at) => at)
    ..sort((int a, int b) {
      final int byStart = ordered[a].from.compareTo(ordered[b].from);

      return byStart != 0 ? byStart : a.compareTo(b);
    });

  for (final int at in order) {
    final _Span one = ordered[at];
    final int free = ends.indexWhere((double end) => end <= one.from);
    final int lane = free == -1 ? ends.length : free;

    if (lane == ends.length) {
      ends.add(one.to);
    } else {
      ends[lane] = one.to;
    }

    one.lane = lane;
  }

  return _Row(spans, math.max(1, ends.length));
}

/// One span as it is drawn: its bar, cut to the plot, and its fill.
class _Bar {
  _Bar({required this.rect, required this.radius, required this.color});

  final Rect rect;
  final double radius;
  final Color color;
}

/// Every span, laid out once per layout: the marks the pointer and the keys
/// are read against, in the order the data was given, and each one's bar,
/// `null` where the bar falls off the plot.
class _Trace {
  _Trace(this.marks, this.bars);

  final List<NebaChartMark> marks;
  final List<_Bar?> bars;
}

/// Lays out the spans of every row on [layout], the React package's `marks`
/// builder and `Spans`.
///
/// A row's lanes share its band as grouped bars share a category's, each an
/// equal cut with the two pixels of surface between them, the group centred
/// on the row's own place. A span wholly outside a pinned end is not drawn,
/// so it is not something the keys can stop on either.
_Trace _traceSpans(
  NebaChartLayout layout, {
  required List<_Row> rows,
  required List<Color> colors,
  required double thickness,
  required double radius,
}) {
  final List<NebaChartMark> marks = <NebaChartMark>[];
  final List<_Bar?> bars = <_Bar?>[];
  final Rect plot = layout.plot;

  for (int index = 0; index < rows.length; index++) {
    final _Row row = rows[index];
    final double height = math.min(
      thickness,
      math.max(1, (layout.band.band - chartMarkGap * (row.lanes - 1)) / row.lanes),
    );
    final double group = height * row.lanes + chartMarkGap * (row.lanes - 1);
    final double top = layout.categoryAt(index) - group / 2 + height / 2;

    for (int at = 0; at < row.spans.length; at++) {
      final _Span? one = row.spans[at];

      if (one == null || one.to < layout.scale.min || one.from > layout.scale.max) {
        continue;
      }

      final double from = layout.valuePx(one.from);
      final double to = layout.valuePx(one.to);
      final Offset centre = Offset((from + to) / 2, top + one.lane * (height + chartMarkGap));
      final double half = math.max(0, (to - from) / 2);

      // A box and not a disc: a fortnight is two hundred pixels of bar whose
      // centre the pointer may never go near.
      marks.add(
        NebaChartMark(
          series: index,
          index: at,
          centre: centre,
          r: height / 2,
          rx: half,
          ry: height / 2,
        ),
      );

      // Cut to the plot rather than to the data: a bar that stops at the edge
      // says there is more of it off the side. A span of no length keeps a
      // hairline, so a milestone is still something on the row.
      final double left = math.max(plot.left, centre.dx - half);
      final double right = math.min(plot.right, centre.dx + half);

      if (right < plot.left || left > plot.right) {
        bars.add(null);
        continue;
      }

      final double width = math.max(1, right - left);

      bars.add(
        _Bar(
          rect: Rect.fromLTWH(left, centre.dy - height / 2, width, height),
          radius: math.min(radius, math.min(width / 2, height / 2)),
          color: one.color ?? colors[index],
        ),
      );
    }
  }

  return _Trace(marks, bars);
}

/// Paints the spans, each drawn back until the reader reads it. Both ends of
/// a span are rounded: it meets no axis, so neither end is the one the reader
/// measures from.
class _SpanPainter extends CustomPainter {
  _SpanPainter({required this.marks}) : super(repaint: marks.emphasis);

  final NebaChartMarks<_Trace> marks;

  @override
  void paint(Canvas canvas, Size size) {
    final List<_Bar?> bars = marks.traced.bars;

    for (int at = 0; at < bars.length; at++) {
      final _Bar? bar = bars[at];

      if (bar == null) {
        continue;
      }

      final double lift = _restOpacity + (1 - _restOpacity) * marks.emphasis.growthOf(at);

      canvas.drawRRect(
        RRect.fromRectAndRadius(bar.rect, Radius.circular(bar.radius)),
        Paint()..color = bar.color.withValues(alpha: bar.color.a * lift),
      );
    }
  }

  @override
  bool shouldRepaint(_SpanPainter oldDelegate) {
    return !identical(oldDelegate.marks.traced, marks.traced) ||
        !identical(oldDelegate.marks.layout, marks.layout) ||
        oldDelegate.marks.activeMark != marks.activeMark ||
        !identical(oldDelegate.marks.emphasis, marks.emphasis);
  }
}
