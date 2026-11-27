/// The marks a line chart and an area chart draw: the React package's
/// `src/internal/chart-line.tsx`.
///
/// They are one picture with one part switched off: an area is a line with
/// the space under it filled, and a stacked area is that with each band on the
/// one below. Tracing the paths twice would mean a `smooth` curve that bends
/// differently depending on which of the two widgets a caller reached for.
///
/// A sparkline does not come through here. It has no axes, no legend and no
/// stacking, and what it needs from `chart.dart` is two calls.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/rendering.dart';

import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/types.dart';

/// Past this many points a dot per point is a row of dots, not a series.
const int chartAutoMarkerLimit = 14;

/// One series, laid out: where its points are, and the paths it draws.
class NebaLineSeriesTrace {
  /// The trace of one series.
  NebaLineSeriesTrace({
    required this.tops,
    required this.area,
    required this.gap,
    required this.line,
    required this.labels,
  });

  /// Where each point is, `null` at a gap. The `null` is what breaks the
  /// path: a filtered list would join the two sides of a missing month.
  final List<Offset?> tops;

  /// The band under the line, on an area.
  final Path? area;

  /// The two pixels of surface between a stacked band and the one under it,
  /// drawn along the band's lower edge.
  final Path? gap;

  /// The line itself. A stacked band has none: its fill is its mark.
  final Path? line;

  /// The values written on the line.
  final List<NebaChartLabel> labels;
}

/// Every series of a line or an area chart, laid out once per layout.
///
/// The pointer moving from one column to the next changes which marker grows
/// and nothing else, so nothing here is traced again for it.
class NebaLineTrace implements NebaChartDisposable {
  /// The traces of every series, `null` for one that is hidden.
  NebaLineTrace(this.series);

  /// One trace per series, by its place in the list it was passed in.
  final List<NebaLineSeriesTrace?> series;

  @override
  void dispose() {
    for (final NebaLineSeriesTrace? one in series) {
      disposeChartLabels(one?.labels ?? const <NebaChartLabel>[]);
    }
  }
}

/// Traces every shown series of [layout].
///
/// [filled] fills under each line, [stacked] sets each series on the total of
/// the ones before it, and [connectNulls] bridges a gap rather than breaking
/// at it, by leaving the gaps out of the path rather than drawing over them,
/// so a bridged segment and a real one are the same shape.
NebaLineTrace chartTraceLines(
  NebaChartLayout layout, {
  required NebaChartCurve curve,
  required bool filled,
  required bool stacked,
  required bool connectNulls,
  required NebaChartValueLabels valueLabels,
}) {
  final List<List<NebaChartValue>> values = layout.values;
  final List<bool> visible = layout.visible;
  final int first = visible.indexOf(true);
  final double radius = chartMarkerRadii[layout.size]!;

  // The running totals each band sits on, one per sign: a positive value
  // stacks up from the zero line and a negative one down from it. Only the
  // shown series add to them, so hiding one closes the gap it left.
  final List<List<double>> baselines = <List<double>>[];
  final List<double> above = <double>[];
  final List<double> below = <double>[];

  double slot(List<double> totals, int category) {
    return category < totals.length ? totals[category] : 0;
  }

  void add(List<double> totals, int category, double amount) {
    while (totals.length <= category) {
      totals.add(0);
    }

    totals[category] += amount;
  }

  for (int index = 0; index < values.length; index++) {
    final List<NebaChartValue> one = values[index];

    baselines.add(<double>[
      for (int category = 0; category < one.length; category++)
        (one[category].value ?? 0) < 0 ? slot(below, category) : slot(above, category),
    ]);

    if (!stacked || !visible[index]) {
      continue;
    }

    for (int category = 0; category < one.length; category++) {
      final double amount = one[category].value ?? 0;

      add(amount < 0 ? below : above, category, amount);
    }
  }

  List<Offset?> bridged(List<Offset?> vertices) {
    return connectNulls ? <Offset?>[for (final Offset? vertex in vertices) ?vertex] : vertices;
  }

  final List<NebaLineSeriesTrace?> series = <NebaLineSeriesTrace?>[];

  for (int index = 0; index < values.length; index++) {
    if (!visible[index]) {
      series.add(null);
      continue;
    }

    final List<NebaChartValue> one = values[index];
    final List<Offset?> tops = <Offset?>[
      for (int category = 0; category < one.length; category++)
        if (one[category].value case final double value)
          layout.point(category, stacked ? baselines[index][category] + value : value, index)
        else
          null,
    ];
    final double base = layout.zeroPxOf(index);
    final List<Offset?> under = <Offset?>[
      for (int category = 0; category < one.length; category++)
        if (one[category].value case final double value)
          stacked
              ? layout.point(category, baselines[index][category], index)
              : Offset(layout.point(category, value, index).dx, base)
        else
          null,
    ];
    final List<Offset?> line = bridged(tops);
    final List<Offset?> floor = bridged(under);
    // A stacked band's fill is its mark, so it has no line along its top:
    // what separates it from the band above is the gap below that one.
    final bool banded = filled && stacked;
    final bool Function(int index) labelled = chartLabelledPoints(one, valueLabels);
    final String Function(double value) write = layout.formatFor(index);
    final List<NebaChartLabel> labels = <NebaChartLabel>[];

    for (int category = 0; category < one.length; category++) {
      final Offset? vertex = tops[category];
      final double? value = one[category].value;

      if (vertex == null || value == null || !labelled(category)) {
        continue;
      }

      final Color ink = chartLabelInk(
        chartResolveColor(one[category].color, layout.tokens) ?? layout.colors[index],
        layout.tokens,
      );

      labels.add(
        NebaChartLabel(
          chartTextPainter(
            one[category].label ?? write(value),
            layout.textStyle.copyWith(color: ink, fontWeight: FontWeight.w500),
            layout.textDirection,
          ),
          Offset(vertex.dx, vertex.dy - radius - 5),
          anchor: vertex.dx > layout.plot.right - 24
              ? -1
              : vertex.dx < layout.plot.left + 24
              ? 1
              : 0,
        ),
      );
    }

    series.add(
      NebaLineSeriesTrace(
        tops: tops,
        area: filled ? chartAreaPath(line, curve, floor: floor) : null,
        // Drawn on the lower edge so the top of the stack keeps its
        // silhouette, and skipped on the first band, whose lower edge is the
        // axis.
        gap: banded && index != first ? chartLinePath(floor, curve) : null,
        line: banded ? null : chartLinePath(line, curve),
        labels: labels,
      ),
    );
  }

  return NebaLineTrace(series);
}

/// Paints a [NebaLineTrace]: each shown series' band, its line, its markers
/// and its value labels, faded and grown by the chart's emphasis.
class NebaLinePainter extends CustomPainter {
  /// The painter of [marks].
  NebaLinePainter({
    required this.marks,
    required this.filled,
    required this.stacked,
    required this.markers,
    required this.gradient,
  }) : super(repaint: marks.emphasis);

  /// The layout, the trace and the pointer.
  final NebaChartMarks<NebaLineTrace> marks;

  /// Whether each band is filled.
  final bool filled;

  /// Whether the bands are stacked, which fills them flat.
  final bool stacked;

  /// Which points get a dot.
  final NebaChartMarkers markers;

  /// Whether each line fades from a paler step of its hue to the full one.
  final bool gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final NebaChartLayout layout = marks.layout;
    final List<NebaLineSeriesTrace?> traces = marks.traced.series;
    final double stroke = chartLineWidths[layout.size]!;
    final double radius = chartMarkerRadii[layout.size]!;
    final Color gapColor = layout.tokens.chartGap;
    final int? active = marks.activeIndex;

    for (int index = 0; index < traces.length; index++) {
      final NebaLineSeriesTrace? trace = traces[index];

      if (trace == null) {
        continue;
      }

      final Color color = layout.colors[index];
      final double opacity = marks.emphasis.opacityOf(index);
      final bool faded = opacity < 1;

      if (faded) {
        canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
      }

      if (trace.area case final Path area) {
        final Paint fill = Paint()..style = PaintingStyle.fill;

        if (stacked) {
          fill.color = mixOklab(color, 0.70, transparent);
        } else {
          // A wash and not a block, fading out downward across the band's
          // own box, so two of them overlapping stay readable.
          final Rect bounds = area.getBounds();

          fill.shader = chartGradient(bounds.topCenter, bounds.bottomCenter, <Color>[
            mixOklab(color, 0.28, transparent),
            mixOklab(color, 0.02, transparent),
          ]);
        }

        canvas.drawPath(area, fill);
      }

      if (trace.gap case final Path gap) {
        canvas.drawPath(
          gap,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = chartMarkGap
            ..color = gapColor,
        );
      }

      if (trace.line case final Path line) {
        final Paint paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color;

        if (gradient) {
          // Across the plot rather than the line's own box: a flat series has
          // a box with no height.
          paint.shader = chartGradient(
            Offset(layout.plot.left, 0),
            Offset(layout.plot.right, 0),
            <Color>[mixOklab(color, 0.45, transparent), color],
          );
        }

        canvas.drawPath(line, paint);
      }

      final List<NebaChartValue> values = layout.values[index];
      final bool every =
          markers == NebaChartMarkers.all ||
          (markers == NebaChartMarkers.auto && values.length <= chartAutoMarkerLimit);

      void dot(int category, double r) {
        final Offset? vertex = category < trace.tops.length ? trace.tops[category] : null;

        if (vertex == null) {
          return;
        }

        final Color fill = chartResolveColor(values[category].color, layout.tokens) ?? color;

        // The ring is the surface showing through, which keeps a marker
        // legible where two lines cross.
        canvas
          ..drawCircle(vertex, r, Paint()..color = fill)
          ..drawCircle(
            vertex,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = chartMarkGap
              ..color = gapColor,
          );
      }

      if (every) {
        for (int category = 0; category < trace.tops.length; category++) {
          dot(category, radius + marks.emphasis.growthOf(category));
        }
      } else if (active != null) {
        // The point under the pointer always gets one: that is what says
        // which column the tooltip is about.
        dot(active, radius + 1);
      }

      for (final NebaChartLabel label in trace.labels) {
        label.paint(canvas);
      }

      if (faded) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(NebaLinePainter oldDelegate) {
    return !identical(oldDelegate.marks.traced, marks.traced) ||
        !identical(oldDelegate.marks.layout, marks.layout) ||
        oldDelegate.marks.activeIndex != marks.activeIndex ||
        !identical(oldDelegate.marks.emphasis, marks.emphasis) ||
        oldDelegate.filled != filled ||
        oldDelegate.stacked != stacked ||
        oldDelegate.markers != markers ||
        oldDelegate.gradient != gradient;
  }
}

/// The widest a value label may hang over the plot's top, which the frame
/// reserves as headroom when the line carries labels.
const double chartValueLabelHeadroom = 10;
