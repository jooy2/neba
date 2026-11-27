/// `NebaAnimateShake`, the one effect in the set that says no.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// The one effect in the set that says no: a password that was wrong, a form
/// that would not send, a row that could not be dropped where it was let go.
/// Every other effect here is content arriving; this one is an answer.
///
/// It waits for `play` rather than running on its first build, because a
/// shake that runs on its own is decoration. Bind `play` to a count of the
/// failures: each new number replays it without rebuilding what is inside it,
/// so the second wrong answer moves as much as the first and the focus stays
/// where it was. It starts and ends where the widget sits, so a run that is
/// interrupted leaves nothing off its mark; it has no `mode`, and it should
/// never be given a `repeat`.
///
/// A shake is the one movement the design language allows on a control: not a
/// state of it but a reply, over in under half a second. Under reduced motion
/// nothing moves, so say what went wrong in words too. Every setting it shares
/// with the other `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateShake(
///   play: attempts,
///   child: NebaTextField(label: Text('Passphrase'), error: message),
/// )
/// ```
class NebaAnimateShake extends NebaAnimateBase {
  /// [child], or [children], shaken [distance] each way when [play] says.
  const NebaAnimateShake({
    this.distance = 6,
    super.duration = const Duration(milliseconds: 420),
    super.delay,
    super.curve = Curves.easeInOut,
    super.repeat,
    super.alternate,
    super.paused,
    super.trigger = NebaAnimateTrigger.manual,
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

  /// How far it travels at the widest point, in logical pixels. Short: this
  /// is a head shaken, not a thing thrown.
  final double distance;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.shake, offset: Offset(distance, 0)),
    );
  }
}
