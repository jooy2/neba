/// `NebaAnimateCounter`, a number counted up to its value.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/format.dart';
import 'package:neba/src/types.dart';

/// A number counted up to its value.
///
/// The one effect whose subject is the content rather than the box around
/// it: a value interpolated and written out on every frame. It pairs with
/// `NebaStatistic`, whose `value` takes a widget for exactly this.
///
/// The count runs on a fixed ease-out, since a number may only ever approach
/// its value from one side, and keeps the decimal places of [value] or
/// [from], whichever has more, with every figure set at one width. The box
/// is as wide as the wider of the two ends from the first frame, so the words
/// after it stay where they are while it gains digits. Before it starts it
/// sits at [from]; once it has counted, a new [value] counts on from the
/// number on the screen.
///
/// A screen reader is told the answer once, and none of the count. A reader
/// who asked for less motion is shown the answer, before any trigger too.
///
/// ```dart
/// NebaStatistic(
///   label: Text('Monthly active'),
///   value: NebaAnimateCounter(value: 128400),
/// )
/// ```
class NebaAnimateCounter extends StatefulWidget {
  /// A count from [from] to [value] over [duration].
  const NebaAnimateCounter({
    required this.value,
    this.from = 0,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = Duration.zero,
    this.format,
    this.style,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    super.key,
  });

  /// Where it lands.
  final num value;

  /// Where the first count starts.
  final num from;

  /// How long the count takes.
  final Duration duration;

  /// How long the first count waits before it starts.
  final Duration delay;

  /// How the number is written. Left out, its thousands are grouped and it
  /// has at most three digits after the point, as the React package writes a
  /// number in English; a currency, a percentage or a compact `128K` is a
  /// function of your own. It is handed the number already rounded to the
  /// places the count keeps.
  final String Function(num value)? format;

  /// The style the number is set in, over the [DefaultTextStyle] around it.
  /// Its figures are tabular whatever it says.
  final TextStyle? style;

  /// What starts the count. Before it does, the number sits at [from].
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that counts it again from [from] each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it counts only the first
  /// time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  @override
  State<NebaAnimateCounter> createState() => _NebaAnimateCounterState();
}

class _NebaAnimateCounterState extends State<NebaAnimateCounter> {
  /// Where the count on the clock starts: [NebaAnimateCounter.from] for a
  /// run, or the number on the screen for a new value counted on from it.
  late num _origin = widget.from;

  /// How long the count on the clock waits: the delay for a run, nothing for
  /// a new value.
  late double _wait = _ms(widget.delay);

  /// The number on the screen, as of the last frame drawn.
  late num _onScreen = widget.from;

  /// Whether it has started counting since it was let go.
  bool _counted = false;

  /// The run the count belongs to.
  int _run = 0;

  /// Bumped to start the clock over for a count on from the screen.
  int _again = 0;

  static double _ms(Duration duration) => duration.inMicroseconds / 1000;

  @override
  void didUpdateWidget(NebaAnimateCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // A new figure counts on from wherever the last count had got to rather
    // than from `from`, with no delay: a live figure going from 100 to 105
    // would otherwise drop to nothing and climb back.
    if (_counted &&
        (oldWidget.value != widget.value ||
            oldWidget.from != widget.from ||
            oldWidget.duration != widget.duration)) {
      _origin = _onScreen;
      _wait = 0;
      _again += 1;
    }
  }

  /// How many digits after the point [value] is written with, read off the
  /// shortest string that stands for it: `0.1` is one and `1e-7` is seven.
  static int _decimalsOf(num value) {
    if (!value.isFinite || value == value.truncate()) {
      return 0;
    }

    final List<String> parts = value.abs().toString().split('e');
    final List<String> digits = parts.first.split('.');
    final int exponent = parts.length > 1 ? int.parse(parts[1]) : 0;
    final int places = (digits.length > 1 ? digits[1].length : 0) - exponent;

    return places.clamp(0, 20);
  }

  /// The ease-out the count runs on, which never passes its value: the house
  /// curve overshoots at the end, which on a number is a total going past
  /// itself and coming back.
  static double _easeOut(double t) => 1 - math.pow(1 - t, 3).toDouble();

  String _write(num value) => (widget.format ?? nebaFormatNumber)(value);

  /// The number at [elapsed] milliseconds into the count, for [run].
  num _at(NebaRunSnapshot run, double elapsed) {
    final double duration = _ms(widget.duration);

    if (run.reduced || duration <= 0) {
      return widget.value;
    }

    // The clock stops at the end, where working back from it can fall a
    // hair short of the value.
    final double t = elapsed >= _wait + duration
        ? 1
        : ((elapsed - _wait) / duration).clamp(0.0, 1.0);

    return _origin + (widget.value - _origin) * _easeOut(t);
  }

  /// Where the run has got to: a new run counts from `from` after the delay,
  /// and one that has not been let go waits at `from`.
  void _follow(NebaRunSnapshot run) {
    if (!run.started) {
      _counted = false;
      _origin = widget.from;
      _wait = _ms(widget.delay);
    } else if (!_counted || run.runs != _run) {
      _counted = true;
      _run = run.runs;
      _origin = widget.from;
      _wait = _ms(widget.delay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int places = math.max(_decimalsOf(widget.value), _decimalsOf(widget.from));
    final num scale = math.pow(10, places);
    final String answer = _write(widget.value);
    final String start = _write(widget.from);

    return Semantics(
      label: answer,
      excludeSemantics: true,
      child: DefaultTextStyle.merge(
        // Figures of one width, so the words beside the count stay where
        // they are while it runs.
        style: (widget.style ?? const TextStyle()).copyWith(
          fontFeatures: <FontFeature>[
            ...?widget.style?.fontFeatures,
            const FontFeature.tabularFigures(),
          ],
        ),
        child: NebaAnimateRun(
          // Long enough for a count that waits out the delay, which a count
          // on from the screen does not.
          timing: NebaTiming(duration: _ms(widget.delay) + _ms(widget.duration)),
          trigger: widget.trigger,
          play: widget.play,
          once: widget.once,
          threshold: widget.threshold,
          restart: _again,
          builder: (BuildContext context, NebaRunSnapshot run) {
            _follow(run);

            return ValueListenableBuilder<double>(
              valueListenable: run.clock,
              builder: (BuildContext context, double elapsed, Widget? child) {
                final num shown = run.started || run.reduced ? _at(run, elapsed) : widget.from;
                final String drawn = run.reduced ? answer : _write((shown * scale).round() / scale);

                _onScreen = shown;

                // The two ends, laid out under the count and drawn by nobody,
                // so the box is as wide as the wider of them from the first
                // frame. `from` is let go once the count has landed.
                final List<String> samples = drawn == answer || start == answer
                    ? <String>[answer]
                    : <String>[answer, start];

                return Stack(
                  children: <Widget>[
                    for (final String sample in samples)
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Text(sample, softWrap: false),
                      ),
                    Text(drawn, softWrap: false),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
