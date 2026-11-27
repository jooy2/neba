/// `NebaAnimateGrow`, content unfolding from a point.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content unfolding from a point. It starts close to its final size and can
/// be anchored to any edge with [origin], so it reads as something opening out
/// of the thing next to it: a panel out of a toolbar, a card out of the row it
/// belongs to.
///
/// [NebaAnimateMode.exit] folds it away again, held at the end. Every setting
/// it shares with the other `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateGrow(
///   origin: Alignment.topCenter,
///   child: NebaCard(title: Text('Filters'), child: Text('Three of nine applied.')),
/// )
/// ```
class NebaAnimateGrow extends NebaAnimateBase {
  /// [child], or [children], growing from [from] of its size about [origin].
  const NebaAnimateGrow({
    this.mode = NebaAnimateMode.enter,
    this.from = 0.8,
    this.origin = Alignment.center,
    this.fade = true,
    super.duration = const Duration(milliseconds: 340),
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

  /// Whether the content unfolds or folds away.
  final NebaAnimateMode mode;

  /// The scale it starts from, as a multiple of its final size. Above 1 it
  /// settles down onto the page instead of up out of it.
  final double from;

  /// Which point stays put while the rest moves: [Alignment.topCenter]
  /// unfolds downwards, [Alignment.bottomLeft] out of a corner.
  final AlignmentGeometry origin;

  /// Fades in as it grows. Turn it off for something already on the page that
  /// is only changing size.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(
        keyframe: NebaKeyframe.scale,
        scale: from,
        opacity: fade ? 0 : 1,
        origin: origin,
      ),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
