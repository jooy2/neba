/// `NebaAnimateTyping`, text appearing one character at a time.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/text.dart';
import 'package:neba/src/types.dart';

/// Text appearing one character at a time.
///
/// A screen reader is told the whole line once, from the first frame, and
/// none of the typing. The box is laid out from the whole line, with room for
/// the caret at its end, so the text around it never moves while it types.
///
/// [repeat], [hold] and [erase] make it a loop: type, hold, delete, type
/// again. Without [erase] a repeat clears in one frame, which is right for a
/// line being replaced rather than rewritten. Characters are counted as a
/// reader counts them, so a Hangul syllable typed as three jamo and a family
/// emoji of five code points each arrive in one step. A reader
/// who asked for less motion sees the line whole, with a caret that does not
/// blink.
///
/// ```dart
/// NebaAnimateTyping(text: 'Ship the interface, not the design system.', speed: 18)
/// ```
class NebaAnimateTyping extends StatelessWidget {
  /// [text], typed at [speed] characters a second.
  const NebaAnimateTyping({
    required this.text,
    this.style,
    this.textAlign,
    this.speed = 24,
    this.hold = const Duration(milliseconds: 1400),
    this.erase = false,
    this.eraseSpeed,
    this.caret = true,
    this.caretChar,
    this.duration,
    this.delay = Duration.zero,
    this.repeat = 1,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    super.key,
  });

  /// The text to type.
  final String text;

  /// The style the text is set in, over the [DefaultTextStyle] around it.
  final TextStyle? style;

  /// How the lines of the text are aligned.
  final TextAlign? textAlign;

  /// How fast it is typed, in characters per second. A speed rather than a
  /// duration, so a long line and a short one are typed at the same pace.
  final double speed;

  /// How long the finished text is held before it repeats.
  final Duration hold;

  /// Deletes the text a character at a time before repeating, rather than
  /// clearing it in one frame. Only means anything with a [repeat] above one.
  final bool erase;

  /// How fast it is deleted, in characters per second. Left out, twice
  /// [speed], which is what a person does.
  final double? eraseSpeed;

  /// The caret after the text.
  final bool caret;

  /// What the caret is drawn as. Left out, a `|` in the text's own style.
  final Widget? caretChar;

  /// The time for the whole line, when it is given; [speed] otherwise.
  final Duration? duration;

  /// How long it waits before the first character.
  final Duration delay;

  /// How many passes it makes; `double.infinity` types it until the widget
  /// goes, and holds while it is off the screen.
  final num repeat;

  /// Holds the typing where it is. The caret is not held.
  final bool paused;

  /// What starts it. Until it starts, nothing is typed.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that types it again each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  /// The blink of the caret: on for 550 milliseconds in every second, cut
  /// rather than faded, since a caret that eases looks slow to draw.
  static const Duration caretPeriod = Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    final List<String> graphemes = nebaGraphemesOf(text);
    final _Typing typing = _Typing(
      total: graphemes.length,
      type: duration != null && graphemes.isNotEmpty
          ? duration!.inMicroseconds / 1000 / graphemes.length
          : 1000 / math.max(speed, 1),
      erase: erase ? 1000 / math.max(eraseSpeed ?? speed * 2, 1) : null,
      hold: hold.inMicroseconds / 1000,
      delay: delay.inMicroseconds / 1000,
      passes: repeat.isInfinite ? double.infinity : math.max(1, repeat).toDouble(),
    );
    final Widget? mark = caret ? caretChar ?? const Text('|') : null;

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: DefaultTextStyle.merge(
        style: style,
        textAlign: textAlign,
        child: NebaAnimateRun(
          // The clock runs to the end of the last pass, or forever.
          timing: NebaTiming(
            duration: typing.end.isFinite ? typing.end : 1,
            repeat: typing.end.isFinite ? 1 : double.infinity,
          ),
          trigger: trigger,
          play: play,
          once: once,
          threshold: threshold,
          paused: paused,
          // A new line is typed from its start.
          restart: text,
          builder: (BuildContext context, NebaRunSnapshot run) {
            return _Overlaid(
              // The finished line, laid out and never drawn, so the box is
              // the size of what it will be from the first frame.
              finished: Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _Line(text: text, caret: mark),
              ),
              typed: ValueListenableBuilder<double>(
                valueListenable: run.clock,
                builder: (BuildContext context, double elapsed, Widget? child) {
                  // Waiting is empty rather than finished, and less motion
                  // is the line itself.
                  final int shown = run.reduced
                      ? graphemes.length
                      : run.started
                      ? typing.shownAt(elapsed)
                      : 0;

                  return _Line(
                    text: graphemes.take(shown).join(),
                    caret: mark == null ? null : _Caret(child: mark),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The finished line and the typed one drawn over it. The typed one is laid
/// out under the constraints the finished one was, so it breaks where that
/// does, and at least as wide, so it is aligned within the same box; laid
/// out at exactly the finished width, the last character of a line could
/// break onto a line of its own.
class _Overlaid extends MultiChildRenderObjectWidget {
  _Overlaid({required Widget finished, required Widget typed})
    : super(children: <Widget>[finished, typed]);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderOverlaid();
}

class _OverlaidParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderOverlaid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverlaidParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverlaidParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverlaidParentData) {
      child.parentData = _OverlaidParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) => firstChild!.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) => firstChild!.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => firstChild!.getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => firstChild!.getMaxIntrinsicHeight(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return firstChild!.getDistanceToActualBaseline(baseline);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(firstChild!.getDryLayout(constraints));
  }

  @override
  void performLayout() {
    final RenderBox finished = firstChild!;
    final RenderBox typed = childAfter(finished)!;

    finished.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(finished.size);
    typed.layout(
      BoxConstraints(
        minWidth: math.min(finished.size.width, constraints.maxWidth),
        maxWidth: constraints.maxWidth,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// A line and the caret after it, inline at its end.
class _Line extends StatelessWidget {
  const _Line({required this.text, required this.caret});

  final String text;
  final Widget? caret;

  @override
  Widget build(BuildContext context) {
    final Widget? caret = this.caret;

    return Text.rich(
      TextSpan(
        text: text,
        children: <InlineSpan>[
          if (caret != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: MediaQuery.withNoTextScaling(child: caret),
            ),
        ],
      ),
    );
  }
}

/// The caret, on for 550 milliseconds of every second for as long as it is
/// built, and on throughout for a reader who asked for less motion.
class _Caret extends StatelessWidget {
  const _Caret({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NebaAnimateRun(
      timing: NebaTiming(
        duration: NebaAnimateTyping.caretPeriod.inMicroseconds / 1000,
        repeat: double.infinity,
      ),
      builder: (BuildContext context, NebaRunSnapshot run) {
        return ValueListenableBuilder<double>(
          valueListenable: run.clock,
          child: child,
          builder: (BuildContext context, double elapsed, Widget? child) {
            final double period = NebaAnimateTyping.caretPeriod.inMicroseconds / 1000;
            final bool on = run.reduced || (elapsed % period) / period < 0.55;

            return Opacity(opacity: on ? 1 : 0, child: child);
          },
        );
      },
    );
  }
}

/// Where a typewriter is at any moment, worked out from the time alone: the
/// first character at the delay and one more every [type] milliseconds, the
/// line held for [hold], then deleted one every [erase] milliseconds or
/// cleared at once, and the next pass typed after one more step.
@immutable
class _Typing {
  const _Typing({
    required this.total,
    required this.type,
    required this.erase,
    required this.hold,
    required this.delay,
    required this.passes,
  });

  final int total;
  final double type;
  final double? erase;
  final double hold;
  final double delay;
  final double passes;

  /// When the last character of a pass lands, from its first.
  double get _typed => (total - 1) * type;

  /// From the first character of one pass to the first of the next.
  double get _cycle => total * type + hold + (erase == null ? 0 : (total - 1) * erase!);

  /// When the last pass has typed its last character; never, for an endless
  /// one.
  double get end {
    if (total == 0) {
      return 0;
    }

    return passes.isInfinite ? double.infinity : delay + (passes - 1) * _cycle + _typed;
  }

  /// How many characters are showing [elapsed] milliseconds in.
  int shownAt(double elapsed) {
    if (total == 0 || elapsed < delay) {
      return 0;
    }

    // The clock stops at the end, where working back from it can fall a hair
    // short of the last character.
    if (elapsed >= end) {
      return total;
    }

    final double since = elapsed - delay;
    double pass = (since / _cycle).floorToDouble();

    if (pass > passes - 1) {
      pass = passes - 1;
    }

    final double local = since - pass * _cycle;

    if (local < _typed) {
      return (local / type).floor() + 1;
    }

    // The last pass, or the hold after a pass.
    if (pass >= passes - 1 || local - _typed < hold) {
      return total;
    }

    final double? erase = this.erase;

    if (erase == null) {
      return 0;
    }

    return math.max(0, total - ((local - _typed - hold) / erase).floor() - 1);
  }
}
