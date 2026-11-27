/// What a widget's `transition` plays: the React package's
/// `src/internal/animate.tsx`, for the effects it shares with the `Animate*`
/// components.
///
/// Every effect runs from a start state of its own to the widget as it is
/// laid out, and the tree it builds is the same for all seven: an opacity, a
/// fractional translation, a transform and a clip, each of which costs nothing
/// at rest. So the last frame is the child as it was handed over, and changing
/// the effect on a rebuild never rebuilds what is inside it.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/types.dart';

/// How long each effect takes when nobody said, the React package's
/// `defaultDurations`. They differ because the effects do not travel the same
/// distance, and a blink's is a period rather than an arrival.
const Map<NebaAnimation, Duration> nebaAnimationDurations = <NebaAnimation, Duration>{
  NebaAnimation.fade: Duration(milliseconds: 320),
  NebaAnimation.grow: Duration(milliseconds: 340),
  NebaAnimation.slide: Duration(milliseconds: 380),
  NebaAnimation.zoom: Duration(milliseconds: 340),
  NebaAnimation.rotate: Duration(milliseconds: 460),
  NebaAnimation.blink: Duration(milliseconds: 900),
  NebaAnimation.reveal: Duration(milliseconds: 620),
};

/// The shortest one blink may take: more than three flashes a second is what
/// WCAG 2.3.1 rules out.
const Duration nebaMinBlinkDuration = Duration(milliseconds: 334);

/// The duration [transition] runs for, before any step is added to it.
Duration nebaTransitionDuration(NebaTransition transition) {
  final Duration duration = transition.duration ?? nebaAnimationDurations[transition.type]!;

  if (transition.type == NebaAnimation.blink && duration < nebaMinBlinkDuration) {
    return nebaMinBlinkDuration;
  }

  return duration;
}

/// How many times [transition] runs: once, or forever for a blink, unless it
/// says.
num nebaTransitionRepeat(NebaTransition transition) {
  return transition.repeat ?? (transition.type == NebaAnimation.blink ? double.infinity : 1);
}

/// Plays [transition] on [child] once, when it is first built, and again
/// from the start each time [trigger] changes.
///
/// [delayOffset] and [durationOffset] are added to the transition's own, which
/// is how a pile staggers one effect across its items. A duration never goes
/// below zero however far the offsets run.
class NebaEntrance extends StatefulWidget {
  /// [child], arriving by [transition].
  const NebaEntrance({
    required this.transition,
    required this.child,
    this.delayOffset = Duration.zero,
    this.durationOffset = Duration.zero,
    this.trigger,
    this.playsOnBuild = true,
    super.key,
  });

  /// The effect.
  final NebaTransition transition;

  /// Added to the transition's delay.
  final Duration delayOffset;

  /// Added to the transition's duration.
  final Duration durationOffset;

  /// What arrives.
  final Widget child;

  /// A value whose change plays the transition again from its start, as
  /// putting an animation back on an element does in CSS. [child] stays built
  /// through it, so a step of a guide that is arrived at again keeps what was
  /// typed into it.
  final Object? trigger;

  /// Whether the transition plays when the widget is first built. Off, the
  /// child starts at rest and only a change of [trigger] plays it: for
  /// content that arrives with the page and should be there in its first
  /// paint.
  final bool playsOnBuild;

  @override
  State<NebaEntrance> createState() => _NebaEntranceState();
}

class _NebaEntranceState extends State<NebaEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _wait;
  bool _reduced = false;
  bool _settled = false;

  /// One pass, never less than nothing.
  Duration get _period {
    final Duration duration = nebaTransitionDuration(widget.transition) + widget.durationOffset;

    return duration < Duration.zero ? Duration.zero : duration;
  }

  num get _repeat {
    final num repeat = nebaTransitionRepeat(widget.transition);

    return repeat < 0 ? 0 : repeat;
  }

  bool get _forever => _repeat == double.infinity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool reduced = nebaReducedMotion(context);

    if (!_settled) {
      _settled = true;
      _reduced = reduced;

      if (widget.playsOnBuild) {
        _start();
      } else {
        _controller.value = 1;
      }
    } else if (reduced != _reduced) {
      _reduced = reduced;
      _start();
    }
  }

  @override
  void didUpdateWidget(NebaEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new effect starts over, as a new animation name does in CSS, and so
    // does a new trigger. A new duration on the same effect does not, and a
    // finished entrance stays finished.
    if (oldWidget.transition.type != widget.transition.type ||
        oldWidget.trigger != widget.trigger) {
      _start();
    }
  }

  @override
  void dispose() {
    _wait?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    _wait?.cancel();
    _wait = null;
    _controller.stop();

    // A reader who asked for less motion is shown the last frame of one run
    // at once: an entrance that does not play has still delivered its content.
    if (_reduced) {
      _controller.value = 1;
      return;
    }

    // Held on the first frame until it starts, as `fill-mode: both` holds it.
    _controller.value = 0;

    final Duration delay = widget.transition.delay + widget.delayOffset;

    if (delay > Duration.zero) {
      _wait = Timer(delay, _run);
    } else {
      _run();
    }
  }

  void _run() {
    _wait = null;

    final Duration period = _period;

    if (_forever) {
      // One controller pass is one pass of the effect, and `reverse` is
      // exactly `alternate`.
      if (period == Duration.zero) {
        _controller.value = 1;
      } else {
        _controller.repeat(reverse: widget.transition.alternate, period: period);
      }

      return;
    }

    // Every pass on one clock, so the next one starts on the frame the last
    // one ends rather than a frame later, and a count of 1.5 is half a pass
    // more as CSS has it.
    _controller.duration = period * _repeat;
    _controller.forward(from: 0);
  }

  /// Where along one pass the effect is, from the controller's place on the
  /// whole run: the iteration progress CSS works out, turned around on every
  /// other pass when it alternates.
  double get _progress {
    final double value = _controller.value;

    if (_reduced) {
      return 1;
    }

    if (_forever) {
      return value;
    }

    final double repeat = _repeat.toDouble();

    if (repeat == 0) {
      return 0;
    }

    final double elapsed = value * repeat;
    // The very end belongs to the last pass, at whatever part of it the count
    // reaches, rather than to the start of a pass that never runs.
    final int pass = value >= 1 ? (repeat.ceil() - 1) : elapsed.floor();
    final double local = elapsed - pass;

    return widget.transition.alternate && pass.isOdd ? 1 - local : local;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTransition transition = widget.transition;
    final Curve curve = transition.curve ?? NebaScale.ease;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        return _NebaFrame(transition: transition, progress: _progress, curve: curve, child: child!);
      },
    );
  }
}

/// One frame of an effect, at [progress] along it, from 0 for the start state
/// to 1 for the widget as it is laid out.
class _NebaFrame extends StatelessWidget {
  const _NebaFrame({
    required this.transition,
    required this.progress,
    required this.curve,
    required this.child,
  });

  final NebaTransition transition;
  final double progress;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NebaAnimation type = transition.type;
    final double eased = curve.transform(progress.clamp(0, 1).toDouble());
    final double rest = 1 - eased;

    double opacity = eased;
    Offset fraction = Offset.zero;
    Offset shift = Offset.zero;
    double scale = 1;
    double turn = 0;
    NebaSide? wipe;

    switch (type) {
      case NebaAnimation.fade:
        break;
      case NebaAnimation.grow:
      case NebaAnimation.zoom:
        scale = 1 - (1 - transition.scale!) * rest;
      case NebaAnimation.slide:
        final Offset edge = _edge(transition.from!);
        final double? distance = transition.distance;

        if (distance == null) {
          fraction = edge * rest;
        } else {
          shift = edge * distance * rest;
        }
      case NebaAnimation.rotate:
        turn = transition.angle! * math.pi / 180 * rest;
      case NebaAnimation.blink:
        // Full, faint at the middle and full again, with the curve on each
        // half as CSS lays a timing function on each keyframe interval.
        final double half = progress.clamp(0, 1).toDouble() * 2;
        opacity = half <= 1 ? 1 - curve.transform(half) : curve.transform(half - 1);
      case NebaAnimation.reveal:
        opacity = 1;
        wipe = transition.side;
    }

    final Matrix4 transform = Matrix4.identity()
      ..translateByDouble(shift.dx, shift.dy, 0, 1)
      ..rotateZ(turn)
      ..scaleByDouble(scale, scale, 1, 1);

    return Opacity(
      opacity: opacity.clamp(0, 1).toDouble(),
      // Content on its way in is still content: a screen reader finds it on
      // the first frame, as it finds an element at `opacity: 0`.
      alwaysIncludeSemantics: true,
      child: FractionalTranslation(
        translation: fraction,
        child: Transform(
          transform: transform,
          alignment: Alignment.center,
          child: ClipRect(
            clipper: wipe == null ? null : _RevealClipper(side: wipe, shown: eased),
            clipBehavior: wipe == null ? Clip.none : Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
  }

  /// Which way a slide starts from [side], as a fraction of the widget.
  static Offset _edge(NebaSide side) {
    switch (side) {
      case NebaSide.top:
        return const Offset(0, -1);
      case NebaSide.bottom:
        return const Offset(0, 1);
      case NebaSide.left:
        return const Offset(-1, 0);
      case NebaSide.right:
        return const Offset(1, 0);
    }
  }
}

/// The part of a revealed widget that is showing: [shown] of it, measured from
/// [side].
class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper({required this.side, required this.shown});

  final NebaSide side;
  final double shown;

  @override
  Rect getClip(Size size) {
    switch (side) {
      case NebaSide.left:
        return Rect.fromLTWH(0, 0, size.width * shown, size.height);
      case NebaSide.right:
        return Rect.fromLTRB(size.width * (1 - shown), 0, size.width, size.height);
      case NebaSide.top:
        return Rect.fromLTWH(0, 0, size.width, size.height * shown);
      case NebaSide.bottom:
        return Rect.fromLTRB(0, size.height * (1 - shown), size.width, size.height);
    }
  }

  @override
  bool shouldReclip(_RevealClipper oldClipper) {
    return oldClipper.side != side || oldClipper.shown != shown;
  }
}
