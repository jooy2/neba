/// The light on a surface the pointer can act on, the React package's
/// `.neba-glow` layers.
///
/// Two layers, both centred where the pointer is. The spotlight is an 88-pixel
/// bloom that trails a mouse across the surface and fades in and out over
/// 240ms. The afterglow is a 72-pixel flash that lands on the frame of a press
/// and drains over 900ms after it, which is the whole of the house press
/// signature: no ripple, no timers. Both are off for a reader who asked for
/// less motion. A finger never hovers, so on a touch screen only the afterglow
/// is ever seen.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/color.dart';
import 'package:neba/src/internal/interaction.dart';
import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// The colours of the two layers.
@immutable
class NebaGlowColors {
  /// The spotlight's and the afterglow's colours.
  const NebaGlowColors({required this.glow, required this.flash});

  /// What a surface of [variant] in [color]'s family lights with: white over a
  /// fill, and the family's own wash over everything else. Never a tinted
  /// light on a filled surface, which would only be a darker fill.
  factory NebaGlowColors.of(NebaTokens tokens, NebaColor color, NebaVariant variant) {
    if (variant == NebaVariant.solid) {
      return NebaGlowColors(glow: tokens.glowOnFill, flash: tokens.flashOnFill);
    }

    final NebaColorRoles roles = tokens.roles(color);

    return NebaGlowColors(glow: roles.soft, flash: roles.softPress);
  }

  /// What a field's shell lights with: half the family's wash, and no flash.
  ///
  /// A field is entered rather than pressed, so it takes the spotlight and
  /// never the afterglow. And it is a thing the pointer passes over on its way
  /// to putting a caret down: what the reader looks at next is their own text,
  /// and a bloom at full strength would sit behind it. Half of [roles]' own
  /// wash rather than a paler token, so a field that turns `danger` the moment
  /// it is invalid takes the danger light at the same strength.
  factory NebaGlowColors.field(NebaColorRoles roles) {
    return NebaGlowColors(glow: mixSrgb(roles.soft, 0.5, transparent), flash: transparent);
  }

  /// The spotlight's colour.
  final Color glow;

  /// The afterglow's colour.
  final Color flash;

  @override
  bool operator ==(Object other) {
    return other is NebaGlowColors && other.glow == glow && other.flash == flash;
  }

  @override
  int get hashCode => Object.hash(glow, flash);
}

/// The spotlight's radius, CSS `5.5rem`.
const double spotlightRadius = 88;

/// The afterglow's radius, CSS `4.5rem`.
const double afterglowRadius = 72;

/// How long the spotlight takes to come and go.
const Duration spotlightDuration = Duration(milliseconds: 240);

/// How long the afterglow takes to drain after a press.
const Duration afterglowDuration = Duration(milliseconds: 900);

/// The afterglow's curve, CSS `cubic-bezier(0.22, 1, 0.36, 1)`.
const Curve afterglowCurve = Cubic(0.22, 1, 0.36, 1);

/// The two layers over a surface of [borderRadius], filling the box it is
/// given. Paints nothing that takes a pointer.
class NebaGlow extends StatelessWidget {
  /// The light for a control in [interaction], following [pointer].
  const NebaGlow({
    required this.interaction,
    required this.pointer,
    required this.colors,
    this.borderRadius = BorderRadius.zero,
    this.spotlight = true,
    this.afterglow = true,
    super.key,
  });

  /// The control's state: the spotlight shows while it is hovered, the
  /// afterglow while it is pressed.
  final NebaInteraction interaction;

  /// Where the pointer is; the centre of the box while it is `null`.
  final ValueListenable<Offset?> pointer;

  /// The layers' colours.
  final NebaGlowColors colors;

  /// The surface's corners, which the light is clipped to.
  final BorderRadius borderRadius;

  /// Whether the spotlight is drawn. A surface the reader is typing into
  /// turns it off, because the pointer resting over the text is exactly where
  /// the bloom is least wanted.
  final bool spotlight;

  /// Whether the afterglow is drawn. A surface that is merely entered, such as
  /// a field, has a spotlight and no afterglow.
  final bool afterglow;

  @override
  Widget build(BuildContext context) {
    if (nebaReducedMotion(context)) {
      return const SizedBox.shrink();
    }

    final bool spotlightOn = spotlight && interaction.hovered;
    final bool afterglowOn = afterglow && interaction.pressed;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _Layer(
            visible: spotlightOn,
            duration: spotlightDuration,
            curve: NebaScale.ease,
            painter: _LightPainter(pointer, colors.glow, spotlightRadius, 0.70, borderRadius),
          ),
          _Layer(
            visible: afterglowOn,
            // In on the frame of the press, out slowly.
            duration: afterglowOn ? Duration.zero : afterglowDuration,
            curve: afterglowCurve,
            painter: _LightPainter(pointer, colors.flash, afterglowRadius, 0.72, borderRadius),
          ),
        ],
      ),
    );
  }
}

class _Layer extends StatelessWidget {
  const _Layer({
    required this.visible,
    required this.duration,
    required this.curve,
    required this.painter,
  });

  final bool visible;
  final Duration duration;
  final Curve curve;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1 : 0),
      duration: duration,
      curve: curve,
      builder: (BuildContext context, double opacity, Widget? child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: CustomPaint(painter: painter),
    );
  }
}

class _LightPainter extends CustomPainter {
  _LightPainter(this.pointer, this.color, this.radius, this.stop, this.borderRadius)
    : super(repaint: pointer);

  final ValueListenable<Offset?> pointer;
  final Color color;
  final double radius;
  final double stop;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) {
      return;
    }

    final Offset center = pointer.value ?? size.center(Offset.zero);
    final Rect circle = Rect.fromCircle(center: center, radius: radius);

    canvas.save();
    canvas.clipRRect(borderRadius.toRRect(Offset.zero & size));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[color, color.withValues(alpha: 0)],
          stops: <double>[0, stop],
        ).createShader(circle),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LightPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.pointer != pointer;
  }
}
