/// `NebaProgressBox`, progress as a row of acrylic plates that light up.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
import 'package:neba/src/internal/surface.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Progress as a row of acrylic plates that light up: the shape that is
/// about the material rather than the quantity, and the one for a loading
/// state on a Neba surface, where a foreign spinner would look borrowed.
///
/// With a [value] the plates fill from the start, the leading one partly, so
/// four plates read as a four-segment bar and 30% does not round away to a
/// quarter. Without one they light in turn, each held back by its place in
/// the row; only their colour changes, never where they are. A reader who
/// asked for less motion sees the same wave at half the speed.
///
/// ```dart
/// const NebaProgressBox(value: 62, label: Text('Migrating'), showValue: true)
/// ```
class NebaProgressBox extends StatefulWidget {
  /// A row of [count] plates filled [value] of the way from [min] to [max],
  /// or lighting in turn without a [value].
  const NebaProgressBox({
    this.value,
    this.min = 0,
    this.max = 100,
    this.label,
    this.showValue = false,
    this.format,
    this.size,
    this.color,
    this.count = 4,
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

  /// What is loading, usually a [Text], at the start of the row above the
  /// plates. A [Text] is also the name a screen reader hears.
  final Widget? label;

  /// Whether the reading is drawn at the end of the row above the plates: a
  /// percentage of the range unless [format] says otherwise.
  final bool showValue;

  /// What the value is written as, once the number means something: given
  /// the value held to the range, it returns the text. Without it the reading
  /// is a whole percentage of [min] to [max].
  final String Function(double value)? format;

  /// The size of one plate, 8, 10, 12, 16 or 20 logical pixels square, and
  /// the type scale above the row. Defaults to `NebaProvider`'s, then
  /// [NebaSize.md].
  final NebaSize? size;

  /// The family of the plates. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// How many plates the row is made of. Four by default: enough that the
  /// wave reads as a wave, few enough to count at a glance. Set it to the
  /// number of steps when what is being waited on has steps. A count under
  /// one draws one plate.
  final int count;

  /// The name a screen reader hears in place of [label].
  final String? semanticLabel;

  /// One pass of the wave along the row.
  static const Duration wave = Duration(milliseconds: 1200);

  /// How long each plate waits behind the one before it.
  static const Duration stagger = Duration(milliseconds: 120);

  @override
  State<NebaProgressBox> createState() => _NebaProgressBoxState();
}

class _NebaProgressBoxState extends State<NebaProgressBox> with SingleTickerProviderStateMixin {
  late final NebaProgressClock _clock = NebaProgressClock(this);

  double? get _fraction => progressFraction(widget.value, widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _clock.run(_fraction == null);
  }

  @override
  void didUpdateWidget(NebaProgressBox oldWidget) {
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
    final int plates = math.max(1, widget.count);
    final _Look look = _Look(
      tokens: tokens,
      soft: roles.soft,
      fill: roles.fill,
      radius: BorderRadius.circular(plateRadius[size]!),
      rtl: Directionality.of(context) == TextDirection.rtl,
      period: nebaReducedMotion(context) ? NebaProgressBox.wave * 2 : NebaProgressBox.wave,
    );
    final double side = plateSize[size]!;
    final Duration duration = nebaDuration(context, NebaScale.durationFill);

    Widget plate(int index) {
      if (fraction == null) {
        return _Plate(look: look, side: side, index: index, clock: _clock);
      }

      // Each plate is a track of its own, so the leading one can be part
      // full, and each one eases to its own share when the reading changes.
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(end: (fraction * plates - index).clamp(0.0, 1.0)),
        duration: duration,
        curve: NebaScale.ease,
        builder: (BuildContext context, double filled, Widget? _) {
          return _Plate(look: look, side: side, index: index, filled: filled);
        },
      );
    }

    final Widget? label = widget.label;

    return progressSemantics(
      value: text,
      semanticLabel: widget.semanticLabel,
      // As wide as the row of plates or the row above it, whichever is
      // wider, and no wider than it is given.
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: NebaScale.stackGap[size]!,
          children: <Widget>[
            if (label != null || widget.showValue)
              NebaProgressCaption(
                size: size,
                label: label,
                value: text,
                showValue: widget.showValue,
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: plateGap[size]!,
              children: <Widget>[for (int i = 0; i < plates; i++) plate(i)],
            ),
          ],
        ),
      ),
    );
  }
}

/// What every plate of one row is drawn with.
@immutable
class _Look {
  const _Look({
    required this.tokens,
    required this.soft,
    required this.fill,
    required this.radius,
    required this.rtl,
    required this.period,
  });

  final NebaTokens tokens;
  final Color soft;
  final Color fill;
  final BorderRadius radius;
  final bool rtl;

  /// One pass of the wave.
  final Duration period;

  @override
  bool operator ==(Object other) {
    return other is _Look &&
        other.tokens == tokens &&
        other.soft == soft &&
        other.fill == fill &&
        other.radius == radius &&
        other.rtl == rtl &&
        other.period == period;
  }

  @override
  int get hashCode => Object.hash(tokens, soft, fill, radius, rtl, period);
}

/// One plate: filled to [filled] from the start, or lighting in its turn on
/// [clock] while there is no reading.
class _Plate extends StatelessWidget {
  const _Plate({
    required this.look,
    required this.side,
    required this.index,
    this.filled,
    this.clock,
  });

  final _Look look;
  final double side;
  final int index;
  final double? filled;
  final ValueListenable<Duration>? clock;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: side,
      child: CustomPaint(painter: _PlatePainter(look, index, filled, clock)),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.look, this.index, this.filled, this.clock) : super(repaint: clock);

  final _Look look;
  final int index;
  final double? filled;
  final ValueListenable<Duration>? clock;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect box = Offset.zero & size;
    final RRect shape = look.radius.toRRect(box);
    final double? filled = this.filled;
    final ValueListenable<Duration>? clock = this.clock;

    canvas
      ..save()
      ..clipRRect(shape);

    if (filled != null) {
      canvas.drawRect(box, Paint()..color = look.soft);
      paintPlate(canvas, shape, look.tokens, NebaPlate.glass);

      // The fill lies over the plate's top light, as a child lies over the
      // inset shadow of the box it is in.
      if (filled > 0) {
        final double length = size.width * filled;

        canvas.drawRect(
          look.rtl
              ? Rect.fromLTWH(size.width - length, 0, length, size.height)
              : Rect.fromLTWH(0, 0, length, size.height),
          Paint()..color = look.fill,
        );
      }
    } else if (clock != null) {
      // Lit at a third of the way through each pass and dark again by
      // seven tenths, waiting out its place in the row first: the colour
      // and the plate's edge change, and the plate never moves.
      final double? phase = progressPhase(
        clock.value,
        look.period,
        delay: NebaProgressBox.stagger * index,
      );
      Color colour = look.soft;
      double edge = 0;

      if (phase != null) {
        final ({int span, double t}) at = progressKeyframe(phase, const <double>[0, 0.35, 0.7, 1]);

        if (at.span == 0) {
          colour = Color.lerp(look.soft, look.fill, at.t)!;
          edge = at.t;
        } else if (at.span == 1) {
          colour = Color.lerp(look.fill, look.soft, at.t)!;
          edge = 1 - at.t;
        }
      }

      canvas.drawRect(box, Paint()..color = colour);
      paintPlate(canvas, shape, look.tokens, NebaPlate.glass);

      if (edge > 0) {
        final Color hairline = look.tokens.plateEdge;

        strokeInside(canvas, shape, hairline.withValues(alpha: hairline.a * edge));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlatePainter oldDelegate) {
    return oldDelegate.look != look ||
        oldDelegate.index != index ||
        oldDelegate.filled != filled ||
        oldDelegate.clock != clock;
  }
}
