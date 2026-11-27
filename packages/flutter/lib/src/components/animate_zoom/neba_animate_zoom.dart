/// `NebaAnimateZoom`, content arriving from the middle of where it will end
/// up.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content arriving from the middle of where it will end up: the same
/// arithmetic as `NebaAnimateGrow` at more than twice the distance, and always
/// about the centre, for the one thing on a screen that is meant to
/// interrupt: a confirmation, a result, a number that just landed.
///
/// There is no `origin`: a zoom anchored to a corner is a grow.
/// [NebaAnimateMode.exit] drops it away again, held at the end. Every setting
/// it shares with the other `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateZoom(
///   child: NebaStatistic(label: Text('Uptime this quarter'), value: 99.98, unit: Text('%')),
/// )
/// ```
class NebaAnimateZoom extends NebaAnimateBase {
  /// [child], or [children], zooming in from [from] of its size.
  const NebaAnimateZoom({
    this.mode = NebaAnimateMode.enter,
    this.from = 0.4,
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

  /// Whether the content comes forward or falls away.
  final NebaAnimateMode mode;

  /// The scale it starts from, as a multiple of its final size. Above 1 it
  /// arrives oversized and settles back, which reads as coming towards the
  /// reader rather than up out of the page.
  final double from;

  /// Fades in as it zooms.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.scale, scale: from, opacity: fade ? 0 : 1),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
