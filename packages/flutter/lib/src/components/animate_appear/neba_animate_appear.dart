/// `NebaAnimateAppear`, a list of things settling into place one after
/// another.
library;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

export 'package:neba/src/internal/animate.dart' show NebaAnimateBase;

/// A list of things settling into place one after another.
///
/// Each of [children] gets the same short fade and drift, held back by its
/// place in the list, so the effect belongs to the set rather than to any one
/// item and a reader's eye is walked down the list in the order it should be
/// read. The step is per child: eight children are eight steps, and one child
/// holding eight things is one step, which is also how to opt part of a list
/// out.
///
/// Each child runs the effect on its own even with no `stagger`, and is laid
/// out by `layoutBuilder` as it would be without it, so a row stays a row.
/// Every setting it shares with the other `Animate*` widgets is on
/// [NebaAnimateBase].
///
/// ```dart
/// NebaAnimateAppear(
///   children: <Widget>[
///     NebaCard(title: Text('Design review'), child: Text('Thursday, 14:00')),
///     NebaCard(title: Text('Sprint planning'), child: Text('Friday, 10:00')),
///   ],
/// )
/// ```
class NebaAnimateAppear extends NebaAnimateBase {
  /// [children], settling in one after another from [from].
  const NebaAnimateAppear({
    required List<Widget> super.children,
    this.from = NebaSide.bottom,
    this.distance = 12,
    this.fade = true,
    super.duration = const Duration(milliseconds: 420),
    super.delay,
    super.curve,
    super.repeat,
    super.alternate,
    super.paused,
    super.trigger,
    super.play,
    super.once,
    super.threshold,
    super.stagger = const Duration(milliseconds: 80),
    super.durationStep,
    super.reverse,
    super.timeline,
    super.range,
    super.layoutBuilder,
    super.key,
  });

  /// Which edge each child drifts in from. Physical, as [NebaSide] is
  /// everywhere.
  final NebaSide from;

  /// How far each child travels, in logical pixels. Short on purpose: this is
  /// a settling, not an entrance from off the screen, and a long travel on a
  /// list of eight turns the whole block into something moving.
  final double distance;

  /// Fades each child in as it settles.
  final bool fade;

  @override
  Widget build(BuildContext context) {
    return nebaAnimate(
      this,
      effect: NebaEffect(
        keyframe: NebaKeyframe.slide,
        offset: nebaSlideStart(from, distance).offset,
        opacity: fade ? 0 : 1,
      ),
      eachChild: true,
    );
  }
}
