/// What every `Animate*` widget runs on, and what a widget's `transition`
/// plays: the React package's `src/internal/animate.tsx`.
///
/// An effect is a start state of its own and the widget as it is laid out,
/// and every one of them is drawn on the same tree: an opacity, a fractional
/// translation, a transform about an origin and a clip, each of which costs
/// nothing at rest. So the last frame of an arrival is the child as it was
/// handed over, and a frame never rebuilds what is inside it.
///
/// One clock runs it. A run counts the milliseconds since it was let go and
/// holds the count while it is held, and every pass of a repeat and every
/// child of a stagger reads its frame off that one count, as CSS reads every
/// animation off one timeline; an exit is the same count read backwards. A
/// `view` timeline swaps the count for how far the widget has come up
/// through the scroll view it is in.
///
/// The library talking to itself: only [NebaAnimateBase] is exported, by the
/// `Animate*` widgets that extend it.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/progress.dart';
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

/// [duration] in milliseconds, which is what the clock counts in.
double _ms(Duration duration) => duration.inMicroseconds / 1000;

/* ---------------------------------------------------------------------------
 * The shape of an effect
 * ------------------------------------------------------------------------- */

/// Which keyframe an effect runs, the React package's keyframe classes. A
/// grow and a zoom share [scale], as they share one `@keyframes`, and a float
/// and a shake have keyframes of their own that no `transition` can name.
enum NebaKeyframe {
  /// From [NebaEffect.opacity] to opaque.
  fade,

  /// From [NebaEffect.scale] and [NebaEffect.opacity] to the widget as it is.
  scale,

  /// From [NebaEffect.offset] or [NebaEffect.fraction] away, and
  /// [NebaEffect.opacity], to where it is laid out.
  slide,

  /// From [NebaEffect.angle] and [NebaEffect.opacity] to [NebaEffect.angleTo].
  rotate,

  /// Opaque, down to [NebaEffect.opacity] at the middle and opaque again.
  blink,

  /// Wiped in from [NebaEffect.side], from [NebaEffect.opacity].
  reveal,

  /// From where it is laid out to [NebaEffect.offset] or [NebaEffect.fraction]
  /// away.
  float,

  /// Across [NebaEffect.offset]'s width each way, twice, a little less the
  /// second time, ending where it began.
  shake,
}

/// What an effect looks like: its keyframe and where it starts, the React
/// package's `--n-anim-*` slots. Only the fields a keyframe reads mean
/// anything to it.
@immutable
class NebaEffect {
  /// The [keyframe], from the start state the other fields describe.
  const NebaEffect({
    required this.keyframe,
    this.opacity = 1,
    this.scale = 1,
    this.offset = Offset.zero,
    this.fraction = Offset.zero,
    this.angle = 0,
    this.angleTo = 0,
    this.side = NebaSide.left,
    this.origin = Alignment.center,
  });

  /// What [transition] plays, from the React package's start state for each
  /// effect: transparent for every one but a reveal.
  factory NebaEffect.of(NebaTransition transition) {
    switch (transition.type) {
      case NebaAnimation.fade:
        return const NebaEffect(keyframe: NebaKeyframe.fade, opacity: 0);
      case NebaAnimation.grow:
      case NebaAnimation.zoom:
        return NebaEffect(keyframe: NebaKeyframe.scale, opacity: 0, scale: transition.scale!);
      case NebaAnimation.slide:
        final ({Offset offset, Offset fraction}) start = nebaSlideStart(
          transition.from!,
          transition.distance,
        );

        return NebaEffect(
          keyframe: NebaKeyframe.slide,
          opacity: 0,
          offset: start.offset,
          fraction: start.fraction,
        );
      case NebaAnimation.rotate:
        return NebaEffect(keyframe: NebaKeyframe.rotate, opacity: 0, angle: transition.angle!);
      case NebaAnimation.blink:
        return const NebaEffect(keyframe: NebaKeyframe.blink, opacity: 0);
      case NebaAnimation.reveal:
        return NebaEffect(keyframe: NebaKeyframe.reveal, side: transition.side!);
    }
  }

  /// Which keyframe.
  final NebaKeyframe keyframe;

  /// The opacity it starts at; for a blink, the floor of the cycle.
  final double opacity;

  /// The scale it starts at, as a multiple of the size.
  final double scale;

  /// How far from where it is laid out it starts, in logical pixels; for a
  /// float, where the drift turns round; for a shake, how far the widest
  /// swing goes, along `dx`.
  final Offset offset;

  /// The same as [offset], as a fraction of the widget's own size.
  final Offset fraction;

  /// The angle it turns from, in degrees.
  final double angle;

  /// The angle it turns to, in degrees.
  final double angleTo;

  /// The edge a reveal is wiped from. Physical, so it does not flip under RTL.
  final NebaSide side;

  /// The point a scale and a turn are about.
  final AlignmentGeometry origin;

  /// Whether a held run rests on the widget as it is and starts over when it
  /// is let go, as a held blink does rather than stopping half drawn.
  bool get restsWhenHeld => keyframe == NebaKeyframe.blink;

  /// Whether its first frame is somewhere other than where the layout put it.
  bool get moves {
    return keyframe == NebaKeyframe.slide ||
        keyframe == NebaKeyframe.scale ||
        keyframe == NebaKeyframe.rotate;
  }

  @override
  bool operator ==(Object other) {
    return other is NebaEffect &&
        other.keyframe == keyframe &&
        other.opacity == opacity &&
        other.scale == scale &&
        other.offset == offset &&
        other.fraction == fraction &&
        other.angle == angle &&
        other.angleTo == angleTo &&
        other.side == side &&
        other.origin == origin;
  }

  @override
  int get hashCode {
    return Object.hash(keyframe, opacity, scale, offset, fraction, angle, angleTo, side, origin);
  }
}

/// Where something coming from [side] starts: [distance] logical pixels
/// away, or the widget's own size along that axis when [distance] is `null`.
///
/// Physical, as [NebaSide] is everywhere: something coming down from the top
/// comes from the top in every writing direction.
({Offset offset, Offset fraction}) nebaSlideStart(NebaSide side, double? distance) {
  final Offset edge = switch (side) {
    NebaSide.top => const Offset(0, -1),
    NebaSide.bottom => const Offset(0, 1),
    NebaSide.left => const Offset(-1, 0),
    NebaSide.right => const Offset(1, 0),
  };

  if (distance == null) {
    return (offset: Offset.zero, fraction: edge);
  }

  return (offset: edge * distance, fraction: Offset.zero);
}

/* ---------------------------------------------------------------------------
 * When it runs
 * ------------------------------------------------------------------------- */

/// When an effect runs, in milliseconds on the clock: CSS's animation timing,
/// with `fill-mode: both`, so it is held on its first frame before it starts
/// and on its last after it ends.
@immutable
class NebaTiming {
  /// [repeat] passes of [duration] each, after [delay], every other one
  /// backwards when [alternate], and the whole run backwards when [reversed].
  const NebaTiming({
    required this.duration,
    this.delay = 0,
    this.repeat = 1,
    this.alternate = false,
    this.reversed = false,
  });

  /// What [transition] asks for, with [delayOffset] and [durationOffset]
  /// added, which is how a pile staggers one effect across its items.
  factory NebaTiming.of(
    NebaTransition transition, {
    Duration delayOffset = Duration.zero,
    Duration durationOffset = Duration.zero,
  }) {
    return NebaTiming(
      duration: math.max(0, _ms(nebaTransitionDuration(transition) + durationOffset)),
      delay: _ms(transition.delay + delayOffset),
      repeat: math.max(0, nebaTransitionRepeat(transition)).toDouble(),
      alternate: transition.alternate,
    );
  }

  /// One pass. Never less than nothing.
  final double duration;

  /// How long the first frame is held before it starts.
  final double delay;

  /// How many passes; `double.infinity` runs it until the widget goes.
  final double repeat;

  /// Runs every other pass backwards.
  final bool alternate;

  /// Runs the whole of it backwards, which is what an exit is.
  final bool reversed;

  /// The same timing [order] steps down a stagger: [stagger] milliseconds
  /// later and [durationStep] longer for each step, never running for less
  /// than nothing.
  NebaTiming step(int order, {required double stagger, required double durationStep}) {
    return NebaTiming(
      duration: math.max(0, duration + order * durationStep),
      delay: delay + order * stagger,
      repeat: repeat,
      alternate: alternate,
      reversed: reversed,
    );
  }

  /// When it ends; never, for an endless one that takes any time at all.
  double get end {
    if (repeat.isInfinite && duration > 0) {
      return double.infinity;
    }

    return delay + duration * (repeat.isInfinite ? 0 : repeat);
  }

  /// Where along one pass the effect is [elapsed] milliseconds into the run,
  /// from 0 for the start state to 1 for the widget as it is: the iteration
  /// progress CSS works out, turned round on the passes that run backwards.
  double at(double elapsed) {
    final double active = elapsed - delay;

    if (active < 0 || repeat == 0) {
      return _directed(0, 0);
    }

    if (duration <= 0 || (!repeat.isInfinite && active >= duration * repeat)) {
      return last;
    }

    final double passes = active / duration;
    final int pass = passes.floor();

    return _directed(pass, passes - pass);
  }

  /// Where it is held once it has ended. The very end belongs to the last
  /// pass, at whatever part of it the count reaches, so a count of 1.5 ends
  /// half way through a pass, as CSS has it.
  double get last {
    if (repeat == 0) {
      return _directed(0, 0);
    }

    if (repeat.isInfinite) {
      return _directed(0, 1);
    }

    final int pass = repeat.ceil() - 1;

    return _directed(pass, repeat - pass);
  }

  /// The last frame of one pass: all a reader who asked for less motion is
  /// shown, as the stylesheet cuts every effect that runs to one pass of a
  /// millisecond.
  double get settled => _directed(0, 1);

  double _directed(int pass, double local) {
    final bool backwards = reversed != (alternate && pass.isOdd);

    return backwards ? 1 - local : local;
  }

  @override
  bool operator ==(Object other) {
    return other is NebaTiming &&
        other.duration == duration &&
        other.delay == delay &&
        other.repeat == repeat &&
        other.alternate == alternate &&
        other.reversed == reversed;
  }

  @override
  int get hashCode => Object.hash(duration, delay, repeat, alternate, reversed);
}

/* ---------------------------------------------------------------------------
 * Where it is on the screen
 * ------------------------------------------------------------------------- */

/// How much of [box] is left to see inside every clip above it and the
/// window, as a share of its area, and how much of it a window can show at
/// most: what an `IntersectionObserver` measures.
///
/// Measured on the box as the layout placed it, so an effect waiting on its
/// first frame a width away is measured where it is going to land. `null`
/// for a box that is not laid out.
({double shown, double room})? nebaShownShare(RenderBox box) {
  if (!box.attached || !box.hasSize) {
    return null;
  }

  Rect whole = Offset.zero & box.size;
  Rect left = whole;
  RenderObject child = box;
  RenderObject? parent = box.parent;

  while (parent != null && parent is! RenderView) {
    final Matrix4 transform = Matrix4.identity();
    parent.applyPaintTransform(child, transform);
    whole = MatrixUtils.transformRect(transform, whole);
    left = MatrixUtils.transformRect(transform, left);

    final Rect? clip = parent.describeApproximatePaintClip(child);

    if (clip != null) {
      left = left.intersect(clip);
    }

    if (left.width <= 0 || left.height <= 0) {
      return (shown: 0, room: 1);
    }

    child = parent;
    parent = parent.parent;
  }

  final Size window = parent is RenderView ? parent.size : Size.infinite;

  left = left.intersect(Offset.zero & window);

  final double area = whole.width * whole.height;
  final double shown = left.width <= 0 || left.height <= 0
      ? 0
      : area <= 0
      ? 1
      : (left.width * left.height / area).clamp(0.0, 1.0);
  final double room =
      math.min(1, window.width / math.max(1, box.size.width)) *
      math.min(1, window.height / math.max(1, box.size.height));

  return (shown: shown, room: room);
}

/// How far through [range] a widget [height] tall stands whose top is [top]
/// below the top of a view [extent] tall, from 0 to 1: CSS's `view()`
/// progress, held at either end outside the range.
double nebaViewProgress(
  NebaViewRange range, {
  required double top,
  required double height,
  required double extent,
}) {
  final bool fits = height <= extent;
  final double containStart = fits ? extent - height : 0;
  final double containEnd = fits ? 0 : extent - height;

  // Where the widget's top is at [fraction] of [phase]: each phase runs from
  // one such place to another, as the widget comes up the view.
  double topAt(NebaViewPhase phase, double fraction) {
    final (double from, double to) = switch (phase) {
      NebaViewPhase.cover => (extent, -height),
      NebaViewPhase.contain => (containStart, containEnd),
      NebaViewPhase.entry => (extent, containStart),
      NebaViewPhase.exit => (containEnd, -height),
      NebaViewPhase.entryCrossing => (extent, extent - height),
      NebaViewPhase.exitCrossing => (0, -height),
    };

    return from + (to - from) * fraction;
  }

  final double start = topAt(range.startPhase, range.start);
  final double end = topAt(range.endPhase, range.end);

  if (start == end) {
    return top <= start ? 1 : 0;
  }

  return ((start - top) / (start - end)).clamp(0.0, 1.0);
}

/* ---------------------------------------------------------------------------
 * The settings every Animate* takes
 * ------------------------------------------------------------------------- */

/// What every `Animate*` widget takes besides its own effect: how long it
/// runs and how often, what starts it, whether it is handed to each of its
/// children in turn, and whether the scroll position drives it instead of the
/// clock. The React package's `NebaAnimateProps`, `NebaStaggerProps` and
/// `NebaTimelineProps`, which mean the same thing on every one of them.
///
/// It wraps a [child], or lays out [children] with [layoutBuilder], in a
/// `Column` unless that says otherwise. The effect moves what is inside it
/// and never anything around it: every frame is a paint-time opacity,
/// translation, transform or clip of the widget as it is laid out, so nothing
/// on the page reflows while it runs, and the wrapper adds nothing a screen
/// reader hears.
///
/// A reader who asked the platform for less motion sees the last frame of
/// one pass at once, so content arriving is simply there and content leaving
/// is gone; an effect still waiting to start, or held, is drawn as it is, and
/// a float does not move at all.
abstract class NebaAnimateBase extends StatelessWidget {
  /// The settings, with React's defaults; [duration] is each effect's own.
  const NebaAnimateBase({
    required this.duration,
    this.delay = Duration.zero,
    this.curve,
    this.repeat = 1,
    this.alternate = false,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    this.stagger = Duration.zero,
    this.durationStep = Duration.zero,
    this.reverse = false,
    this.timeline = NebaAnimateTimeline.time,
    this.range = const NebaViewRange(),
    this.layoutBuilder,
    this.children,
    this.child,
    super.key,
  }) : assert(child == null || children == null, 'Pass a child or children, not both.'),
       assert(
         play == null || play is bool || play is num,
         'play is a bool, or a number that replays it each time it changes.',
       );

  /// How long one pass takes.
  final Duration duration;

  /// How long the first frame is held before it starts.
  final Duration delay;

  /// The easing. Left out, it is the house curve, `NebaScale.ease`.
  final Curve? curve;

  /// How many times it runs; `double.infinity` runs it until the widget goes.
  /// An endless one holds while it is off the screen and carries on when it
  /// is back.
  final num repeat;

  /// Runs every other pass backwards, so a repeat returns instead of jumping.
  final bool alternate;

  /// Holds it where it is.
  final bool paused;

  /// What starts it.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number. Each `false` to `true` starts it over, and so does a number that
  /// changes, so a count of failed attempts replays it on every failure
  /// without rebuilding what is inside it. `false`, `0` and `null` hold it.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  /// Off, it runs again every time it comes back into view.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of the widget has to be on
  /// screen before it counts as visible, from 0 to 1. For a widget larger
  /// than the window it is a share of the window instead: 0.2 is a fifth of
  /// the window filled by it.
  final double threshold;

  /// How long after one of [children] the next one starts. Zero animates the
  /// whole of them as one; anything above it moves the effect onto each child
  /// in turn.
  final Duration stagger;

  /// How much longer each successive one of [children] takes than the one
  /// before it. Negative speeds them up down the list, and none ever runs for
  /// less than nothing.
  final Duration durationStep;

  /// Runs [children] from the last to the first. Only the order reverses:
  /// each one still plays forwards.
  final bool reverse;

  /// What drives the progress: the clock, or how far the widget has come up
  /// through the scroll view it is in, which costs [duration], [delay],
  /// [repeat] and [trigger].
  final NebaAnimateTimeline timeline;

  /// The part of the widget's way through the scroll view a
  /// [NebaAnimateTimeline.view] effect is played over.
  final NebaViewRange range;

  /// Lays out [children]. Left out, they are a `Column` as wide as its
  /// widest child, each at the start.
  final Widget Function(List<Widget> children)? layoutBuilder;

  /// What arrives, as a list: each one is a step of a [stagger].
  final List<Widget>? children;

  /// What arrives.
  final Widget? child;
}

/// [settings]' run of [effect], backwards when [reversed], over [duration]
/// when it is not [NebaAnimateBase.duration], and on each of the children
/// even with no step when [eachChild]: the one way an `Animate*` widget
/// builds itself.
Widget nebaAnimate(
  NebaAnimateBase settings, {
  required NebaEffect effect,
  bool reversed = false,
  bool eachChild = false,
  Duration? duration,
}) {
  return NebaAnimateRun(
    effect: effect,
    timing: NebaTiming(
      duration: math.max(0, _ms(duration ?? settings.duration)),
      delay: _ms(settings.delay),
      repeat: math.max(0, settings.repeat).toDouble(),
      alternate: settings.alternate,
      reversed: reversed,
    ),
    curve: settings.curve,
    trigger: settings.trigger,
    play: settings.play,
    once: settings.once,
    threshold: settings.threshold,
    paused: settings.paused,
    stagger: _ms(settings.stagger),
    durationStep: _ms(settings.durationStep),
    reverse: settings.reverse,
    eachChild: eachChild,
    timeline: settings.timeline,
    range: settings.range,
    layoutBuilder: settings.layoutBuilder,
    children: settings.children,
    child: settings.child,
  );
}

/* ---------------------------------------------------------------------------
 * Running one
 * ------------------------------------------------------------------------- */

/// What a run hands a [NebaRunBuilder]: its clock, and where it stands.
@immutable
class NebaRunSnapshot {
  /// The run as it stands.
  const NebaRunSnapshot({
    required this.clock,
    required this.started,
    required this.running,
    required this.runs,
    required this.reduced,
  });

  /// Milliseconds since the run was let go, held while it is held and back
  /// to nothing when it is played again or restarted.
  final ValueListenable<double> clock;

  /// Whether it has been let go and not stopped since: the React package's
  /// `started`. Until it is, a widget draws what it waits on.
  final bool started;

  /// Whether the clock is moving: let go, not held, and not an endless one
  /// off the screen.
  final bool running;

  /// How many times it has been let go, which a replay counts up.
  final int runs;

  /// Whether the reader asked for less motion, so the widget draws where it
  /// ends, before any trigger too. A finite clock is already at its end.
  final bool reduced;
}

/// Draws a run's frames for a widget whose frame is not one effect on its
/// child: a typewriter counting characters, a count, a light going round.
/// It listens to [NebaRunSnapshot.clock] itself, so a tick rebuilds what
/// moves and nothing else.
typedef NebaRunBuilder = Widget Function(BuildContext context, NebaRunSnapshot run);

/// Plays [effect] on [child], or on [children] laid out by [layoutBuilder]
/// and, with a [stagger] or a [durationStep], on each of them in turn: an
/// `Animate*` widget's run, and a `transition`'s. With a [builder], the
/// builder draws every frame instead, from the same clock, trigger, hold and
/// screen.
///
/// [observes] is whether it watches where it is on the screen at all. An
/// `Animate*` does, to start on [NebaAnimateTrigger.visible] and to hold an
/// endless effect while it is off the screen; a `transition` runs on the
/// clock alone, as the React package's does.
class NebaAnimateRun extends StatefulWidget {
  /// [effect] on [timing], started by [trigger].
  const NebaAnimateRun({
    required this.timing,
    this.effect = const NebaEffect(keyframe: NebaKeyframe.fade),
    this.curve,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    this.paused = false,
    this.stagger = 0,
    this.durationStep = 0,
    this.reverse = false,
    this.eachChild = false,
    this.timeline = NebaAnimateTimeline.time,
    this.range = const NebaViewRange(),
    this.observes = true,
    this.restsUntilPlayed = false,
    this.endless,
    this.restart,
    this.builder,
    this.layoutBuilder,
    this.children,
    this.child,
    super.key,
  });

  /// What it looks like. Left out, nothing: a fade from fully drawn.
  final NebaEffect effect;

  /// When it runs, for the whole of it or for the first of [children].
  final NebaTiming timing;

  /// The easing; the house curve when it is `null`.
  final Curve? curve;

  /// See [NebaAnimateBase.trigger].
  final NebaAnimateTrigger trigger;

  /// See [NebaAnimateBase.play].
  final Object? play;

  /// See [NebaAnimateBase.once].
  final bool once;

  /// See [NebaAnimateBase.threshold].
  final double threshold;

  /// See [NebaAnimateBase.paused].
  final bool paused;

  /// Milliseconds of delay added per child.
  final double stagger;

  /// Milliseconds of duration added per child.
  final double durationStep;

  /// See [NebaAnimateBase.reverse].
  final bool reverse;

  /// Whether each of [children] runs the effect on its own even with no
  /// [stagger] or [durationStep], as a list that settles in does: a piece
  /// that grows grows about its own middle rather than the list's.
  final bool eachChild;

  /// See [NebaAnimateBase.timeline].
  final NebaAnimateTimeline timeline;

  /// See [NebaAnimateBase.range].
  final NebaViewRange range;

  /// Whether it watches where it is on the screen.
  final bool observes;

  /// Whether it is drawn as it is, rather than on its first frame, until it
  /// first runs: for content that arrives with the page and is only played
  /// again later.
  final bool restsUntilPlayed;

  /// Whether it counts as endless: held while it is off the screen, and
  /// stopped when the pointer leaves under [NebaAnimateTrigger.hover]. Left
  /// out, it is whether [timing] repeats forever; a widget whose clock ends
  /// but whose `repeat` says forever passes it.
  final bool? endless;

  /// A value whose change starts the clock over from nothing, without it
  /// counting as another run: for content that changed under a run already
  /// going, as a typewriter handed a new line types it from the start.
  final Object? restart;

  /// Draws every frame, in place of [effect] on [child] or [children].
  final NebaRunBuilder? builder;

  /// See [NebaAnimateBase.layoutBuilder].
  final Widget Function(List<Widget> children)? layoutBuilder;

  /// See [NebaAnimateBase.children].
  final List<Widget>? children;

  /// See [NebaAnimateBase.child].
  final Widget? child;

  @override
  State<NebaAnimateRun> createState() => _NebaAnimateRunState();
}

/// Whether [play] says go: `true`, or a number other than zero.
bool _playing(Object? play) => play == true || (play is num && play != 0 && !play.isNaN);

class _NebaAnimateRunState extends State<NebaAnimateRun> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);

  /// Milliseconds since the run was let go, held while it is held.
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);

  /// What the clock read when the ticker last started.
  double _base = 0;

  /// Whether the run has reached its end. A finished run stays finished when
  /// its timing changes, as a finished entrance does not play again because
  /// its duration did.
  bool _finished = false;

  /// Whether it has been let go: the React package's `started`.
  bool _started = false;

  /// How many times it has been let go.
  int _runs = 0;

  /// Whether it has run since it was built, so a start is a replay that
  /// rewinds rather than a first start that only lets it go.
  bool _ran = false;

  /// An endless effect that is off the screen, held until it comes back.
  bool _offscreen = false;

  /// Whether a [NebaAnimateTrigger.visible] effect counted as visible when it
  /// was last measured.
  bool _inView = false;

  /// A `once` effect that has been seen, which no longer needs watching.
  bool _seen = false;

  bool _reduced = false;
  bool _settled = false;
  bool _scheduled = false;
  List<ScrollableState> _scrollables = const <ScrollableState>[];
  List<ScrollPosition> _positions = const <ScrollPosition>[];

  bool get _infinite => widget.endless ?? widget.timing.repeat.isInfinite;

  bool get _spread {
    return widget.children != null &&
        (widget.eachChild || widget.stagger != 0 || widget.durationStep != 0);
  }

  /// The timing of each piece: one for the whole, or one per child.
  List<NebaTiming> get _timings {
    final List<Widget>? children = widget.children;

    if (!_spread || children == null) {
      return <NebaTiming>[widget.timing];
    }

    final int count = children.length;

    return <NebaTiming>[
      for (int index = 0; index < count; index++)
        widget.timing.step(
          widget.reverse ? count - 1 - index : index,
          stagger: widget.stagger,
          durationStep: widget.durationStep,
        ),
    ];
  }

  double get _end {
    double end = 0;

    for (final NebaTiming timing in _timings) {
      end = math.max(end, timing.end);
    }

    return end;
  }

  bool get _viewDriven => widget.timeline == NebaAnimateTimeline.view && !_reduced;

  /// Whether it is running: let go, not held, and not an endless one off the
  /// screen. A scroll-driven one has no clock to hold, so it always is.
  bool get _running {
    if (widget.timeline == NebaAnimateTimeline.view) {
      return true;
    }

    return _started && !widget.paused && !(_infinite && _offscreen);
  }

  /// An entrance that moves, waiting for [NebaAnimateTrigger.visible], drawn
  /// unseen where the layout put it until it first starts, as the React
  /// package's `data-waiting` holds it: what the reader sees of the entrance
  /// is the same, and the semantics and the focus find it where it will land.
  bool get _waiting {
    return !_reduced &&
        widget.trigger == NebaAnimateTrigger.visible &&
        widget.timeline == NebaAnimateTimeline.time &&
        !_spread &&
        !widget.timing.reversed &&
        widget.effect.moves &&
        !_started &&
        _runs == 0;
  }

  @override
  void initState() {
    super.initState();

    _started = widget.trigger == NebaAnimateTrigger.mount;

    if (widget.trigger == NebaAnimateTrigger.manual && _playing(widget.play)) {
      _started = true;
      _runs = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _reduced = nebaReducedMotion(context);

    if (widget.observes) {
      // Both axes, so a strip scrolled sideways inside a page scrolled down
      // is measured against both. A window resize measures again.
      _scrollables = <ScrollableState>{
        ?Scrollable.maybeOf(context, axis: Axis.vertical),
        ?Scrollable.maybeOf(context, axis: Axis.horizontal),
      }.toList();
      MediaQuery.maybeSizeOf(context);
    }

    _settled = true;
    _follow();
    _sync();
    _later();
  }

  @override
  void didUpdateWidget(NebaAnimateRun oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new keyframe starts over, as a new animation name does in CSS. A new
    // duration on the same one does not, and a finished run stays finished.
    if (oldWidget.effect.keyframe != widget.effect.keyframe ||
        oldWidget.restart != widget.restart) {
      _rewind();
    }

    if (widget.trigger == NebaAnimateTrigger.manual &&
        (oldWidget.trigger != NebaAnimateTrigger.manual || oldWidget.play != widget.play)) {
      if (_playing(widget.play)) {
        _start();
      } else {
        _stop();
      }
    }

    if (oldWidget.trigger != widget.trigger ||
        oldWidget.once != widget.once ||
        oldWidget.threshold != widget.threshold) {
      _seen = false;
      _inView = false;
    }

    _follow();
    _sync();
    _later();
  }

  @override
  void dispose() {
    for (final ScrollPosition position in _positions) {
      position.removeListener(_later);
    }

    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final double now = _base + elapsed.inMicroseconds / 1000;
    final double end = _end;

    if (now >= end) {
      _finished = true;
      _ticker.stop();
      _clock.value = end;
    } else {
      _clock.value = now;
    }
  }

  /// Back to the first frame, held there.
  void _rewind() {
    if (_ticker.isActive) {
      _ticker.stop();
    }

    _finished = false;
    _clock.value = 0;
  }

  /// Lets it go, from the beginning if it has run before.
  void _start() {
    final bool replay = _ran;

    _started = true;
    _runs += 1;

    if (replay) {
      _rewind();
    }

    _sync();
  }

  /// Holds it where it is.
  void _stop() {
    _started = false;
    _sync();
  }

  /// Runs the clock exactly while the run is running.
  void _sync() {
    if (!_settled) {
      return;
    }

    final bool running = _running;

    if (running) {
      _ran = true;
    }

    if (!running && widget.effect.restsWhenHeld && !_reduced) {
      _rewind();
    }

    if (_viewDriven || _reduced) {
      if (_ticker.isActive) {
        _ticker.stop();
      }

      // Cut to its end, as the stylesheet cuts it to a millisecond: a run
      // that has been let go under less motion is over.
      if (_reduced && running && !_infinite) {
        _finished = true;
        _clock.value = _end;
      }

      return;
    }

    if (running && !_finished) {
      if (!_ticker.isActive) {
        _base = _clock.value;
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  /// Listens to the scroll views around it while there is something to
  /// watch for.
  void _follow() {
    final bool watching =
        widget.observes &&
        widget.timeline == NebaAnimateTimeline.time &&
        ((widget.trigger == NebaAnimateTrigger.visible && !_seen) || _infinite);
    final List<ScrollPosition> next = watching
        ? <ScrollPosition>[
            for (final ScrollableState scrollable in _scrollables) scrollable.position,
          ]
        : const <ScrollPosition>[];

    if (listEquals(next, _positions)) {
      return;
    }

    for (final ScrollPosition position in _positions) {
      position.removeListener(_later);
    }

    for (final ScrollPosition position in next) {
      position.addListener(_later);
    }

    _positions = next;
  }

  /// Measures where it is after the frame, once, however many scrolls asked:
  /// it is measured where it was laid out.
  void _later() {
    if (_scheduled || !widget.observes) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _scheduled = false;

      if (mounted) {
        _measure();
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _measure() {
    final bool watchesTrigger =
        widget.trigger == NebaAnimateTrigger.visible &&
        widget.timeline == NebaAnimateTimeline.time &&
        !_seen;
    final bool watchesScreen = _infinite && widget.timeline == NebaAnimateTimeline.time;

    if (!watchesTrigger && !watchesScreen) {
      return;
    }

    final RenderObject? box = context.findRenderObject();
    final ({double shown, double room})? share = box is RenderBox ? nebaShownShare(box) : null;

    if (share == null) {
      return;
    }

    bool changed = false;

    if (watchesTrigger) {
      final double threshold = widget.threshold.isNaN ? 0 : widget.threshold.clamp(0.0, 1.0);
      // A share of something taller than the window may be more than the
      // window can show, so it is scaled to what the window can hold.
      final double watched = share.room < 1
          ? (threshold * share.room * 100).floorToDouble() / 100
          : threshold;
      final bool visible = watched <= 0 ? share.shown > 0 : share.shown >= watched;

      if (visible != _inView) {
        _inView = visible;
        changed = true;

        if (visible) {
          _start();
          _seen = widget.once;
        } else if (!widget.once) {
          _stop();
        }
      }
    }

    if (watchesScreen) {
      final bool offscreen = share.shown <= 0;

      if (offscreen != _offscreen) {
        _offscreen = offscreen;
        changed = true;
        _sync();
      }
    }

    if (changed) {
      setState(() {});
      _follow();
    }
  }

  void _enter() {
    setState(_start);
  }

  void _leave() {
    // A finite effect finishes; an endless one stops where it is.
    if (_infinite) {
      setState(_stop);
    }
  }

  /// The frame [timing] is at, or `null` for the widget as it is.
  double? _progress(NebaTiming timing) {
    final bool running = _running;

    if (_reduced) {
      // A float has no last frame, so it simply does not move; anything held
      // or still waiting is drawn as it is, never on an unseen first frame.
      if (widget.effect.keyframe == NebaKeyframe.float || !running) {
        return null;
      }

      return timing.settled;
    }

    if (!running && (widget.effect.restsWhenHeld || (widget.restsUntilPlayed && _runs == 0))) {
      return null;
    }

    return _finished ? timing.last : timing.at(_clock.value);
  }

  Widget _piece(Widget child, NebaTiming timing) {
    final Curve curve = widget.curve ?? NebaScale.ease;

    if (_viewDriven) {
      return _NebaViewDriven(
        effect: widget.effect,
        curve: curve,
        reversed: timing.reversed,
        range: widget.range,
        child: child,
      );
    }

    return ListenableBuilder(
      listenable: _clock,
      child: child,
      builder: (BuildContext context, Widget? child) {
        return _NebaFrame(
          effect: widget.effect,
          curve: curve,
          progress: _progress(timing),
          hidden: _waiting,
          child: child!,
        );
      },
    );
  }

  static Widget _column(List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget>? children = widget.children;
    final Widget Function(List<Widget> children) layout = widget.layoutBuilder ?? _column;
    final NebaRunBuilder? builder = widget.builder;
    final Widget content;

    if (builder != null) {
      content = builder(
        context,
        NebaRunSnapshot(
          clock: _clock,
          started: _started,
          running: _running,
          runs: _runs,
          reduced: _reduced,
        ),
      );
    } else if (children == null) {
      content = _piece(widget.child ?? const SizedBox.shrink(), widget.timing);
    } else if (_spread) {
      final List<NebaTiming> timings = _timings;

      content = layout(<Widget>[
        for (int index = 0; index < children.length; index++)
          KeyedSubtree(
            // The child's own key, one level up, so reordering the list moves
            // a child rather than rebuilding it.
            key: children[index].key == null ? null : ValueKey<Key>(children[index].key!),
            child: _piece(children[index], timings[index]),
          ),
      ]);
    } else {
      content = _piece(layout(children), widget.timing);
    }

    if (widget.trigger != NebaAnimateTrigger.hover) {
      return content;
    }

    // The focus counts as the pointer, or an effect on something the keyboard
    // reaches would never run without a mouse; it counts once, when it
    // arrives from outside, and not again as it moves between things inside.
    // A finger counts on a touch screen, where there is no hover, as a
    // browser sends a pointer entering on a touch.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (bool focused) => focused ? _enter() : _leave(),
      child: MouseRegion(
        opaque: false,
        onEnter: (PointerEnterEvent event) => _enter(),
        onExit: (PointerExitEvent event) => _leave(),
        child: Listener(
          // Anywhere on its box, as the browser's pointer entering is.
          behavior: HitTestBehavior.translucent,
          onPointerDown: (PointerDownEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              _enter();
            }
          },
          onPointerUp: (PointerUpEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              _leave();
            }
          },
          onPointerCancel: (PointerCancelEvent event) {
            if (event.kind == PointerDeviceKind.touch) {
              _leave();
            }
          },
          child: content,
        ),
      ),
    );
  }
}

/// One piece of a [NebaAnimateTimeline.view] effect, whose progress is how
/// far it has come up through the nearest scroll view that scrolls down the
/// page, or the window when there is none.
///
/// Measured after layout, and moved by the scroll offset in between, so a
/// frame keeps up with the scroll rather than trailing it by one. Until it
/// has been measured it is drawn as it is.
class _NebaViewDriven extends StatefulWidget {
  const _NebaViewDriven({
    required this.effect,
    required this.curve,
    required this.reversed,
    required this.range,
    required this.child,
  });

  final NebaEffect effect;
  final Curve curve;
  final bool reversed;
  final NebaViewRange range;
  final Widget child;

  @override
  State<_NebaViewDriven> createState() => _NebaViewDrivenState();
}

class _NebaViewDrivenState extends State<_NebaViewDriven> {
  ScrollableState? _scrollable;
  ScrollPosition? _position;
  double? _progress;
  bool _scheduled = false;

  // Where it was when it was last measured.
  bool _measured = false;
  double _top = 0;
  double _pixels = 0;
  double _height = 0;
  double _extent = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
    MediaQuery.maybeSizeOf(context);

    final ScrollPosition? position = _scrollable?.position;

    if (position != _position) {
      _position?.removeListener(_scrolled);
      _position = position?..addListener(_scrolled);
    }

    _later();
  }

  @override
  void didUpdateWidget(_NebaViewDriven oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.range != widget.range || oldWidget.reversed != widget.reversed) {
      _later();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_scrolled);
    super.dispose();
  }

  void _scrolled() {
    final ScrollPosition? position = _position;
    final ScrollableState? scrollable = _scrollable;

    if (_measured && position != null && scrollable != null) {
      final double sign = axisDirectionIsReversed(scrollable.axisDirection) ? -1 : 1;
      final double top = _top - (position.pixels - _pixels) * sign;

      // Never during a build or a layout; the measure after the frame catches
      // up instead.
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        _show(top);
      }
    }

    _later();
  }

  void _later() {
    if (_scheduled) {
      return;
    }

    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _scheduled = false;

      if (mounted) {
        _measure();
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _measure() {
    final RenderObject? box = context.findRenderObject();

    if (box is! RenderBox || !box.hasSize || !box.attached) {
      return;
    }

    final RenderObject? port = _scrollable?.context.findRenderObject();
    final double top;
    final double extent;

    if (port is RenderBox && port.hasSize) {
      top = box.localToGlobal(Offset.zero, ancestor: port).dy;
      extent = port.size.height;
    } else {
      top = box.localToGlobal(Offset.zero).dy;
      extent = MediaQuery.maybeSizeOf(context)?.height ?? box.size.height;
    }

    _measured = true;
    _top = top;
    _pixels = _position?.pixels ?? 0;
    _height = box.size.height;
    _extent = extent;
    _show(top);
  }

  void _show(double top) {
    final double progress = nebaViewProgress(
      widget.range,
      top: top,
      height: _height,
      extent: _extent,
    );
    final double directed = widget.reversed ? 1 - progress : progress;

    if (directed != _progress) {
      setState(() => _progress = directed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _NebaFrame(
      effect: widget.effect,
      curve: widget.curve,
      progress: _progress,
      hidden: false,
      child: widget.child,
    );
  }
}

/// Plays [transition] on [child] once, when it is first built: a widget's
/// `transition`. It plays again from the start each time [trigger] changes.
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

  /// What arrives.
  final Widget child;

  @override
  State<NebaEntrance> createState() => _NebaEntranceState();
}

class _NebaEntranceState extends State<NebaEntrance> {
  /// How many times it has been let go, which a manual run replays on.
  late int _plays = widget.playsOnBuild ? 1 : 0;

  @override
  void didUpdateWidget(NebaEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.trigger != widget.trigger) {
      _plays += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NebaTransition transition = widget.transition;

    return NebaAnimateRun(
      effect: NebaEffect.of(transition),
      timing: NebaTiming.of(
        transition,
        delayOffset: widget.delayOffset,
        durationOffset: widget.durationOffset,
      ),
      curve: transition.curve,
      trigger: NebaAnimateTrigger.manual,
      play: _plays,
      restsUntilPlayed: !widget.playsOnBuild,
      observes: false,
      child: widget.child,
    );
  }
}

/// One frame of [effect], at [progress] along it, from 0 for the start state
/// to 1 for the end, or the child as it is when [progress] is `null`;
/// unseen in place when [hidden].
class _NebaFrame extends StatelessWidget {
  const _NebaFrame({
    required this.effect,
    required this.curve,
    required this.progress,
    required this.hidden,
    required this.child,
  });

  final NebaEffect effect;
  final Curve curve;
  final double? progress;
  final bool hidden;
  final Widget child;

  /// The shake's stops and where each one is, as a share of its width.
  static const List<double> _shakeStops = <double>[0, 0.2, 0.4, 0.6, 0.8, 1];
  static const List<double> _shakeAt = <double>[0, -1, 1, -0.55, 0.55, 0];

  @override
  Widget build(BuildContext context) {
    double opacity = 1;
    Offset fraction = Offset.zero;
    Offset shift = Offset.zero;
    double scale = 1;
    double turn = 0;
    double? shown;

    final double? at = progress;

    if (hidden) {
      opacity = 0;
    } else if (at != null) {
      final double p = at.clamp(0.0, 1.0);

      switch (effect.keyframe) {
        case NebaKeyframe.fade:
        case NebaKeyframe.scale:
        case NebaKeyframe.slide:
        case NebaKeyframe.rotate:
        case NebaKeyframe.reveal:
          final double eased = curve.transform(p);
          final double rest = 1 - eased;

          opacity = effect.opacity + (1 - effect.opacity) * eased;

          if (effect.keyframe == NebaKeyframe.scale) {
            scale = effect.scale + (1 - effect.scale) * eased;
          } else if (effect.keyframe == NebaKeyframe.slide) {
            fraction = effect.fraction * rest;
            shift = effect.offset * rest;
          } else if (effect.keyframe == NebaKeyframe.rotate) {
            turn = (effect.angle + (effect.angleTo - effect.angle) * eased) * math.pi / 180;
          } else if (effect.keyframe == NebaKeyframe.reveal) {
            shown = eased;
          }
        case NebaKeyframe.blink:
          // Full, down to the floor at the middle and full again, with the
          // curve on each half as CSS lays a timing function on each interval
          // between two keyframes.
          final ({int span, double t}) half = progressKeyframe(p, const <double>[
            0,
            0.5,
            1,
          ], curve: curve);
          opacity = half.span == 0
              ? 1 + (effect.opacity - 1) * half.t
              : effect.opacity + (1 - effect.opacity) * half.t;
        case NebaKeyframe.float:
          final double eased = curve.transform(p);

          fraction = effect.fraction * eased;
          shift = effect.offset * eased;
        case NebaKeyframe.shake:
          final ({int span, double t}) swing = progressKeyframe(p, _shakeStops, curve: curve);
          final double from = _shakeAt[swing.span];
          final double to = _shakeAt[swing.span + 1];

          shift = Offset((from + (to - from) * swing.t) * effect.offset.dx, 0);
      }
    }

    final Matrix4 transform = Matrix4.identity()
      ..translateByDouble(shift.dx, shift.dy, 0, 1)
      ..rotateZ(turn)
      ..scaleByDouble(scale, scale, 1, 1);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      // Content on its way in is still content: a screen reader finds it on
      // the first frame, as it finds an element at `opacity: 0`.
      alwaysIncludeSemantics: true,
      child: FractionalTranslation(
        translation: fraction,
        child: Transform(
          transform: transform,
          alignment: effect.origin,
          child: ClipRect(
            clipper: shown == null ? null : _RevealClipper(side: effect.side, shown: shown),
            clipBehavior: shown == null ? Clip.none : Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
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
