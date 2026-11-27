/// `NebaGaugeChart`, one number on a scale known in advance, drawn as a dial.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/chart.dart';
import 'package:neba/src/internal/chart_frame.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// One number on a scale that is known in advance, drawn as a dial.
///
/// It is a `NebaMeter` bent into an arc, and the two are deliberately the
/// same component in two shapes: [value], [min], [max] and [thresholds] mean
/// what they mean there, so a page can move a reading from a bar to a dial
/// without changing what it says. Reach for the bar in a row of fields and for
/// this in a tile of its own, where a dial reads from across a room.
///
/// It is not a `NebaPieChart` with `NebaPieShape.semi`: a pie is parts of a
/// whole, and the unfilled part of this arc is not a second category but the
/// rest of the dial.
///
/// ```dart
/// const NebaGaugeChart(label: 'Memory', caption: Text('Memory'), value: 82)
/// ```
class NebaGaugeChart extends StatelessWidget {
  /// A dial reading [value].
  const NebaGaugeChart({
    required this.value,
    this.min = 0,
    this.max = 100,
    this.sweep = 180,
    this.thickness = 0.22,
    this.thresholds,
    this.ticks,
    this.showRange = true,
    this.center,
    this.caption,
    this.height,
    this.format,
    this.locale,
    this.label,
    this.empty,
    this.variant,
    this.size,
    this.color = NebaColor.primary,
    this.density,
    this.elevation = 0,
    this.padded = false,
    this.transition,
    super.key,
  });

  /// The reading. `null` draws the dial with nothing on it and a dash in the
  /// middle, the honest picture of an instrument that has not been told
  /// anything.
  final double? value;

  /// The bottom of the scale.
  final double min;

  /// The top of the scale.
  final double max;

  /// How far round the dial goes, in degrees, opened symmetrically about
  /// twelve o'clock: `180` is the half dial a dashboard tile wants, `270` the
  /// instrument shape, `360` a ring.
  final double sweep;

  /// How thick the arc is, as a fraction of its radius.
  final double thickness;

  /// Where the arc changes colour: the last one the reading has reached wins,
  /// and below all of them [color] stands, as on a `NebaMeter`.
  final List<NebaThreshold>? thresholds;

  /// How many marks are drawn around the dial, ends included. None when left
  /// out: a gauge on a dashboard is read as a proportion, and ticks are for an
  /// instrument somebody takes a number off.
  final int? ticks;

  /// Writes [min] and [max] at the two ends of the arc.
  final bool showRange;

  /// What goes in the middle instead of the reading written through
  /// [format]. A [Text] is sized to the room in the dial, as the reading is.
  final Widget? center;

  /// A line under the reading: the unit, or what is being measured. A [Text]
  /// is also read out after the reading.
  final Widget? caption;

  /// How tall the drawing is. The size ladder when left out: 120, 160, 220,
  /// 280 and 360 logical pixels.
  final double? height;

  /// How the reading and the two ends of the scale are written. Without it,
  /// past ten thousand a number is compacted (`12.4K`).
  final String Function(num value)? format;

  /// The language of the chart's own words. Defaults to `NebaProvider`'s, then
  /// the app's.
  final Locale? locale;

  /// What the dial measures, for a screen reader. Given one, the dial is one
  /// node of that name whose value is the reading; without one, the reading in
  /// the middle is read as the text it is.
  final String? label;

  /// What is drawn when the scale has no range.
  final Widget? empty;

  /// The sheet's weight. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.text]: a chart is a drawing, not a sheet.
  final NebaVariant? variant;

  /// The type and the height. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family the arc and the sheet carry before any threshold is reached.
  final NebaColor color;

  /// How much padding the sheet has.
  final NebaDensity? density;

  /// The drop shadow, from `0` to `3`.
  final NebaElevation elevation;

  /// Whether the sheet pads the dial.
  final bool padded;

  /// How the dial arrives when it is first built.
  final NebaTransition? transition;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaDefaults defaults = NebaTheme.defaultsOf(context);
    final NebaSize size = this.size ?? defaults.size ?? NebaSize.md;
    final NebaVariant variant = this.variant ?? defaults.variant ?? NebaVariant.text;
    final String Function(num value)? own = format;
    final String Function(double value) write = own == null
        ? nebaFormatCompact
        : (double value) => own(chartNumber(value));
    final double? value = this.value;
    final double range = max - min;
    final double? fraction = value == null || value.isNaN || range == 0
        ? null
        : ((value - min) / range).clamp(0, 1).toDouble();
    final NebaColor family = value == null ? color : thresholdColor(value, color, thresholds);
    final double plotHeight = height ?? chartPlotHeights[size]!;
    final double fontSize = MediaQuery.textScalerOf(context).scale(chartFontSizes[size]!);
    final Widget? center = this.center;
    final Widget? caption = this.caption;
    // What the middle says, when it is words: the reading, or a `Text` given
    // in its place.
    final String? reading = center == null
        ? (value == null ? '—' : write(value))
        : center is Text
        ? center.data
        : null;

    final Widget dial = NebaChartBox(
      height: plotHeight,
      builder: (BuildContext context, double width) {
        final _Dial dial = _Dial.of(
          width: width,
          height: plotHeight,
          fontSize: fontSize,
          sweep: sweep,
          thickness: thickness,
          ticks: ticks,
          range: showRange
              ? <String>[
                  for (final double end in <double>[min, max])
                    chartTruncate(write(end), math.max(0, width * 0.28), fontSize),
                ]
              : const <String>[],
          caption: caption != null,
          reading: reading,
        );

        if (range == 0 || dial.outer <= 0) {
          return NebaChartEmpty(empty: empty, size: size, locale: locale);
        }

        final TextStyle labelStyle = DefaultTextStyle.of(context).style.copyWith(
          fontSize: fontSize,
          color: tokens.mutedFg,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          height: 1.2,
        );
        final TextDirection direction = Directionality.of(context);
        final List<NebaChartLabel> ends = <NebaChartLabel>[
          for (final (int index, String text) in dial.range.indexed)
            NebaChartLabel(
              chartTextPainter(text, labelStyle, direction),
              dial.rangeAt(index),
              anchor: dial.labelUnder ? 0 : (index == 0 ? -1 : 1),
            ),
        ];

        // A changed reading travels along the arc over the fill's duration,
        // by how much of the stroke is drawn, and a threshold crossed on the
        // way changes its colour over the shorter one, as a meter's does.
        final Widget arc = TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: tokens.roles(family).fill),
          duration: nebaDuration(context, NebaScale.duration),
          curve: NebaScale.ease,
          builder: (BuildContext context, Color? fill, Widget? _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: fraction ?? 0),
              duration: nebaDuration(context, NebaScale.durationFill),
              curve: NebaScale.ease,
              builder: (BuildContext context, double drawn, Widget? _) {
                return CustomPaint(
                  size: Size(width, plotHeight),
                  painter: _GaugePainter(
                    dial: dial,
                    track: tokens.roles(color).soft,
                    fill: fill ?? tokens.roles(family).fill,
                    fraction: fraction == null ? null : drawn,
                    grid: tokens.chartGrid,
                    ends: ends,
                  ),
                );
              },
            );
          },
        );

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            arc,
            // Real text rather than paint: this is the one number the chart
            // is about. Held to the chord it sits on, so a center of the
            // caller's own is wrapped by the dial rather than laid across the
            // tile beside it, and placed so the reading, not the middle of the
            // reading and its caption, lands on the line it is meant for.
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: _ReadingLayout(middle: dial.blockMiddle, room: dial.room),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: dial.readingSize,
                        fontWeight: FontWeight.w600,
                        color: tokens.fg,
                        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                      child: center ?? Text(reading ?? ''),
                    ),
                    if (caption != null)
                      DefaultTextStyle.merge(
                        style: TextStyle(color: tokens.mutedFg, fontSize: NebaScale.metaText[size]),
                        textAlign: TextAlign.center,
                        child: caption,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    return NebaChartSurface(
      plot: _semantics(dial, write, reading),
      plotHeight: plotHeight,
      legendSide: NebaSide.bottom,
      legendAlign: NebaAlign.center,
      variant: variant,
      size: size,
      color: color,
      density: density,
      elevation: elevation,
      padded: padded,
      transition: transition,
    );
  }

  /// Named, the dial is a meter: one node whose value is the reading and the
  /// caption, as a `NebaMeter`'s is. With no reading there is no value to
  /// give, and it is a named picture of nothing. Unnamed it is a plain box,
  /// and the reading in the middle is read as the text it is.
  Widget _semantics(Widget dial, String Function(double value) write, String? reading) {
    final String? label = this.label;
    final double? value = this.value;
    final Widget? caption = this.caption;

    if (label == null) {
      return dial;
    }

    if (value == null || value.isNaN || max == min) {
      return Semantics(
        container: true,
        image: true,
        label: label,
        child: ExcludeSemantics(child: dial),
      );
    }

    return Semantics(
      container: true,
      label: label,
      value: <String>[
        reading ?? write(value),
        if (caption is Text) ?caption.data,
      ].where((String text) => text.isNotEmpty).join(' '),
      child: ExcludeSemantics(child: dial),
    );
  }
}

/// The largest type size at which a line [units] ems long still sits inside a
/// circle of radius [r], given that its middle is [base] above the centre.
///
/// Two things have to fit, half the line's width sideways and how far its
/// digits climb above that middle, and both grow with the size being solved
/// for, so this is a quadratic rather than a division:
///
///     (units·size / 2·fill)² + (base + cap·size)² = r²
///
/// Solved rather than iterated, because iterating oscillates: a size that does
/// not fit shrinks, a shorter number climbs less, and the room that frees up
/// allows a size that does not fit.
double _fitType(double units, double base, double r, double cap, double fill) {
  final double a = units * units / (4 * fill * fill) + cap * cap;
  final double b = 2 * base * cap;
  final double c = base * base - r * r;

  if (a <= 0 || c >= 0) {
    return 0;
  }

  return (math.sqrt(b * b - 4 * a * c) - b) / (2 * a);
}

/// Where everything on the dial goes, worked out from the box.
class _Dial {
  _Dial({
    required this.from,
    required this.to,
    required this.centre,
    required this.outer,
    required this.inner,
    required this.tickCount,
    required this.fontSize,
    required this.range,
    required this.labelUnder,
    required this.labelReach,
    required this.labelDrop,
    required this.blockMiddle,
    required this.room,
    required this.readingSize,
  });

  factory _Dial.of({
    required double width,
    required double height,
    required double fontSize,
    required double sweep,
    required double thickness,
    required int? ticks,
    required List<String> range,
    required bool caption,
    required String? reading,
  }) {
    final double span = sweep.clamp(1, 360).toDouble();
    final double half = span / 2;
    final double band = thickness.clamp(0.05, 0.9).toDouble();

    // How much room the arc needs, as multiples of its own radius. The top is
    // always a full radius above the centre; how far it reaches below depends
    // on the sweep. Which way the two ends point is a third question, and it
    // is the direction the range labels are set along.
    final double halfRadians = half * math.pi / 180;
    final double belowFactor = span >= 360 ? 1 : math.max(0, -math.cos(halfRadians));
    final double sideFactor = span >= 180 ? 1 : math.sin(halfRadians);
    final double endOutX = math.sin(halfRadians);
    final double endOutY = -math.cos(halfRadians);

    // Past 330° the two ends have come within a label's width of each other,
    // and two numbers set on top of each other are not a scale.
    final List<String> ends = span < 330 ? range : const <String>[];
    final double labelWidth = ends.fold<double>(
      0,
      (double widest, String text) => math.max(widest, chartTextWidth(text, fontSize)),
    );

    // A range label goes with the end it names: centred under an end that
    // points sideways, carried on past one that already points down. Either
    // way from the arc's outer edge, clear of the band.
    final double edge = fontSize * 0.35;
    final double tickReach = ticks == null ? 0 : fontSize * 0.85;
    final bool labelUnder = endOutY <= 0.25;
    final double labelReach = labelUnder ? 0 : fontSize * 0.5;
    final double labelDrop = labelUnder ? fontSize : fontSize * (0.35 + endOutY * 0.55);
    final double labelBelow = ends.isNotEmpty
        ? endOutY * labelReach + labelDrop + fontSize * 0.25
        : 0;
    final double sidePad = math.max(edge, tickReach);
    final double topPad = math.max(edge, tickReach);
    final double bottomPad = math.max(math.max(edge, tickReach), labelBelow);

    // The radius, as the smallest of what each side of the box allows, the
    // labels hanging past the ends included.
    final List<double> limits = <double>[
      (width / 2 - sidePad) / math.max(0.05, sideFactor),
      (height - topPad - bottomPad) / (1 + belowFactor),
      if (labelWidth > 0 && endOutX > 0.05)
        math.max(0, width / 2 - edge - (labelUnder ? labelWidth / 2 : labelWidth)) / endOutX -
            labelReach,
    ];
    final double outer = math.max(0, limits.reduce(math.min));
    final double inner = outer * (1 - band);

    // Centred in the height the box has rather than pinned under the top.
    final double drawn = topPad + outer * (1 + belowFactor) + bottomPad;
    final Offset centre = Offset(width / 2, topPad + outer + math.max(0, (height - drawn) / 2));

    // The reading sits in the middle of the hole the arc leaves, which on a
    // half dial is half an inner radius up; a caption hangs off it rather
    // than sharing the middle with it.
    final double captionRoom = caption ? fontSize * 1.85 : 0;
    final double textY = centre.dy - inner * (1 - math.min(1, belowFactor)) / 2;
    final double readingRise = math.min(inner, (centre.dy - textY).abs());
    final double blockRise = math.min(inner, (centre.dy - textY - captionRoom / 2).abs());
    final double room = math.sqrt(math.max(0, inner * inner - blockRise * blockRise)) * 2;

    // Sized to the room it has: twice the tick type for a short number, the
    // tick type at least, and solved for in between. 0.42 of the size above
    // the middle is where a digit's top lands, and 0.86 of the chord is what
    // it may fill, both keeping a little back for an estimate of the width.
    final double units = reading == null ? 0 : chartTextWidth(reading, 1);
    final double readingSize = units > 0
        ? math.max(
            fontSize,
            math.min(fontSize * 2, _fitType(units, readingRise, inner, 0.42, 0.86)),
          )
        : fontSize * 2;

    return _Dial(
      from: -half,
      to: half,
      centre: centre,
      outer: outer,
      inner: inner,
      tickCount: ticks == null ? 0 : math.max(2, ticks),
      fontSize: fontSize,
      range: ends,
      labelUnder: labelUnder,
      labelReach: labelReach,
      labelDrop: labelDrop,
      blockMiddle: textY + captionRoom / 2,
      room: room,
      readingSize: readingSize,
    );
  }

  /// Where the arc starts and ends, in degrees clockwise from twelve o'clock.
  final double from;
  final double to;

  final Offset centre;
  final double outer;
  final double inner;
  final int tickCount;
  final double fontSize;

  /// The two ends of the scale, written and cut to fit, or none.
  final List<String> range;

  final bool labelUnder;
  final double labelReach;
  final double labelDrop;

  /// The height the middle of the reading and its caption sits at.
  final double blockMiddle;

  /// How wide the dial is on the row the reading straddles.
  final double room;

  /// The type size of the reading.
  final double readingSize;

  /// Where range label [index] is pinned by its baseline: `0` at the start of
  /// the arc, `1` at its end.
  Offset rangeAt(int index) {
    return chartPolar(centre, outer + labelReach, index == 0 ? from : to) + Offset(0, labelDrop);
  }
}

/// The groove, the reading stroked along it, the marks and the two ends of
/// the scale.
class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.dial,
    required this.track,
    required this.fill,
    required this.fraction,
    required this.grid,
    required this.ends,
  });

  final _Dial dial;
  final Color track;
  final Color fill;

  /// How much of the arc the reading has drawn, `null` for no reading.
  final double? fraction;
  final Color grid;
  final List<NebaChartLabel> ends;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = dial.centre;

    // The rest of the dial: not a second value, a groove.
    canvas.drawPath(
      chartArcPath(centre, dial.outer, dial.inner, dial.from, dial.to),
      Paint()..color = track,
    );

    // The reading, a stroke along the middle of the groove drawn as far as the
    // fraction: one line whose drawn length is a number, so a new reading
    // travels there rather than jumping, and never a transform, which would
    // resample the numbers written across the dial.
    final double? fraction = this.fraction;

    if (fraction != null && fraction > 0) {
      final Path ring = chartRingPath(centre, (dial.outer + dial.inner) / 2, dial.from, dial.to);
      final ui.PathMetric metric = ring.computeMetrics().first;

      canvas.drawPath(
        metric.extractPath(0, metric.length * fraction),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = dial.outer - dial.inner
          ..color = fill,
      );
    }

    final Paint mark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = grid;

    for (int index = 0; index < dial.tickCount; index++) {
      final double at = dial.from + (dial.to - dial.from) * index / (dial.tickCount - 1);

      canvas.drawLine(
        chartPolar(centre, dial.outer + dial.fontSize * 0.25, at),
        chartPolar(centre, dial.outer + dial.fontSize * 0.6, at),
        mark,
      );
    }

    for (final NebaChartLabel label in ends) {
      label.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return !identical(oldDelegate.dial, dial) ||
        oldDelegate.track != track ||
        oldDelegate.fill != fill ||
        oldDelegate.fraction != fraction ||
        oldDelegate.grid != grid ||
        !identical(oldDelegate.ends, ends);
  }
}

/// The reading and its caption, centred across the box with their middle at
/// [middle] and no wider than [room].
class _ReadingLayout extends SingleChildLayoutDelegate {
  const _ReadingLayout({required this.middle, required this.room});

  final double middle;
  final double room;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(maxWidth: math.max(0, math.min(room, constraints.maxWidth)));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset((size.width - childSize.width) / 2, middle - childSize.height / 2);
  }

  @override
  bool shouldRelayout(_ReadingLayout oldDelegate) {
    return oldDelegate.middle != middle || oldDelegate.room != room;
  }
}
