/// `NebaBarChart`, lengths compared across categories.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/types.dart';

/// Lengths, compared.
///
/// A bar says how much, and it says it by being longer, which is why its
/// value axis keeps zero unless `yAxis` pins an end: crop the scale and a bar
/// twice as long stops meaning twice as much. Reach for a `NebaLineChart`
/// when what matters is the shape of a change rather than the size of each
/// value.
///
/// Grouped bars answer "which series is bigger here"; stacked bars answer
/// "what is this total made of". Turned on its side with [orientation], the
/// chart gives each category name a row of its own, which is the right answer
/// whenever the names are words.
///
/// ```dart
/// const NebaBarChart(
///   label: 'Deploys per team',
///   categories: <Object>['Platform', 'Payments', 'Growth'],
///   series: <NebaChartSeries>[
///     NebaChartSeries(name: 'Deploys', data: <num>[318, 264, 197]),
///   ],
///   valueLabels: NebaChartValueLabels.all,
/// )
/// ```
class NebaBarChart extends StatelessWidget {
  /// A bar chart of [series].
  const NebaBarChart({
    required this.series,
    this.categories,
    this.xAxis,
    this.yAxis,
    this.secondaryAxis,
    this.references,
    this.orientation = NebaOrientation.vertical,
    this.stacked = NebaChartStacking.off,
    this.rounded = true,
    this.barSize,
    this.valueLabels = NebaChartValueLabels.none,
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

  /// The series, in the order their colours are handed out.
  final List<NebaChartSeries> series;

  /// What each category is called: a [String], a [num] or a [DateTime].
  /// Points may carry their own `x` instead.
  final List<Object>? categories;

  /// The category axis, whichever way the bars run.
  final NebaChartAxis? xAxis;

  /// The value axis, whichever way the bars run. It keeps zero in its range:
  /// a bar's length is its value. Stacked to [NebaChartStacking.full], it runs
  /// from 0 to 100 and writes a percentage unless it says otherwise.
  final NebaChartAxis? yAxis;

  /// A second value axis on the far edge, for the series whose `axis` is
  /// [NebaChartSeriesAxis.secondary]. Not read on a stacked chart.
  final NebaChartAxis? secondaryAxis;

  /// Lines and bands drawn across the plot at values the data has none of.
  final List<NebaChartReference>? references;

  /// Which way the bars run: up from the bottom, or out from the start edge
  /// with the category names in a column of their own.
  final NebaOrientation orientation;

  /// How the bars stack: side by side, each on the total of the ones before
  /// it, or every bar the same length so the chart is about the mix.
  final NebaChartStacking stacked;

  /// Cuts the corners off the data end of each bar. The baseline end stays
  /// square, where the value starts from.
  final bool rounded;

  /// How thick a bar may get, in logical pixels. The size ladder when left
  /// out: 14, 18, 24, 30 and 36.
  final double? barSize;

  /// Which values are written past the ends of the bars.
  final NebaChartValueLabels valueLabels;

  /// How tall the drawing is, the axis labels inside it. The size ladder
  /// when left out: 120, 160, 220, 280 and 360 logical pixels.
  final double? height;

  /// How a number is written everywhere it appears: the axis, the tooltip,
  /// the value labels and the table. Stacked to full, the tooltip, the labels
  /// and the table write the caller's own numbers through it.
  final String Function(num value)? format;

  /// The language of the chart's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartLegend]. Shown from two series up when
  /// left out.
  final Object? legend;

  /// `true`, `false` or a [NebaChartTooltip].
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type, the bar thickness and the height. Defaults to `NebaProvider`'s,
  /// then [NebaSize.md].
  final NebaSize? size;

  /// The family of the sheet and the focus ring. A series' colour does not
  /// come from here.
  final NebaColor color;

  /// How much of each band the bars take, and the sheet's padding. Defaults
  /// to `NebaProvider`'s, then [NebaDensity.standard].
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads the chart.
  final bool padded;

  /// How the chart arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final NebaDensity density =
        this.density ?? NebaTheme.defaultsOf(context).density ?? NebaDensity.standard;
    final bool full = stacked == NebaChartStacking.full;
    final bool stacks = stacked != NebaChartStacking.off;

    return NebaCartesianChart<_BarTrace>(
      series: series,
      categories: categories,
      xAxis: xAxis,
      // A share of a hundred, unless the caller said otherwise about any of it.
      yAxis: full ? chartShareAxis(yAxis) : yAxis,
      secondaryAxis: secondaryAxis,
      references: references,
      stacked: stacks,
      // A hundred per cent is worked out by the frame, which knows which
      // series the legend has hidden and so which ones it is shared between.
      stackedFull: full,
      // A bar's length is its value, so zero is not optional.
      includeZero: true,
      horizontal: orientation == NebaOrientation.horizontal,
      bandRatio: chartBarBandRatio[density]!,
      headroom: valueLabels == NebaChartValueLabels.none ? 0 : _labelHeadroom,
      height: height,
      format: format,
      locale: locale,
      label: label,
      legend: legend,
      tooltip: tooltip,
      empty: empty,
      variant: variant,
      size: size,
      color: color,
      density: this.density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      trace: (NebaChartLayout layout) => _traceBars(
        layout,
        stacked: stacks,
        rounded: rounded,
        barSize: barSize ?? chartBarMaxThickness[layout.size]!,
        valueLabels: valueLabels,
      ),
      traceKey: (stacks, rounded, barSize, valueLabels),
      painter: (NebaChartMarks<_BarTrace> marks) => _BarPainter(marks: marks),
    );
  }
}

/// The room kept above the plot for the labels on the bars.
const double _labelHeadroom = 12;

/// How far a bar outside the active column is drawn back, so the column under
/// the crosshair reads as the one being read.
const double _restOpacity = 0.92;

/// One bar, laid out: its box, its outline, its fill, and the number written
/// past its end.
class _Bar {
  _Bar({
    required this.category,
    required this.rect,
    required this.path,
    required this.color,
    required this.label,
  });

  final int category;
  final Rect rect;
  final Path path;
  final Color color;
  final NebaChartLabel? label;
}

/// One shown series' bars, in category order, with none for a gap.
class _BarSeries {
  _BarSeries(this.index, this.bars);

  final int index;
  final List<_Bar> bars;
}

/// Every shown series' bars, laid out once per layout.
///
/// What the pointer changes is which column is active and which series the
/// legend is pointing at, and neither moves a bar: the painter reads both off
/// the chart's emphasis.
class _BarTrace {
  _BarTrace(this.series);

  final List<_BarSeries> series;
}

/// Lays out the bars of every shown series of [layout], the React package's
/// `Bars`.
///
/// Two arrangements out of one loop: grouped bars split the band between the
/// shown series, [stacked] ones take the whole band and are pushed along by
/// whatever came before them, a positive segment from the total above zero
/// and a negative one from the total below it, so a series that dips does not
/// take a bite out of the one above. In both, the two pixels between touching
/// marks are the surface showing through and never a stroke: a border drawn
/// around a bar is ink that is not data. [barSize] caps a bar's thickness, and
/// past it the band keeps the rest as air.
_BarTrace _traceBars(
  NebaChartLayout layout, {
  required bool stacked,
  required bool rounded,
  required double barSize,
  required NebaChartValueLabels valueLabels,
}) {
  final List<int> drawn = <int>[
    for (int index = 0; index < layout.values.length; index++)
      if (layout.visible[index]) index,
  ];
  final int lanes = stacked ? 1 : math.max(1, drawn.length);
  final double laneWidth = math.min(
    barSize,
    math.max(1, (layout.band.band - chartMarkGap * (lanes - 1)) / lanes),
  );
  final double groupWidth = laneWidth * lanes + chartMarkGap * (lanes - 1);
  // A segment inside a stack is rounded half as much, so the seams read as
  // seams rather than as a row of pills.
  final double radius = !rounded
      ? 0
      : stacked
      ? chartBarRadius / 2
      : chartBarRadius;
  final bool horizontal = layout.horizontal;
  final double fontSize = layout.fontSize;

  // Where each stacked segment starts, per category and per sign.
  final Map<int, double> above = <int, double>{};
  final Map<int, double> below = <int, double>{};
  final List<_BarSeries> series = <_BarSeries>[];

  for (int lane = 0; lane < drawn.length; lane++) {
    final int index = drawn[lane];
    final List<NebaChartValue> one = layout.values[index];
    final bool Function(int category) labelled = chartLabelledPoints(one, valueLabels);
    final String Function(double value) write = layout.formatFor(index);
    final double offset = stacked
        ? 0
        : lane * (laneWidth + chartMarkGap) - groupWidth / 2 + laneWidth / 2;
    final List<_Bar> bars = <_Bar>[];

    for (int category = 0; category < one.length; category++) {
      final double? value = one[category].value;

      if (value == null) {
        continue;
      }

      final double base = stacked ? (value >= 0 ? above[category] : below[category]) ?? 0 : 0;
      // With the series, so a bar measured on the far edge's scale is drawn
      // against that one. A stack and a second axis never both apply, so the
      // base is zero wherever the series changes the answer.
      final double from = base == 0 ? layout.zeroPxOf(index) : layout.valuePx(base, index);
      final double to = layout.valuePx(base + value, index);

      if (stacked) {
        (value >= 0 ? above : below)[category] = base + value;
      }

      // The seam between two segments is taken off the end of the later one
      // that meets the earlier, so the stack still totals the right length
      // and the gap is the sheet rather than a line drawn on it.
      final double shrink = stacked && base != 0 ? chartMarkGap : 0;
      final double length = (to - from).abs() - shrink;

      if (length <= 0) {
        continue;
      }

      final bool grows = to < from;
      final double start = math.min(from, to) + (grows ? 0 : shrink);
      final double middle = layout.categoryAt(category) + offset;
      final Rect rect = horizontal
          ? Rect.fromLTWH(start, middle - laneWidth / 2, length, laneWidth)
          : Rect.fromLTWH(middle - laneWidth / 2, start, laneWidth, length);
      final bool positive = value >= 0;
      final Color fill =
          chartResolveColor(one[category].color, layout.tokens) ?? layout.colors[index];

      // Just past the data end, on the outside, which for a bar that grows
      // downward is below it: kept off the fill so it never has to be white on
      // one bar and ink on the next. In its own bar's colour, a step toward the
      // page's ink, because on a grouped chart the label sits over the gap
      // between two bands and the hue says which of the two it belongs to.
      final NebaChartLabel? label = valueLabels != NebaChartValueLabels.none && labelled(category)
          ? NebaChartLabel(
              chartTextPainter(
                one[category].label ?? write(value),
                layout.textStyle.copyWith(
                  color: chartLabelInk(fill, layout.tokens),
                  fontWeight: FontWeight.w500,
                ),
                layout.textDirection,
              ),
              horizontal
                  ? Offset(to + (positive ? 5 : -5), middle)
                  : Offset(middle, positive ? to - 5 : to + fontSize + 2),
              anchor: horizontal ? (positive ? 1 : -1) : 0,
              central: horizontal,
            )
          : null;

      bars.add(
        _Bar(
          category: category,
          rect: rect,
          path: chartBarPath(
            rect,
            radius,
            horizontal
                ? (positive ? NebaChartBarEnd.right : NebaChartBarEnd.left)
                : (positive ? NebaChartBarEnd.up : NebaChartBarEnd.down),
          ),
          color: fill,
          label: label,
        ),
      );
    }

    series.add(_BarSeries(index, bars));
  }

  return _BarTrace(series);
}

/// Paints a [_BarTrace]: each shown series' bars and value labels, faded and
/// brought forward by the chart's emphasis, and the baseline over them.
class _BarPainter extends CustomPainter {
  _BarPainter({required this.marks}) : super(repaint: marks.emphasis);

  final NebaChartMarks<_BarTrace> marks;

  @override
  void paint(Canvas canvas, Size size) {
    final NebaChartLayout layout = marks.layout;
    final NebaChartEmphasis emphasis = marks.emphasis;

    for (final _BarSeries trace in marks.traced.series) {
      final double opacity = emphasis.opacityOf(trace.index);
      final bool faded = opacity < 1;

      if (faded) {
        canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
      }

      for (final _Bar bar in trace.bars) {
        // The bar under the crosshair comes forward, eased like the fade.
        final double lift = _restOpacity + (1 - _restOpacity) * emphasis.growthOf(bar.category);

        canvas.drawPath(bar.path, Paint()..color = bar.color.withValues(alpha: bar.color.a * lift));
        bar.label?.paint(canvas);
      }

      if (faded) {
        canvas.restore();
      }
    }

    // The baseline, drawn again over the bars. Every bar starts here and the
    // line is what says so; under them it would be half hidden by the first
    // pixel of each one.
    final Rect plot = layout.plot;
    final double zero = layout.zeroPxOf();

    chartPaintRule(
      canvas,
      layout.horizontal ? Offset(zero, plot.top) : Offset(plot.left, zero),
      layout.horizontal ? Offset(zero, plot.bottom) : Offset(plot.right, zero),
      layout.tokens.chartBaseline,
    );
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) {
    return !identical(oldDelegate.marks.traced, marks.traced) ||
        !identical(oldDelegate.marks.layout, marks.layout) ||
        oldDelegate.marks.activeIndex != marks.activeIndex ||
        !identical(oldDelegate.marks.emphasis, marks.emphasis);
  }
}
