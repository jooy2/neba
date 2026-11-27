/// `NebaAnimateFloat`, a slow drift with nowhere to get to.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// A slow drift with nowhere to get to. It says that something is not fixed to
/// the page (an illustration, a floating card, a mark above a hero), and it
/// runs for as long as the widget is built, turning round at both ends so
/// there is never a frame where it jumps back.
///
/// It starts where the widget sits, so one that is held is left where the
/// layout put it or on its way back there, and a reader who asked for less
/// motion sees it not move at all. Never float a control: something that is
/// never quite where it was is harder to press. There is no `mode`. Every
/// setting it shares with the other `Animate*` widgets is on
/// [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateFloat(
///   child: NebaCard(elevation: 2, child: Text('Not fixed to the page.')),
/// )
/// ```
class NebaAnimateFloat extends NebaAnimateBase {
  /// [child], or [children], drifting [distance] towards [from] and back.
  const NebaAnimateFloat({
    this.from = NebaSide.top,
    this.distance = 8,
    super.duration = const Duration(milliseconds: 3200),
    super.delay,
    super.curve = Curves.easeInOut,
    super.repeat = double.infinity,
    super.alternate = true,
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

  /// Which way it drifts. Physical, so it does not flip under RTL.
  final NebaSide from;

  /// How far it gets at the top of the drift, in logical pixels. Small on
  /// purpose: past about a centimetre it stops reading as something resting.
  final double distance;

  @override
  Widget build(BuildContext context) {
    final ({Offset offset, Offset fraction}) end = nebaSlideStart(from, distance);

    return nebaAnimate(
      this,
      effect: NebaEffect(keyframe: NebaKeyframe.float, offset: end.offset),
    );
  }
}
