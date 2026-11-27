/// `NebaSparkline`, a word-sized picture of a trend.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/components/visually_hidden/neba_visually_hidden.dart';
import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/color.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which mark a [NebaSparkline] draws.
enum NebaSparklineShape {
  /// A line, for a trend.
  line,

  /// A line with the space under it washed in, for a quantity.
  area,

  /// A bar per value, for a count of discrete things.
  bar,
}

/// A chart with everything taken away except the shape: no axes, no grid, no
/// legend and no tooltip.
///
/// It goes beside a number, inside a sentence or in a table cell, and says
/// which way something has been going. It scales itself to its own range, so
/// the strip is always full, and that is also the trap: two sparklines side by
/// side are on two different scales unless they are given the same [min] and
/// [max].
///
/// ```dart
/// const NebaSparkline(data: <num>[18, 22, 19, 27, 24, 31], label: 'Signups', endDot: true)
/// ```
class NebaSparkline extends StatelessWidget {
  /// A strip of [data].
  const NebaSparkline({
    required this.data,
    this.shape = NebaSparklineShape.line,
    this.curve = NebaChartCurve.linear,
    this.nulls = NebaChartNulls.gap,
    this.size,
    this.color,
    this.endDot = false,
    this.baseline,
    this.min,
    this.max,
    this.width,
    this.label,
    super.key,
  }) : assert(color == null || color is NebaColor || color is Color);

  /// The values: each a [num], `null` for a gap, or a [NebaChartPoint].
  final List<Object?> data;

  /// Which mark.
  final NebaSparklineShape shape;

  /// How the line gets from one point to the next.
  final NebaChartCurve curve;

  /// What the strip does where a value is missing. It matters more here than
  /// on a full chart: there is no tooltip and no axis to notice the hole with.
  final NebaChartNulls nulls;

  /// How tall the strip is, on a ladder measured against the line of text it
  /// sits beside. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The mark's colour: a [NebaColor] family or a [Color]. The first chart
  /// slot when left out.
  final Object? color;

  /// Puts a dot on the last point: the one direct label a strip this small has
  /// room for.
  final bool endDot;

  /// Draws a rule across the strip at this value: a target, a budget.
  final double? baseline;

  /// The bottom of the scale. The strip's own lowest value when left out.
  final double? min;

  /// The top of the scale. The strip's own highest value when left out.
  final double? max;

  /// How wide the strip is. It fills its parent's width when left out.
  final double? width;

  /// A name for the strip. With one it is read as an image of that name and
  /// its values are read after it; without one it is hidden from a screen
  /// reader entirely.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = this.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    // `zero` is done to the values rather than to the points, so the range
    // the strip scales itself to and the numbers a screen reader is given
    // agree with the picture.
    final List<NebaChartValue> values = <NebaChartValue>[
      for (final Object? datum in data)
        switch (chartValueOf(datum)) {
          final NebaChartValue value when value.value == null && nulls == NebaChartNulls.zero =>
            value.withValue(0),
          final NebaChartValue value => value,
        },
    ];
    final double height = sparklineHeights[size]!;
    final Widget drawing = NebaChartBox(
      height: height,
      width: width,
      fallbackWidth: 120,
      builder: (BuildContext context, double width) {
        return CustomPaint(
          size: Size(width, height),
          painter: _SparklinePainter(
            values: values,
            shape: shape,
            curve: curve,
            connect: nulls == NebaChartNulls.connect,
            stroke: chartLineWidths[size]!,
            radius: chartMarkerRadii[size]!,
            barMax: chartBarMaxThickness[size]! / 2,
            fill: chartResolveColor(color, tokens) ?? tokens.chart.series.first,
            endDot: endDot,
            baseline: baseline,
            min: min,
            max: max,
            tokens: tokens,
          ),
        );
      },
    );
    final String? label = this.label;
    // A width of its own is kept inside a parent that would stretch it, as a
    // block with a width keeps it inside a stretched cell.
    final Widget strip = width == null
        ? drawing
        : Align(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 1,
            heightFactor: 1,
            child: drawing,
          );

    if (label == null) {
      return ExcludeSemantics(child: strip);
    }

    // The numbers, for the readers the strip does not reach: a sibling of the
    // picture rather than inside it, which is read as one image.
    final String numbers = values
        .map((NebaChartValue one) {
          final double? value = one.value;

          return value == null ? '—' : chartNumber(value).toString();
        })
        .join(', ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          container: true,
          image: true,
          label: label,
          child: ExcludeSemantics(child: strip),
        ),
        NebaVisuallyHidden(child: Text(numbers)),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.values,
    required this.shape,
    required this.curve,
    required this.connect,
    required this.stroke,
    required this.radius,
    required this.barMax,
    required this.fill,
    required this.endDot,
    required this.baseline,
    required this.min,
    required this.max,
    required this.tokens,
  });

  final List<NebaChartValue> values;
  final NebaSparklineShape shape;
  final NebaChartCurve curve;
  final bool connect;
  final double stroke;
  final double radius;
  final double barMax;
  final Color fill;
  final bool endDot;
  final double? baseline;
  final double? min;
  final double? max;
  final NebaTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    if (width <= 0 || values.isEmpty) {
      return;
    }

    final bool bars = shape == NebaSparklineShape.bar;
    final ({double min, double max})? extent = chartExtentOf(<List<NebaChartValue>>[
      values,
    ], stacked: false);
    final double? baseline = this.baseline;
    // A bar grows from zero, so zero is inside the range: without it an
    // all-negative strip hung its bars from above the box, and equal values
    // drew one-pixel bars that read as zero.
    final double low =
        min ??
        (extent == null
            ? 0
            : <double>[extent.min, baseline ?? extent.min, if (bars) 0].reduce(math.min));
    final double high =
        max ??
        (extent == null
            ? 1
            : <double>[extent.max, baseline ?? extent.max, if (bars) 0].reduce(math.max));
    final double span = high - low == 0 ? 1 : high - low;
    // A line with nothing to rise or fall between sits in the middle of the
    // strip rather than on its floor, where it read as a drop to the bottom.
    final bool level = high == low && !bars;
    final double zero = math.min(math.max(low, 0), high);
    // The stroke straddles the path, so the band it is drawn in comes in by
    // half of it at both ends, or the highest and lowest points are shaved off
    // by the edge of the box.
    final double inset = bars ? 0 : stroke / 2 + (endDot ? radius : 0);
    final double usable = math.max(1, height - inset * 2);

    double y(double value) {
      return level ? inset + usable / 2 : inset + (1 - (value - low) / span) * usable;
    }

    final double step = values.length > 1 ? width / (values.length - 1) : width;
    final List<Offset?> points = <Offset?>[
      for (int index = 0; index < values.length; index++)
        if (values[index].value case final double value) Offset(index * step, y(value)) else null,
    ];
    final List<Offset?> drawn = connect
        ? <Offset?>[for (final Offset? point in points) ?point]
        : points;

    if (shape == NebaSparklineShape.area) {
      final Path area = chartAreaPath(drawn, curve, baseline: height);
      final Rect bounds = area.getBounds();

      canvas.drawPath(
        area,
        Paint()
          ..shader = chartGradient(bounds.topCenter, bounds.bottomCenter, <Color>[
            mixOklab(fill, 0.32, transparent),
            mixOklab(fill, 0.02, transparent),
          ]),
      );
    }

    if (baseline != null) {
      chartPaintRule(
        canvas,
        Offset(0, y(baseline)),
        Offset(width, y(baseline)),
        tokens.chartBaseline,
      );
    }

    if (bars) {
      final double slot = width / math.max(1, values.length);
      final double barWidth = math.min(barMax, math.max(1, slot - chartMarkGap));

      for (int index = 0; index < values.length; index++) {
        final double? value = values[index].value;

        if (value == null) {
          continue;
        }

        final Rect rect = Rect.fromLTWH(
          index * slot + (slot - barWidth) / 2,
          math.min(y(value), y(zero)),
          barWidth,
          math.max(1, (y(value) - y(zero)).abs()),
        );

        canvas.drawPath(
          chartBarPath(
            rect,
            chartBarRadius / 2,
            value >= 0 ? NebaChartBarEnd.up : NebaChartBarEnd.down,
          ),
          Paint()..color = chartResolveColor(values[index].color, tokens) ?? fill,
        );
      }
    } else {
      canvas.drawPath(
        chartLinePath(drawn, curve),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = fill,
      );
    }

    final Offset? last = points.lastWhere((Offset? point) => point != null, orElse: () => null);

    if (endDot && !bars && last != null) {
      canvas
        ..drawCircle(last, radius, Paint()..color = fill)
        ..drawCircle(
          last,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = chartMarkGap
            ..color = tokens.chartGap,
        );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return !identical(oldDelegate.values, values) ||
        oldDelegate.shape != shape ||
        oldDelegate.curve != curve ||
        oldDelegate.connect != connect ||
        oldDelegate.stroke != stroke ||
        oldDelegate.radius != radius ||
        oldDelegate.barMax != barMax ||
        oldDelegate.fill != fill ||
        oldDelegate.endDot != endDot ||
        oldDelegate.baseline != baseline ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.tokens != tokens;
  }
}
