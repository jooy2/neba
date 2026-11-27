/// `NebaAnimateHeadline`, one line replacing the one above it, on a timer.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/types.dart';

/// One line replacing the one above it, on a timer.
///
/// Every one of [children] is laid out in the same place, so the box is as
/// tall and as wide as the largest of them from the first frame and never
/// resizes as the reel turns; the ones not showing keep their room unseen. A
/// line comes up, stops, and is held for [interval], counted from when it
/// arrives, so raising [duration] does not eat the reading time.
///
/// Use it for a set of phrases any one of which would have done. Only the
/// line that is showing is in the semantics tree, and nothing is announced
/// when the reel turns, so it is not for content a reader has to see. Pass
/// [index] to turn it yourself, from a step in a form or a tab. Under reduced
/// motion the reel stops turning on its own, and a line that changes arrives
/// in place.
///
/// ```dart
/// NebaAnimateHeadline(
///   children: <Widget>[Text('faster'), Text('quieter'), Text('yours')],
/// )
/// ```
class NebaAnimateHeadline extends StatelessWidget {
  /// [children], one at a time, each held for [interval].
  const NebaAnimateHeadline({
    required this.children,
    this.interval = const Duration(milliseconds: 2600),
    this.index,
    this.defaultIndex = 0,
    this.onIndexChange,
    this.loop = true,
    this.rise,
    this.duration = const Duration(milliseconds: 480),
    this.delay = Duration.zero,
    this.curve,
    this.repeat = double.infinity,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    super.key,
  });

  /// The lines, in the order they should be read.
  final List<Widget> children;

  /// How long each line is held before the next one comes up, counted from
  /// the moment it arrives.
  final Duration interval;

  /// Which line is showing. Pass it to turn the reel yourself; it then never
  /// turns on its own.
  final int? index;

  /// Where a reel with no [index] starts.
  final int defaultIndex;

  /// Called with the line that has just come up.
  final ValueChanged<int>? onIndexChange;

  /// Starts again after the last line. Off, the reel stops on the last one.
  final bool loop;

  /// How far a line travels as it comes up or leaves, in logical pixels.
  /// Left out, one line's own height.
  final double? rise;

  /// How long a line takes to come up, and the one before it to leave.
  final Duration duration;

  /// How long it waits before the reel first turns.
  final Duration delay;

  /// The easing. Left out, it is the house curve, `NebaScale.ease`.
  final Curve? curve;

  /// Not how many times the reel turns, which is [loop], but whether it
  /// ends: `double.infinity` holds it while it is off the screen and, under
  /// [NebaAnimateTrigger.hover], stops it when the pointer leaves.
  final num repeat;

  /// Holds the reel on the line it is showing. A page whose reel keeps
  /// turning needs a way to stop it; bind a pause button to this.
  final bool paused;

  /// What starts the reel turning.
  final NebaAnimateTrigger trigger;

  /// Turns it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or
  /// a number.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it starts only the first
  /// time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  @override
  Widget build(BuildContext context) {
    // The run says only whether the reel may turn, so it takes no time at
    // all; the lines arrive on runs of their own, which play however the
    // reel stands, as a line handed a new index has to.
    return NebaAnimateRun(
      timing: const NebaTiming(duration: 0),
      endless: repeat.isInfinite,
      trigger: trigger,
      play: play,
      once: once,
      threshold: threshold,
      paused: paused,
      builder: (BuildContext context, NebaRunSnapshot run) {
        return _Reel(settings: this, turning: run.running, reduced: run.reduced);
      },
    );
  }
}

class _Reel extends StatefulWidget {
  const _Reel({required this.settings, required this.turning, required this.reduced});

  final NebaAnimateHeadline settings;
  final bool turning;
  final bool reduced;

  @override
  State<_Reel> createState() => _ReelState();
}

class _ReelState extends State<_Reel> {
  late int _uncontrolled = widget.settings.defaultIndex;

  /// The line on its way out, until its run has had its time.
  int? _leaving;

  /// How many times each line has come up or left, which its run replays on.
  final Map<int, int> _plays = <int, int>{};

  /// Whether the reel has turned on its own yet: the delay is waited once.
  bool _turned = false;

  late int _active = _activeOf(widget);

  Timer? _turn;
  Timer? _clear;

  int _activeOf(_Reel reel) {
    final int count = reel.settings.children.length;

    return math.max(0, math.min(reel.settings.index ?? _uncontrolled, count - 1));
  }

  @override
  void initState() {
    super.initState();

    // The first line comes up as the reel is built.
    _plays[_active] = 1;
    _schedule();
  }

  @override
  void didUpdateWidget(_Reel oldWidget) {
    super.didUpdateWidget(oldWidget);

    _moveTo(_activeOf(widget));

    final NebaAnimateHeadline settings = widget.settings;
    final NebaAnimateHeadline old = oldWidget.settings;

    if (widget.turning != oldWidget.turning ||
        widget.reduced != oldWidget.reduced ||
        (settings.index == null) != (old.index == null) ||
        settings.children.length != old.children.length ||
        settings.duration != old.duration ||
        settings.interval != old.interval ||
        settings.delay != old.delay ||
        settings.loop != old.loop) {
      _schedule();
    }
  }

  @override
  void dispose() {
    _turn?.cancel();
    _clear?.cancel();
    super.dispose();
  }

  /// Brings [next] up and sends the line before it off, both on their runs.
  void _moveTo(int next) {
    if (next == _active) {
      return;
    }

    final int previous = _active;

    _active = next;
    _leaving = previous;
    _plays[next] = (_plays[next] ?? 0) + 1;
    _plays[previous] = (_plays[previous] ?? 0) + 1;
    _clear?.cancel();
    _clear = Timer(widget.settings.duration, () {
      if (mounted) {
        setState(() => _leaving = null);
      }
    });
    _schedule();
  }

  /// Turns the reel after the line on it has arrived and been read, when it
  /// turns on its own at all.
  void _schedule() {
    _turn?.cancel();
    _turn = null;

    final NebaAnimateHeadline settings = widget.settings;
    final int count = settings.children.length;

    // A reel that changes every few seconds is still motion to a reader who
    // asked for less of it, and it never ends.
    if (settings.index != null || count < 2 || !widget.turning || widget.reduced) {
      return;
    }

    if (!settings.loop && _active == count - 1) {
      return;
    }

    _turn = Timer(
      settings.duration + settings.interval + (_turned ? Duration.zero : settings.delay),
      () {
        if (!mounted) {
          return;
        }

        _turned = true;

        final int next = _active + 1 >= count ? 0 : _active + 1;

        if (widget.settings.index == null) {
          setState(() {
            _uncontrolled = next;
            _moveTo(next);
          });
        }

        widget.settings.onIndexChange?.call(next);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NebaAnimateHeadline settings = widget.settings;
    final double? rise = settings.rise;
    final double ms = settings.duration.inMicroseconds / 1000;

    NebaEffect from(double sign) {
      return NebaEffect(
        keyframe: NebaKeyframe.slide,
        opacity: 0,
        offset: rise == null ? Offset.zero : Offset(0, sign * rise),
        fraction: rise == null ? Offset(0, sign) : Offset.zero,
      );
    }

    return ClipRect(
      child: Stack(
        children: <Widget>[
          for (int position = 0; position < settings.children.length; position++)
            _line(position, settings, comes: from(1), goes: from(-1), ms: ms),
        ],
      ),
    );
  }

  Widget _line(
    int position,
    NebaAnimateHeadline settings, {
    required NebaEffect comes,
    required NebaEffect goes,
    required double ms,
  }) {
    final bool active = position == _active;
    final bool leaving = position == _leaving && !widget.reduced;
    final Widget line = NebaAnimateRun(
      // Up from below, or up and away: the same slide, run forwards to come
      // and backwards from the other side to go, held where it ends.
      effect: leaving ? goes : comes,
      timing: NebaTiming(duration: ms, reversed: leaving),
      curve: settings.curve,
      trigger: NebaAnimateTrigger.manual,
      play: _plays[position] ?? 0,
      restsUntilPlayed: true,
      observes: false,
      child: settings.children[position],
    );

    return Visibility(
      key: ValueKey<int>(position),
      visible: active || leaving,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      // Only the line that is showing is read.
      child: ExcludeSemantics(excluding: !active, child: line),
    );
  }
}
