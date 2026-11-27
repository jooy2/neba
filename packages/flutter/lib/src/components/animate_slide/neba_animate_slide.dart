/// `NebaAnimateSlide`, content travelling in from one edge.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// Content travelling in from one edge. The default distance is the widget's
/// own size, so it starts exactly out of frame and is never half drawn
/// somewhere it does not belong; inside a [ClipRect] it is a panel appearing
/// from behind that box's edge.
///
/// It is a translation painted over the widget as it is laid out, so nothing
/// around it moves while it runs. [NebaAnimateMode.exit] sends it back the
/// way it came, held there. Every setting it shares with the other `Animate*`
/// widgets is on [NebaAnimateBase].
///
/// ```dart
/// ClipRect(
///   child: NebaAnimateSlide(
///     from: NebaSide.left,
///     child: NebaAlert(color: NebaColor.success, title: Text('Invitation sent')),
///   ),
/// )
/// ```
class NebaAnimateSlide extends NebaAnimateBase {
  /// [child], or [children], travelling in from [from].
  const NebaAnimateSlide({
    this.mode = NebaAnimateMode.enter,
    this.from = NebaSide.bottom,
    this.distance,
    this.fade = true,
    super.duration = const Duration(milliseconds: 380),
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

  /// Whether the content slides in or slides away. An exit leaves by the same
  /// edge it would have come from.
  final NebaAnimateMode mode;

  /// Which edge it travels from. Physical, as [NebaSide] is everywhere: a
  /// panel sliding down from the top comes from the top in every writing
  /// direction.
  final NebaSide from;

  /// How far it travels, in logical pixels. Left out, it is the widget's own
  /// width or height, which starts it exactly out of frame.
  final double? distance;

  /// Fades in as it slides.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    final ({Offset offset, Offset fraction}) start = nebaSlideStart(from, distance);

    return nebaAnimate(
      this,
      effect: NebaEffect(
        keyframe: NebaKeyframe.slide,
        offset: start.offset,
        fraction: start.fraction,
        opacity: fade ? 0 : 1,
      ),
      reversed: mode == NebaAnimateMode.exit,
    );
  }
}
