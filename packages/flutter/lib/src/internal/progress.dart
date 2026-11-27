/// What the progress widgets share: the React package's
/// `src/internal/progress.ts`.
///
/// `NebaProgressLinear`, `NebaProgressCircular` and `NebaProgressBox` are three
/// shapes answering one question, how far along is this and is it moving at
/// all, so what is not the shape is here: the size ladders, the arithmetic
/// that turns `value`, `min` and `max` into a fraction, the text a reading is
/// written as, the row a label and that text sit in, what a screen reader is
/// told, and the clock an indeterminate one moves on. A `value` of `null` has
/// to mean the same thing on a bar, a ring and a row of plates, or the three
/// are three widgets that happen to share a prefix.
///
/// `NebaMeter` reads them too, because it is the same groove with different
/// semantics: [NebaGroove] is that groove, which a `NebaSlider` cuts its track
/// in as well, and [thresholdColor] is here for a meter and for the gauge that
/// answers the same question about a reading.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Which family a reading has earned: that of the last of [thresholds] that
/// [value] has reached, or [color] below all of them.
///
/// Read in the order given rather than sorted, so a list written out of order
/// shows up as the wrong colour instead of being quietly repaired.
NebaColor thresholdColor(double value, NebaColor color, List<NebaThreshold>? thresholds) {
  NebaColor current = color;

  for (final NebaThreshold threshold in thresholds ?? const <NebaThreshold>[]) {
    if (value >= threshold.from) {
      current = threshold.color;
    }
  }

  return current;
}

/// How thick a bar's groove is, and a meter's: the weight of a rule between
/// two paragraphs at `md`, not a third of a button.
const Map<NebaSize, double> barThickness = <NebaSize, double>{
  NebaSize.xs: 2,
  NebaSize.sm: 3,
  NebaSize.md: 4,
  NebaSize.lg: 6,
  NebaSize.xl: 8,
};

/// A ring's diameter, just under the control ladder at every step: a ring in
/// a button, a field or a table row never makes the row taller.
const Map<NebaSize, double> ringDiameter = <NebaSize, double>{
  NebaSize.xs: 14,
  NebaSize.sm: 16,
  NebaSize.md: 20,
  NebaSize.lg: 26,
  NebaSize.xl: 32,
};

/// A ring's stroke, thickening with the ring so the hole stays in proportion.
const Map<NebaSize, double> ringStroke = <NebaSize, double>{
  NebaSize.xs: 1.5,
  NebaSize.sm: 1.75,
  NebaSize.md: 2,
  NebaSize.lg: 2.5,
  NebaSize.xl: 3,
};

/// One plate of a row of plates, on the tick ladder: an indicator, not a
/// control.
const Map<NebaSize, double> plateSize = <NebaSize, double>{
  NebaSize.xs: 8,
  NebaSize.sm: 10,
  NebaSize.md: 12,
  NebaSize.lg: 16,
  NebaSize.xl: 20,
};

/// The corner cut off a plate: the same 30% or so a tick box's is.
const Map<NebaSize, double> plateRadius = <NebaSize, double>{
  NebaSize.xs: 3,
  NebaSize.sm: 4,
  NebaSize.md: 4.5,
  NebaSize.lg: 6,
  NebaSize.xl: 7,
};

/// Between the plates. Tight, because they are one object and not a row of
/// squares.
const Map<NebaSize, double> plateGap = <NebaSize, double>{
  NebaSize.xs: 4,
  NebaSize.sm: 4,
  NebaSize.md: 6,
  NebaSize.lg: 6,
  NebaSize.xl: 8,
};

/// [value] as a fraction of [min] to [max], or `null` when there is nothing
/// to say.
///
/// `null` is the indeterminate case: no value, a value that is not a finite
/// number, or a range with nothing in it. An indicator that has not been told
/// how far along it is says so, rather than drawing an empty bar that reads
/// as no progress at all. The fraction is held to 0 and 1, because a value
/// usually comes out of a division somewhere, and a bar drawn 140% long
/// because one request finished twice is a worse bug than a full one.
double? progressFraction(double? value, double min, double max) {
  if (value == null || !value.isFinite || !(max > min)) {
    return null;
  }

  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

/// [value] held to [min] and [max]: the number a caller's `format` is handed,
/// never past either end of the range, and [min] for a value that is not a
/// number. Unlike [num.clamp], it does not throw on a range that runs
/// backwards; it answers [max], as the React package's clamp does.
double progressClamp(double value, double min, double max) {
  if (value.isNaN) {
    return min;
  }

  return math.min(math.max(value, min), max);
}

/// What a reading says, on screen and to a screen reader alike: the share of
/// the range as a whole percent, so step 3 of 4 is "75%" in every language,
/// or what [format] writes for the value held to the range, once a caller has
/// said what the number means. `null` without a [fraction].
String? progressText({
  required double? fraction,
  required double? value,
  required double min,
  required double max,
  String Function(double value)? format,
}) {
  if (fraction == null || value == null) {
    return null;
  }

  return format == null ? '${(fraction * 100).round()}%' : format(progressClamp(value, min, max));
}

/// What a screen reader is told about the indicator drawn by [child].
///
/// A reading is its [value], the text drawn beside the shape whether or not
/// it is shown, and an indicator with none is a busy one. It is named by the
/// label drawn inside [child], or by [semanticLabel] in its place.
///
/// The value is not handed to `SemanticsRole.progressBar`: on the oldest
/// Flutter the package supports, that role takes only a bare number, and a
/// reader would then hear "75" for 75% and nothing of a caller's own
/// `format`.
Widget progressSemantics({
  required String? value,
  required String? semanticLabel,
  required Widget child,
}) {
  return Semantics(
    container: true,
    role: value == null ? SemanticsRole.loadingSpinner : null,
    label: semanticLabel,
    value: value,
    excludeSemantics: semanticLabel != null,
    child: child,
  );
}

/// A label beside a progress shape: in the page's ink, on one line, cut short
/// with an ellipsis rather than wrapping.
Widget progressLabel(NebaTokens tokens, Widget label) {
  return DefaultTextStyle.merge(
    style: TextStyle(color: tokens.fg),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
    child: label,
  );
}

/// The reading beside a progress shape: muted, in figures of one width so it
/// does not jitter as it counts, and silent, because the indicator says it to
/// a screen reader as its value. Nothing at all while there is no [text].
Widget progressValue(NebaTokens tokens, String? text) {
  if (text == null) {
    return const SizedBox.shrink();
  }

  return ExcludeSemantics(
    child: Text(
      text,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        color: tokens.mutedFg,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    ),
  );
}

/// The row above a bar, a row of plates and a meter: the [label] at the
/// start and the reading at the end, or the reading alone at the end, on the
/// meta type scale of [size].
class NebaProgressCaption extends StatelessWidget {
  /// The [label] and, when [showValue], the reading [value].
  const NebaProgressCaption({
    required this.size,
    this.label,
    this.value,
    this.showValue = false,
    super.key,
  });

  /// The step whose meta type the row is set in.
  final NebaSize size;

  /// What is loading, or being measured.
  final Widget? label;

  /// The reading, as [progressText] writes it.
  final String? value;

  /// Whether the reading is drawn.
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Widget? label = this.label;

    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: NebaScale.metaText[size]),
      child: Row(
        mainAxisAlignment: label == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: 8,
        children: <Widget>[
          if (label != null) Flexible(child: progressLabel(tokens, label)),
          if (showValue) progressValue(tokens, value),
        ],
      ),
    );
  }
}

/// The time an indeterminate indicator has been moving, as the listenable
/// its painter repaints on.
///
/// Elapsed time rather than a repeating controller, because each part of a
/// motion has a period of its own and a row of plates holds each one back by
/// a delay, as a CSS animation does: [progressPhase] turns the time into a
/// point in a cycle while painting, so a reader who asks for less motion
/// lengthens the period without the clock starting over.
class NebaProgressClock extends ValueNotifier<Duration> {
  /// A stopped clock whose ticker [vsync] provides.
  NebaProgressClock(TickerProvider vsync) : super(Duration.zero) {
    _ticker = vsync.createTicker(_tick);
  }

  late final Ticker _ticker;

  void _tick(Duration elapsed) {
    value = elapsed;
  }

  /// Starts the clock from zero when [running] and it is stopped, and stops
  /// it when it is not.
  void run(bool running) {
    if (running == _ticker.isActive) {
      return;
    }

    if (running) {
      value = Duration.zero;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

/// Where a cycle [period] long stands at [elapsed], from 0 to 1, once
/// [delay] has passed, or `null` while it is still waiting, as a delayed CSS
/// animation leaves its element as it was until it starts.
double? progressPhase(Duration elapsed, Duration period, {Duration delay = Duration.zero}) {
  final int since = elapsed.inMicroseconds - delay.inMicroseconds;

  if (since < 0) {
    return null;
  }

  return (since % period.inMicroseconds) / period.inMicroseconds;
}

/// Which span between two of the keyframe [stops] the point [t] of a cycle
/// is in, and how far through that span it is once [curve], the house curve
/// unless it says, has eased it.
///
/// A CSS animation eases each span between two keyframes on its own rather
/// than the cycle as a whole, so a pulse that rises and falls eases twice.
({int span, double t}) progressKeyframe(
  double t,
  List<double> stops, {
  Curve curve = NebaScale.ease,
}) {
  assert(stops.length >= 2);

  int span = 0;

  while (span < stops.length - 2 && t >= stops[span + 1]) {
    span += 1;
  }

  final double width = stops[span + 1] - stops[span];
  final double local = width <= 0 ? 1 : ((t - stops[span]) / width).clamp(0.0, 1.0);

  return (span: span, t: curve.transform(local));
}

/// The groove a bar, a meter and a slider cut into the surface they sit on: a
/// rounded track in the family's wash, with the fill along it from the start,
/// or from [start] for a slider's range, or, while there is no reading, a
/// segment crossing it on [clock].
///
/// It takes the width it is given, and none where there is no limit, as a
/// bar a hundred per cent wide does; a [vertical] one takes the height it is
/// given and fills from the bottom. Nothing in it moves a box: the fill is
/// painted as long as the reading says, and the segment is painted further
/// along on each frame, so neither runs a layout. A reader who asked for less
/// motion sees the whole groove pulse between [rest] and [fill] instead,
/// because a bar that holds still says nothing is happening.
class NebaGroove extends StatelessWidget {
  /// A groove [thickness] tall, filled to [fraction], or crossing on [clock]
  /// while [fraction] is `null`.
  const NebaGroove({
    required this.thickness,
    required this.track,
    required this.fill,
    required this.rest,
    this.fraction,
    this.start = 0,
    this.vertical = false,
    this.clock,
    super.key,
  });

  /// How thick the groove is: its height, or its width when [vertical].
  final double thickness;

  /// The groove itself: the family's wash.
  final Color track;

  /// The fill, and the crossing segment.
  final Color fill;

  /// Where the pulse falls back to between beats, under reduced motion.
  final Color rest;

  /// How full, from 0 to 1, or `null` for a groove with no reading.
  final double? fraction;

  /// Where the fill begins, from 0 to 1: the low end of a slider's range, and
  /// the start of the groove for everything else.
  final double start;

  /// Whether the groove runs up the page, from the bottom, rather than along
  /// the line.
  final bool vertical;

  /// What the segment crosses on while there is no reading.
  final ValueListenable<Duration>? clock;

  /// One crossing of the segment.
  static const Duration sweep = Duration(milliseconds: 1150);

  /// One beat of the pulse that stands in for it under reduced motion.
  static const Duration pulse = Duration(milliseconds: 1800);

  /// The crossing segment's length, as a share of the groove.
  static const double segment = 0.45;

  @override
  Widget build(BuildContext context) {
    final Widget painted = CustomPaint(
      painter: _GroovePainter(
        track: track,
        fill: fill,
        rest: rest,
        fraction: fraction,
        start: start,
        vertical: vertical,
        clock: clock,
        reduced: nebaReducedMotion(context),
        rtl: Directionality.of(context) == TextDirection.rtl,
      ),
    );

    if (vertical) {
      return LimitedBox(
        maxHeight: 0,
        child: SizedBox(width: thickness, height: double.infinity, child: painted),
      );
    }

    return LimitedBox(
      maxWidth: 0,
      child: SizedBox(width: double.infinity, height: thickness, child: painted),
    );
  }
}

class _GroovePainter extends CustomPainter {
  _GroovePainter({
    required this.track,
    required this.fill,
    required this.rest,
    required this.fraction,
    required this.start,
    required this.vertical,
    required this.clock,
    required this.reduced,
    required this.rtl,
  }) : super(repaint: clock);

  final Color track;
  final Color fill;
  final Color rest;
  final double? fraction;
  final double start;
  final bool vertical;
  final ValueListenable<Duration>? clock;
  final bool reduced;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Offset.zero & size;
    final double extent = vertical ? size.height : size.width;
    final Radius round = Radius.circular((vertical ? size.width : size.height) / 2);

    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(box, round))
      ..drawRect(box, Paint()..color = track);

    final double? fraction = this.fraction;
    final ValueListenable<Duration>? clock = this.clock;

    if (fraction != null) {
      final double from = extent * start;
      final double length = extent * fraction - from;

      if (length > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(_fromStart(size, from, length), round),
          Paint()..color = fill,
        );
      }
    } else if (clock != null) {
      if (reduced) {
        final ({int span, double t}) at = progressKeyframe(
          progressPhase(clock.value, NebaGroove.pulse) ?? 0,
          const <double>[0, 0.5, 1],
        );
        final Color beat = at.span == 0
            ? Color.lerp(rest, fill, at.t)!
            : Color.lerp(fill, rest, at.t)!;

        canvas.drawRRect(RRect.fromRectAndRadius(box, round), Paint()..color = beat);
      } else {
        // From one length of itself before the start to the far end of the
        // groove: a translation of what is painted, never of a box.
        final double t = NebaScale.ease.transform(
          progressPhase(clock.value, NebaGroove.sweep) ?? 0,
        );
        final double length = extent * NebaGroove.segment;
        final double from = -length + (extent + length) * t;

        canvas.drawRRect(
          RRect.fromRectAndRadius(_fromStart(size, from, length), round),
          Paint()..color = fill,
        );
      }
    }

    canvas.restore();
  }

  /// A run [length] long, [from] in from the start edge: the bottom of a
  /// vertical groove, and the inline start of any other.
  Rect _fromStart(Size size, double from, double length) {
    if (vertical) {
      return Rect.fromLTWH(0, size.height - from - length, size.width, length);
    }

    return rtl
        ? Rect.fromLTWH(size.width - from - length, 0, length, size.height)
        : Rect.fromLTWH(from, 0, length, size.height);
  }

  @override
  bool shouldRepaint(_GroovePainter oldDelegate) {
    return oldDelegate.track != track ||
        oldDelegate.fill != fill ||
        oldDelegate.rest != rest ||
        oldDelegate.fraction != fraction ||
        oldDelegate.start != start ||
        oldDelegate.vertical != vertical ||
        oldDelegate.clock != clock ||
        oldDelegate.reduced != reduced ||
        oldDelegate.rtl != rtl;
  }
}
