/// `NebaAnimateReveal`, content uncovered by an edge travelling across it.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content uncovered by an edge travelling across it. Nothing moves and
/// nothing changes colour: the content is already in place at full size, and
/// what changes is how much of it a clip lets through, so everything around
/// it is laid out against the finished size from the first frame. It is the
/// effect for a heading, a rule or a chart's plot area: anything whose
/// position is part of the information.
///
/// The content is in the semantics tree the whole time; a clip hides pixels,
/// not information. [NebaAnimateMode.exit] runs the same edge backwards and
/// holds it there, which covers the content up. Every setting it shares with
/// the other `Animate*` widgets is on [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateReveal(
///   child: NebaTypography('Nothing moved.', level: NebaTypographyLevel.h4),
/// )
/// ```
class NebaAnimateReveal extends NebaAnimateBase {
  /// [child], or [children], wiped in from [side].
  const NebaAnimateReveal({
    this.mode = NebaAnimateMode.enter,
    this.side = NebaSide.left,
    this.from = 1,
    super.duration = const Duration(milliseconds: 620),
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

  /// Whether the content is uncovered or covered again.
  final NebaAnimateMode mode;

  /// The edge the wipe travels from: [NebaSide.left] uncovers left to right.
  /// Physical, so it does not flip under RTL.
  final NebaSide side;

  /// The opacity it fades from as it wipes. 1, the default, is a wipe and
  /// nothing else, which is the point of reaching for one.
  final double from;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.reveal, side: side, opacity: from),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
