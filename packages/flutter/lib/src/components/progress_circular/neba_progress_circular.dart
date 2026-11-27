/// `NebaProgressCircular`, progress as a ring that fills.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Progress as a ring that fills, for where there is no room for a bar:
/// inside a button, at the end of a table row, next to a field.
///
/// The ring is just under the control height at every size, so it drops into
/// a row of controls without making the row taller. The [label] and the
/// reading sit beside it rather than inside: at `xs` the ring is fourteen
/// pixels across, and there is nowhere for "40%" to go.
///
/// Without a [value] it is indeterminate, and a quarter of the ring turns
/// once every 900 milliseconds, or every 2.4 seconds for a reader who asked
/// for less motion, slowed rather than stopped because a ring that holds
/// still says nothing is happening.
///
/// ```dart
/// const NebaProgressCircular(value: 72, label: Text('Indexing'), showValue: true)
/// ```
class NebaProgressCircular extends StatefulWidget {
  /// A ring [value] of the way from [min] to [max], or an indeterminate one
  /// without a [value].
  const NebaProgressCircular({
    this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.format,
    this.size,
    this.color,
    this.thickness,
    this.semanticLabel,
    super.key,
  });

  /// How far along, between [min] and [max]. `null`, the default, is the
  /// indeterminate case: something is happening and nobody knows how much of
  /// it is left. A value past either end of the range is held to it.
  final double? value;

  /// The bottom of the range.
  final double min;

  /// The top of the range.
  final double max;

  /// What is loading, usually a [Text], beside the ring. A [Text] is also
  /// the name a screen reader hears.
  final Widget? label;

  /// Whether the reading is drawn beside the ring, after the [label]: a
  /// percentage of the range unless [format] says otherwise.
  final bool showValue;

  /// What the value is written as, once the number means something: given
  /// the value held to the range, it returns the text. Without it the reading
  /// is a whole percentage of [min] to [max].
  final String Function(double value)? format;

  /// The ring's diameter, 14, 16, 20, 26 or 32 logical pixels, and the type
  /// scale beside it. Defaults to `NebaProvider`'s, then [NebaSize.md].
  final NebaSize? size;

  /// The family of the ring. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The ring's stroke in logical pixels, when the step's own is not the one
  /// wanted. [size] still sets the diameter, so this is how thick the ring is
  /// and not how big. It is held to half the radius, so a hole always
  /// remains.
  final double? thickness;

  /// The name a screen reader hears in place of [label].
  final String? semanticLabel;

  @override
  State<NebaProgressCircular> createState() => _NebaProgressCircularState();
}

class _NebaProgressCircularState extends State<NebaProgressCircular>
    with SingleTickerProviderStateMixin {
  late final NebaProgressClock _clock = NebaProgressClock(this);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _clock.run(_fraction == null);
  }

  @override
  void didUpdateWidget(NebaProgressCircular oldWidget) {
    super.didUpdateWidget(oldWidget);
    _clock.run(_fraction == null);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final NebaSize size = widget.size ?? NebaTheme.defaultsOf(context).size ?? NebaSize.md;
    final NebaColorRoles roles = tokens.roles(widget.color ?? NebaColor.primary);
    final double? fraction = _fraction;
    final String? text = progressText(
      fraction: fraction,
      value: widget.value,
      min: widget.min,
      max: widget.max,
      format: widget.format,
    );
    final double diameter = ringDiameter[size]!;
    // Past half the radius the hole is too small to read as a ring, so a
    // caller's stroke is held there.
    final double stroke = math.min(
      math.max(widget.thickness ?? ringStroke[size]!, 0.5),
      diameter / 4,
    );
    final bool reduced = nebaReducedMotion(context);

    Widget ring(double? filled) {
      return SizedBox.square(
        dimension: diameter,
        child: CustomPaint(
          painter: _RingPainter(
            track: roles.soft,
            arc: roles.accent,
            stroke: stroke,
            fraction: filled,
            clock: filled == null ? _clock : null,
            reduced: reduced,
          ),
        ),
      );
    }

    // A reading that changes closes the gap over the fill's duration.
    final Widget drawn = fraction == null
        ? ring(null)
        : TweenAnimationBuilder<double>(
            tween: Tween<double>(end: fraction),
            duration: nebaDuration(context, NebaScale.durationFill),
            curve: NebaScale.ease,
            builder: (BuildContext context, double filled, Widget? _) => ring(filled),
          );
    final Widget? label = widget.label;

    return progressSemantics(
      value: text,
      semanticLabel: widget.semanticLabel,
      // As wide as what it holds, and no wider than it is given, which is
      // where a long label is cut short.
      child: IntrinsicWidth(
        child: DefaultTextStyle.merge(
          style: TextStyle(fontSize: NebaScale.metaText[size]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: NebaScale.gap[size]!,
            children: <Widget>[
              drawn,
              if (label != null) Flexible(child: progressLabel(tokens, label)),
              if (widget.showValue) progressValue(tokens, text),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ring: a full circle in the family's wash, and the arc over it in the
/// family's accent, from twelve o'clock clockwise as far as the reading, or a
/// quarter of it turning while there is none.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.track,
    required this.arc,
    required this.stroke,
    required this.fraction,
    required this.clock,
    required this.reduced,
  }) : super(repaint: clock);

  final Color track;
  final Color arc;
  final double stroke;
  final double? fraction;
  final ValueListenable<Duration>? clock;
  final bool reduced;

  /// The share of the ring the turning arc covers.
  static const double reach = 0.28;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    // The stroke straddles the circle, so the radius comes in by half of it
    // or the ring is cut by its own box.
    final double radius = size.width / 2 - stroke / 2;
    final Rect circle = Rect.fromCircle(center: centre, radius: radius);
    const double top = -math.pi / 2;

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = arc;
    final double? fraction = this.fraction;
    final ValueListenable<Duration>? clock = this.clock;

    if (fraction != null) {
      if (fraction > 0) {
        canvas.drawArc(circle, top, 2 * math.pi * fraction, false, line);
      }
    } else if (clock != null) {
      // One turn of the arc's start, at a steady speed: the glyph turning,
      // as the house spinner turns, with nothing laid out again.
      final double turn =
          progressPhase(clock.value, Duration(milliseconds: reduced ? 2400 : 900)) ?? 0;

      canvas.drawArc(circle, top + 2 * math.pi * turn, 2 * math.pi * reach, false, line);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.track != track ||
        oldDelegate.arc != arc ||
        oldDelegate.stroke != stroke ||
        oldDelegate.fraction != fraction ||
        oldDelegate.clock != clock ||
        oldDelegate.reduced != reduced;
  }
}
