/// `NebaAnimateBlink`, content pulsing between full opacity and a floor.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content pulsing between full opacity and a floor. The cycle is
/// symmetric, full, faint and full again, so however many times it runs it
/// ends where it started.
///
/// It repeats until the widget goes unless `repeat` says otherwise, because a
/// single blink is a flicker. `duration` is one blink and is never shorter
/// than 334 milliseconds: more than three flashes a second can bring on a
/// seizure. Held with `paused`, or off the screen, it rests at full opacity
/// rather than wherever the pulse had got to, and starts over when it is let
/// go. A reader who asked for less motion sees none of it, so the blink is
/// never the only thing carrying the message.
///
/// There is no `mode`: the cycle is the same both ways. Every setting it
/// shares with the other `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateBlink(
///   min: 0.35,
///   child: NebaChip(color: NebaColor.danger, variant: NebaVariant.solid, child: Text('Recording')),
/// )
/// ```
class NebaAnimateBlink extends NebaAnimateBase {
  /// [child], or [children], pulsing down to [min] and back.
  const NebaAnimateBlink({
    this.min = 0,
    super.duration = const Duration(milliseconds: 900),
    super.delay,
    super.curve,
    super.repeat = double.infinity,
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

  /// How faint it gets at the bottom of the cycle, between 0 and 1. Raise it
  /// for something that has to stay readable while it pulses.
  final double min;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.blink, opacity: min),
      duration: duration < nebaMinBlinkDuration ? nebaMinBlinkDuration : duration,
    );
  }
}
