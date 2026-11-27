/// `NebaAreaChart`, a line with the space under it filled.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/chart_line.dart';
import 'package:neba/src/types.dart';

/// A line with the space under it filled, which changes what the chart is
/// about.
///
/// A line says where a value went; an area says how much of something there
/// was, and stacked it says what that amount was made of. If the quantity does
/// not add up to anything, a temperature or a rate, the fill is decoration and
/// a [NebaLineChart] is the chart to reach for.
///
/// Unstacked bands are a wash fading out downward, so two of them overlapping
/// stay readable. Stacked bands are a flat tint separated by the surface,
/// because there the fill is the mark.
///
/// ```dart
/// const NebaAreaChart(
///   label: 'Storage used by tier',
///   categories: <Object>['Jan', 'Feb', 'Mar'],
///   stacked: NebaChartStacking.on,
///   series: <NebaChartSeries>[
///     NebaChartSeries(name: 'Hot', data: <num>[120, 138, 149]),
///     NebaChartSeries(name: 'Archive', data: <num>[610, 648, 690]),
///   ],
/// )
/// ```
class NebaAreaChart extends StatelessWidget {
  /// An area chart of [series].
  const NebaAreaChart({
    required this.series,
    this.categories,
    this.xAxis,
    this.yAxis,
    this.secondaryAxis,
    this.references,
    this.curve = NebaChartCurve.linear,
    this.stacked = NebaChartStacking.off,
    this.markers = NebaChartMarkers.none,
    this.valueLabels = NebaChartValueLabels.none,
    this.nulls = NebaChartNulls.gap,
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

  /// The value axis. It keeps zero in its range: a band's thickness is its
  /// magnitude. Stacked to [NebaChartStacking.full], it runs from 0 to 100
  /// and writes a percentage unless it says otherwise.
  final NebaChartAxis? yAxis;

  /// A second value axis on the far edge. Not read on a stacked chart.
  final NebaChartAxis? secondaryAxis;

  /// Lines and bands drawn across the plot at values the data has none of.
  final List<NebaChartReference>? references;

  /// How the edge of a band gets from one point to the next.
  final NebaChartCurve curve;

  /// How the bands stack: overlaid, each on the total of the ones below, or
  /// every category normalised to a hundred.
  final NebaChartStacking stacked;

  /// Dots on the points. None by default: a filled band already has a visible
  /// edge.
  final NebaChartMarkers markers;

  /// Which values are written on the bands.
  final NebaChartValueLabels valueLabels;

  /// What a band does where a value is missing. On a stacked chart a band
  /// that breaks takes the bands above it with it, so [NebaChartNulls.zero]
  /// is usually the one to pass there.
  final NebaChartNulls nulls;

  /// How tall the drawing is, the axis labels inside it. The size ladder
  /// when left out.
  final double? height;

  /// How a number is written everywhere it appears. Stacked to full, the
  /// tooltip and the table write the caller's own numbers through it.
  final String Function(num value)? format;

  /// The language of the chart's own words.
  final Locale? locale;

  /// What the chart is of: its name for a screen reader, and the caption of
  /// its table.
  final String? label;

  /// `true`, `false` or a [NebaChartLegend].
  final Object? legend;

  /// `true`, `false` or a [NebaChartTooltip].
  final Object? tooltip;

  /// What is drawn when there is nothing to draw.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text].
  final NebaVariant? variant;

  /// The type, the line weight, the markers and the height.
  final NebaSize? size;

  /// The family of the sheet and the focus ring.
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
    final bool full = stacked == NebaChartStacking.full;
    final bool stacks = stacked != NebaChartStacking.off;
    final NebaChartAxis? given = yAxis;
    // A share of a hundred, unless the caller said otherwise about any of it.
    final NebaChartAxis? valueAxis = full
        ? NebaChartAxis(
            hidden: given?.hidden ?? false,
            label: given?.label,
            grid: given?.grid,
            min: given?.min ?? 0,
            max: given?.max ?? 100,
            tickCount: given?.tickCount,
            tickFormat: given?.tickFormat ?? _percent,
            tickAngle: given?.tickAngle ?? 0,
            thickness: given?.thickness,
          )
        : given;

    return NebaCartesianChart<NebaLineTrace>(
      series: series,
      categories: categories,
      xAxis: xAxis,
      yAxis: valueAxis,
      secondaryAxis: secondaryAxis,
      references: references,
      stacked: stacks,
      // A hundred per cent is worked out by the frame, which knows which
      // series the legend has hidden and so which ones it is shared between.
      stackedFull: full,
      zeroGaps: nulls == NebaChartNulls.zero,
      inset: true,
      // Unlike a line, a band's fill is its magnitude, so the baseline stays
      // at zero.
      includeZero: true,
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
        filled: true,
        stacked: stacks,
        connectNulls: nulls == NebaChartNulls.connect,
        valueLabels: valueLabels,
      ),
      traceKey: (curve, stacks, nulls, valueLabels),
      painter: (NebaChartMarks<NebaLineTrace> marks) => NebaLinePainter(
        marks: marks,
        filled: true,
        stacked: stacks,
        markers: markers,
        gradient: false,
      ),
    );
  }
}

String _percent(Object value, int index) => '$value%';
