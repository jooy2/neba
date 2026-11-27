/// `NebaLineChart`, values against an ordered axis, joined.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/chart_line.dart';
import 'package:neba/src/types.dart';

/// A value against time, or against anything else with an order to it.
///
/// The line is the mark that says change: it claims the space between two
/// points is a journey rather than two separate facts. Everything around it,
/// the axes, the grid, the crosshair, the legend, the tooltip and the table a
/// screen reader reads instead of the picture, is the frame every chart
/// shares, so a line chart and a bar chart on one dashboard read as one
/// drawing.
///
/// The value axis is cropped to the data, because a line encodes a position:
/// pass `yAxis: NebaChartAxis(min: 0)` when zero belongs on the scale.
///
/// ```dart
/// const NebaLineChart(
///   label: 'Weekly active users by month',
///   categories: <Object>['Jan', 'Feb', 'Mar'],
///   series: <NebaChartSeries>[
///     NebaChartSeries(name: 'Web', data: <num>[1820, 1960, 2140]),
///     NebaChartSeries(name: 'Mobile', data: <num>[940, 1120, 1310]),
///   ],
/// )
/// ```
class NebaLineChart extends StatelessWidget {
  /// A line chart of [series].
  const NebaLineChart({
    required this.series,
    this.categories,
    this.xAxis,
    this.yAxis,
    this.secondaryAxis,
    this.references,
    this.curve = NebaChartCurve.linear,
    this.markers = NebaChartMarkers.auto,
    this.gradient = false,
    this.nulls = NebaChartNulls.gap,
    this.valueLabels = NebaChartValueLabels.none,
    this.stacked = false,
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

  /// The category axis.
  final NebaChartAxis? xAxis;

  /// The value axis.
  final NebaChartAxis? yAxis;

  /// A second value axis on the far edge, for the series whose `axis` is
  /// [NebaChartSeriesAxis.secondary]. Passing it is what turns the split on,
  /// and a stacked chart does not read it.
  final NebaChartAxis? secondaryAxis;

  /// Lines and bands drawn across the plot at values the data has none of.
  final List<NebaChartReference>? references;

  /// How the line gets from one point to the next.
  final NebaChartCurve curve;

  /// Dots on the points. Whatever this says, the point under the pointer gets
  /// one.
  final NebaChartMarkers markers;

  /// Fades each line from a paler step of its own hue at the start to the full
  /// colour at the end.
  final bool gradient;

  /// What the line does where a value is missing.
  final NebaChartNulls nulls;

  /// Which values are written on the line.
  final NebaChartValueLabels valueLabels;

  /// Stacks the series, each line riding on the total of the ones below it.
  final bool stacked;

  /// How tall the drawing is, the axis labels inside it. The size ladder
  /// when left out: 120, 160, 220, 280 and 360 logical pixels.
  final double? height;

  /// How a number is written everywhere it appears: the axis, the tooltip,
  /// the value labels and the table. Without it, past ten thousand a number
  /// is compacted (`12.4K`).
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

  /// The type, the line weight, the markers and the height. Defaults to
  /// `NebaProvider`'s, then [NebaSize.md].
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
    return NebaCartesianChart<NebaLineTrace>(
      series: series,
      categories: categories,
      xAxis: xAxis,
      yAxis: yAxis,
      secondaryAxis: secondaryAxis,
      references: references,
      stacked: stacked,
      zeroGaps: nulls == NebaChartNulls.zero,
      // A line sits on its category tick, and its value axis is free to leave
      // zero out: what it encodes is a position, so cropping moves every point
      // by the same amount and the shape survives.
      inset: true,
      includeZero: false,
      headroom: valueLabels == NebaChartValueLabels.none ? 0 : chartValueLabelHeadroom,
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
      density: density,
      elevation: elevation,
      padded: padded,
      transition: transition,
      trace: (NebaChartLayout layout) => chartTraceLines(
        layout,
        curve: curve,
        filled: false,
        stacked: stacked,
        connectNulls: nulls == NebaChartNulls.connect,
        valueLabels: valueLabels,
      ),
      traceKey: (curve, stacked, nulls, valueLabels),
      painter: (NebaChartMarks<NebaLineTrace> marks) => NebaLinePainter(
        marks: marks,
        filled: false,
        stacked: stacked,
        markers: markers,
        gradient: gradient,
      ),
    );
  }
}
