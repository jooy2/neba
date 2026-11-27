/// `NebaAnimateFade`, content arriving or leaving on opacity alone.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content arriving or leaving on opacity alone: the plainest effect in the
/// set, and the one to reach for first. Nothing moves, so nothing reflows and
/// no text is resampled.
///
/// [NebaAnimateMode.exit] is the same fade backwards, held at the end, so
/// what faded out stays faded out. Every setting it shares with the other
/// `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateFade(
///   child: NebaCard(title: Text('Deployment finished'), child: Text('No errors.')),
/// )
/// ```
class NebaAnimateFade extends NebaAnimateBase {
  /// [child], or [children], fading in from [from].
  const NebaAnimateFade({
    this.mode = NebaAnimateMode.enter,
    this.from = 0,
    super.duration = const Duration(milliseconds: 320),
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

  /// Whether the content arrives or leaves.
  final NebaAnimateMode mode;

  /// The opacity it starts from, between 0 and 1. Raise it for content that
  /// should never be completely gone.
  final double from;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.fade, opacity: from),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
