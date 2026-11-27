/// `NebaScatterChart` and `NebaScatterShape`, two measures per point drawn
/// against each other.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/messages.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// What each mark of a [NebaScatterChart] is drawn as.
enum NebaScatterShape {
  /// A circle while colour alone can tell the series apart, and a shape per
  /// series from the fourth on: past three, two of the palette's hues are
  /// indistinguishable under deuteranopia, and a shape is the one channel a
  /// dot has going spare.
  auto,

  /// A shape per series always, in the fixed order circle, square, triangle,
  /// diamond, cross: for a chart that will be printed or read in greyscale.
  varied,

  /// Every mark a circle.
  circle,

  /// Every mark a square.
  square,

  /// Every mark a triangle.
  triangle,

  /// Every mark a diamond.
  diamond,

  /// Every mark a cross.
  cross,
}

/// How many series the palette can tell apart where any two marks may end up
/// side by side: run on every pair rather than on the pairs that touch, the
/// colour-vision check separates three slots and no more.
const int _separableSeries = 3;

/// The smallest a bubble is drawn, so a small but real value does not
/// disappear.
const double _minBubble = 2;

/// Two numbers per point, and whether they move together.
///
/// Both axes measure, which makes this the one chart with no categories:
/// there is no column a mark belongs to and no order the points could be
/// shuffled out of. A point with a `z` is drawn as a bubble and one without
/// it as a dot, so a scatter and a bubble chart are the same widget reading
/// the same data.
///
/// Every point's `x` is a [num] or a [DateTime]. A string has no place on a
/// number line, and a chart of named things against one measure is a
/// `NebaBarChart`.
///
/// ```dart
/// const NebaScatterChart(
///   label: 'Pages read against session length',
///   xAxis: NebaChartAxis(label: 'Seconds on site'),
///   yAxis: NebaChartAxis(label: 'Pages'),
///   series: <NebaChartSeries>[
///     NebaChartSeries(
///       name: 'Organic',
///       data: <NebaChartPoint>[
///         NebaChartPoint(x: 22, y: 2),
///         NebaChartPoint(x: 41, y: 3),
///       ],
///     ),
///   ],
/// )
/// ```
class NebaScatterChart extends StatelessWidget {
  /// A scatter of [series].
  const NebaScatterChart({
    required this.series,
    this.categories,
    this.xAxis,
    this.yAxis,
    this.references,
    this.shape = NebaScatterShape.auto,
    this.pointRadius,
    this.maxRadius,
    this.height,
    this.format,
    this.locale,
    this.label,
    this.legend,
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
  }) : assert(legend == null || legend is bool || legend is NebaChartLegend),
       assert(tooltip == null || tooltip is bool || tooltip is NebaChartTooltip);

  /// The series. Every point carries an `x` and a `y` as numbers, and one
  /// that also carries a `z` is drawn as a bubble.
  final List<NebaChartSeries> series;

  /// The `x` of a point that does not carry its own, found by its index: a
  /// [num] or a [DateTime].
  final List<Object>? categories;

  /// The x axis. Here it is a second value axis rather than a category axis:
  /// it ticks at rounded numbers, is never forced through zero, and casts a
  /// grid unless its `grid` says otherwise.
  final NebaChartAxis? xAxis;

  /// The value axis, never forced through zero either.
  final NebaChartAxis? yAxis;

  /// Lines and bands drawn across the plot at values the data has none of. A
  /// reference on the category axis is a number on the x scale.
  final List<NebaChartReference>? references;

  /// What each mark is drawn as.
  final NebaScatterShape shape;

  /// The radius of a mark with no `z`, in logical pixels. The size ladder
  /// when left out: 3, 3.5, 4, 4.5 and 5.
  final double? pointRadius;

  /// The radius of the largest bubble, in logical pixels, with every other
  /// one scaled under it by area. A twelfth of the chart's height when left
  /// out.
  final double? maxRadius;

  /// How tall the drawing is, the axis labels inside it. The size ladder
  /// when left out: 120, 160, 220, 280 and 360 logical pixels.
  final double? height;

  /// How a `y` is written: the value axis, the tooltip and the table. The x
  /// axis writes its ticks through `xAxis.tickFormat`, and the table writes
  /// `x` and `z` as numbers of their own.
  final String Function(num value)? format;

  /// The language of the chart's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartLegend]. Shown from two series up when
  /// left out, with each series' swatch in the shape of its marks.
  final Object? legend;

  /// `true`, `false` or a [NebaChartTooltip]. Always about one mark, the one
  /// nearest the pointer, so `mode` and `crosshair` are not read.
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type, the marks and the height. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet and the focus ring. A series' colour does not
  /// come from here.
  final NebaColor color;

  /// How much padding the sheet has.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads the chart.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final double dot = pointRadius ?? chartMarkerRadii[size]!;
    // How much room the biggest mark needs, which is also how big it may get.
    // Measured off the chart's height rather than off the plot, which is only
    // that size once this room has been taken out of it.
    final double reserve = maxRadius ?? math.max(dot + 2, (height ?? chartPlotHeights[size]!) / 12);
    // Only the series taking a palette slot count against the ceiling: a
    // caller who gave every series a colour has already answered the
    // question it exists to ask.
    final int palettes = series.where((NebaChartSeries one) => one.color == null).length;
    final NebaMarkShape plain = switch (shape) {
      NebaScatterShape.auto ||
      NebaScatterShape.varied ||
      NebaScatterShape.circle => NebaMarkShape.circle,
      NebaScatterShape.square => NebaMarkShape.square,
      NebaScatterShape.triangle => NebaMarkShape.triangle,
      NebaScatterShape.diamond => NebaMarkShape.diamond,
      NebaScatterShape.cross => NebaMarkShape.cross,
    };
    final bool varied =
        shape == NebaScatterShape.varied ||
        (shape == NebaScatterShape.auto && palettes > _separableSeries);

    // By its place in the list it was passed, as its colour is, so hiding a
    // series from the legend cannot reshape the ones that are left.
    NebaMarkShape shapeOf(int index) {
      return varied ? NebaMarkShape.values[index % NebaMarkShape.values.length] : plain;
    }

    return NebaCartesianChart<_ScatterTrace>(
      series: series,
      categories: categories,
      xAxis: xAxis,
      yAxis: yAxis,
      references: references,
      valueCategories: true,
      // Neither axis is forced to zero: what a position encodes is a place,
      // so cropping a scale slides every mark by the same amount and the
      // shape of the cloud survives.
      includeZero: false,
      markInset: reserve,
      height: height,
      format: format,
      locale: locale,
      label: label,
      legend: legend,
      tooltip: tooltip,
      empty: empty,
      variant: variant,
      size: this.size,
      color: color,
      density: density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      trace: (NebaChartLayout layout) =>
          _traceMarks(layout, categories: categories, dot: dot, reserve: reserve, shapeOf: shapeOf),
      traceKey: (categories, dot, reserve, varied, plain),
      marks: (_ScatterTrace traced) => traced.marks,
      painter: (NebaChartMarks<_ScatterTrace> marks) => _ScatterPainter(marks: marks),
      swatch: (int index, Color color) => _Swatch(shape: shapeOf(index), color: color),
      table: (String Function(double value) format) => _ScatterTable(
        series: series,
        categories: categories,
        label: label,
        xLabel: xAxis?.label,
        yLabel: yAxis?.label,
        locale: locale,
        format: format,
      ),
    );
  }
}

/// One mark as it is drawn: its shape, its outline and its fill.
class _Dot {
  _Dot({required this.shape, required this.path, required this.color});

  final NebaMarkShape shape;
  final Path path;
  final Color color;
}

/// Every mark, laid out once per layout.
///
/// [marks] is in the order the data was given, which is the order the arrow
/// keys walk; [order] is the order they are painted in, largest first, so a
/// small bubble inside a big one is drawn over it rather than under it.
class _ScatterTrace {
  _ScatterTrace({
    required this.marks,
    required this.dots,
    required this.order,
    required this.bubbles,
  });

  final List<NebaChartMark> marks;
  final List<_Dot> dots;
  final List<int> order;

  /// Whether any point has a `z`. Without one every mark is the same size, so
  /// largest first is the data's own order and each series fades as one
  /// group; with one, the paint order runs across the series and each mark
  /// fades on its own.
  final bool bubbles;
}

/// Lays out every shown series' marks on [layout], the React package's
/// `marks` builder and `ScatterMarks`.
///
/// One `z` scale for the whole chart, taken over every series rather than
/// the shown ones: two bubbles the same size mean the same number wherever
/// they are, and a size that changed with the legend would be a legend that
/// rewrites the data.
_ScatterTrace _traceMarks(
  NebaChartLayout layout, {
  required List<Object>? categories,
  required double dot,
  required double reserve,
  required NebaMarkShape Function(int index) shapeOf,
}) {
  double biggest = 0;
  bool bubbles = false;

  for (final List<NebaChartValue> one in layout.values) {
    for (final NebaChartValue value in one) {
      final double? z = value.z;

      if (z == null) {
        continue;
      }

      bubbles = true;

      if (value.value != null && z.isFinite) {
        biggest = math.max(biggest, z);
      }
    }
  }

  final List<NebaChartMark> marks = <NebaChartMark>[];
  final List<_Dot> dots = <_Dot>[];

  for (int series = 0; series < layout.values.length; series++) {
    if (!layout.visible[series]) {
      continue;
    }

    final List<NebaChartValue> one = layout.values[series];
    final NebaMarkShape shape = shapeOf(series);

    for (int index = 0; index < one.length; index++) {
      final NebaChartValue value = one[index];
      final double? y = value.value;
      final double? x = chartPointX(value, index, categories);

      if (y == null || x == null) {
        continue;
      }

      final double? z = value.z;
      // With its series, so a mark is placed against the scale it is
      // measured on.
      final Offset centre = Offset(layout.categoryValuePx(x), layout.valuePx(y, series));
      final double r = z == null ? dot : chartBubbleRadius(z, biggest, reserve, _minBubble);

      marks.add(NebaChartMark(series: series, index: index, centre: centre, r: r));
      dots.add(
        _Dot(
          shape: shape,
          path: chartMarkPath(shape, centre, r),
          color: chartResolveColor(value.color, layout.tokens) ?? layout.colors[series],
        ),
      );
    }
  }

  // Sorted with the place as the tie-break, since a Dart sort is not stable.
  final List<int> order = List<int>.generate(marks.length, (int at) => at)
    ..sort((int a, int b) {
      final int bySize = marks[b].r.compareTo(marks[a].r);

      return bySize != 0 ? bySize : a.compareTo(b);
    });

  return _ScatterTrace(marks: marks, dots: dots, order: order, bubbles: bubbles);
}

/// Paints a [_ScatterTrace]: every mark ringed by the surface, largest first,
/// faded by the legend and grown a pixel under the pointer.
///
/// The ring is the surface showing through rather than a stroke around the
/// mark, which is what keeps two overlapping dots two dots.
class _ScatterPainter extends CustomPainter {
  _ScatterPainter({required this.marks}) : super(repaint: marks.emphasis);

  final NebaChartMarks<_ScatterTrace> marks;

  @override
  void paint(Canvas canvas, Size size) {
    final _ScatterTrace trace = marks.traced;
    final NebaChartEmphasis emphasis = marks.emphasis;
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartMarkGap
      ..color = marks.layout.tokens.chartGap;

    void draw(int at) {
      final NebaChartMark mark = trace.marks[at];
      final _Dot dot = trace.dots[at];
      final double growth = mark.r > 0 ? emphasis.growthOf(at) : 0;
      // A pixel bigger under the pointer, about the point it is pinned to.
      final Path path = growth > 0
          ? chartMarkPath(dot.shape, mark.centre, mark.r + growth)
          : dot.path;

      canvas
        ..drawPath(path, Paint()..color = dot.color)
        ..drawPath(path, ring);
    }

    if (!trace.bubbles) {
      // Every mark the same size: the data's own order, series by series,
      // and each series fades as one group, as a line does.
      int start = 0;

      while (start < trace.order.length) {
        final int series = trace.marks[trace.order[start]].series;
        int end = start;

        while (end < trace.order.length && trace.marks[trace.order[end]].series == series) {
          end += 1;
        }

        final double opacity = emphasis.opacityOf(series);

        if (opacity < 1) {
          canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
        }

        for (int at = start; at < end; at++) {
          draw(trace.order[at]);
        }

        if (opacity < 1) {
          canvas.restore();
        }

        start = end;
      }

      return;
    }

    // Bubbles are painted largest first across every series, so a group per
    // series would reorder them: each fades on its own.
    for (final int at in trace.order) {
      final NebaChartMark mark = trace.marks[at];
      final double opacity = emphasis.opacityOf(mark.series);

      if (opacity < 1) {
        canvas.saveLayer(
          Rect.fromCircle(center: mark.centre, radius: mark.r * 1.6 + chartMarkGap + 1),
          Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
        );
      }

      draw(at);

      if (opacity < 1) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ScatterPainter oldDelegate) {
    return !identical(oldDelegate.marks.traced, marks.traced) ||
        !identical(oldDelegate.marks.layout, marks.layout) ||
        oldDelegate.marks.activeMark != marks.activeMark ||
        !identical(oldDelegate.marks.emphasis, marks.emphasis);
  }
}

/// A legend row's swatch, in the shape its series' marks are drawn in.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.shape, required this.color});

  final NebaMarkShape shape;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size.square(10), painter: _SwatchPainter(shape, color));
  }
}

class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.shape, this.color);

  final NebaMarkShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(chartMarkPath(shape, size.center(Offset.zero), 4), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SwatchPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}

/// The scatter as a table: a row per point, with its series, its `x`, its `y`
/// and, when any point has one, its `z`.
///
/// A row per point rather than the frame's grid of categories against
/// series, because two points that are both the fifth of their series have
/// nothing to do with each other. The columns are named from the axis labels,
/// and `x` and `y` when there are none; the size column is a word in the
/// chart's language. `x` and `z` are written as numbers of their own, never
/// through `format`, which is the value axis'.
class _ScatterTable extends StatelessWidget {
  const _ScatterTable({
    required this.series,
    required this.categories,
    required this.label,
    required this.xLabel,
    required this.yLabel,
    required this.locale,
    required this.format,
  });

  final List<NebaChartSeries> series;
  final List<Object>? categories;
  final String? label;
  final String? xLabel;
  final String? yLabel;
  final Locale? locale;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> words = nebaMessages(context, 'chart', locale: locale);
    final List<List<NebaChartValue>> values = chartValuesOf(series);
    final bool sized = values.any(
      (List<NebaChartValue> one) => one.any((NebaChartValue value) => value.z != null),
    );
    final List<Object>? categories = this.categories;

    String written(Object x) => x is num ? nebaFormatNumber(x) : chartCategoryText(x);

    return NebaChartDataTable(
      caption: label,
      columns: <String>['', xLabel ?? 'x', yLabel ?? 'y', if (sized) words['size']!],
      points: values.fold<int>(0, (int sum, List<NebaChartValue> one) => sum + one.length),
      rows: <List<String>>[
        for (int index = 0; index < values.length; index++)
          for (int at = 0; at < values[index].length; at++)
            <String>[
              series[index].name ?? '${index + 1}',
              written(
                values[index][at].x ??
                    (categories != null && at < categories.length ? categories[at] : at),
              ),
              // A gap is an empty cell, as on every other chart's table.
              switch (values[index][at].value) {
                final double y => format(y),
                null => '',
              },
              if (sized)
                switch (values[index][at].z) {
                  final double z => nebaFormatNumber(z),
                  null => '',
                },
            ],
      ],
    );
  }
}
