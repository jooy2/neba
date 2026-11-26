/// The focus ring, the React package's `focus-visible:[outline:2px_solid_…]`.
///
/// Two pixels wide, two pixels off the control, following its corners, in the
/// family's `ring` colour, and only for keyboard focus. What changes is the
/// colour and never the width, as in the React package: the ring is always
/// there and goes from transparent to its colour over the house duration, so
/// it never snaps in and never changes the control's size. A field's shell
/// draws it flush, with no offset, because the hairline under it is already
/// the ring's colour.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';

/// The ring's width.
const double focusRingWidth = 2;

/// How far the ring stands off a control, CSS `outline-offset: 2px`.
const double focusRingOffset = 2;

/// [child] with a focus ring drawn around it while [visible].
class NebaFocusRing extends StatelessWidget {
  /// A ring in [color] around [child], whose corners are [borderRadius].
  const NebaFocusRing({
    required this.visible,
    required this.color,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.offset = focusRingOffset,
    super.key,
  });

  /// Whether the ring is shown.
  final bool visible;

  /// The ring's colour.
  final Color color;

  /// The control's corners. The ring's follow them, grown by the offset.
  final BorderRadius borderRadius;

  /// How far outside the control the ring stands.
  final double offset;

  /// The control.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: visible ? color : color.withValues(alpha: 0)),
      duration: nebaDuration(context, NebaScale.duration),
      curve: NebaScale.ease,
      builder: (BuildContext context, Color? ring, Widget? child) {
        return CustomPaint(
          foregroundPainter: _RingPainter(ring ?? color, borderRadius, offset),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.borderRadius, this.offset);

  final Color color;
  final BorderRadius borderRadius;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) {
      return;
    }

    final RRect ring = borderRadius
        .toRRect(Offset.zero & size)
        .inflate(offset + focusRingWidth / 2);

    canvas.drawRRect(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focusRingWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.offset != offset;
  }
}
