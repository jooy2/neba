/// `NebaAnimateRotate`, content turning about a point.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content turning about a point. Two angles rather than one, so the same
/// widget covers both a glyph swinging into place and one that spins without
/// ever landing: [from] alone is an arrival, and [from] and [to] with an
/// endless `repeat`, `Curves.linear` and no [fade] is a spin.
///
/// Rotation is for glyphs. A turned word is resampled along its whole length,
/// which is what the design language's rule against transforms exists to
/// prevent. Every setting it shares with the other `Animate*` widgets is on
/// [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateRotate(
///   from: -270,
///   child: NebaIcon(icon: star, size: NebaSize.xl, color: NebaColor.warning),
/// )
/// ```
class NebaAnimateRotate extends NebaAnimateBase {
  /// [child], or [children], turning from [from] degrees to [to] about
  /// [origin].
  const NebaAnimateRotate({
    this.mode = NebaAnimateMode.enter,
    this.from = -180,
    this.to = 0,
    this.origin = Alignment.center,
    this.fade = true,
    super.duration = const Duration(milliseconds: 460),
    super.delay,
    super.curve,
    super.repeat,
    super.alternate,
    super.paused,
    super.trigger,
    super.play,
    super.once,
    super.threshold,
    super.stagger,
    super.durationStep,
    super.reverse,
    super.timeline,
    super.range,
    super.layoutBuilder,
    super.children,
    super.child,
    super.key,
  });

  /// Whether the content turns into place or out of it.
  final NebaAnimateMode mode;

  /// The angle it starts at, in degrees. Negative is anticlockwise.
  final double from;

  /// The angle it ends at, in degrees.
  final double to;

  /// Which point it turns about.
  final AlignmentGeometry origin;

  /// Fades in as it turns. Turn it off for a continuous spin, where a
  /// repeating fade would read as flickering.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(
        keyframe: NebaKeyframe.rotate,
        angle: from,
        angleTo: to,
        opacity: fade ? 0 : 1,
        origin: origin,
      ),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
