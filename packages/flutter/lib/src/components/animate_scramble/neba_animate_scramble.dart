/// `NebaAnimateScramble`, text arriving through noise, one character at a time.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/text.dart';
import 'package:neba/src/types.dart';

/// Text arriving through noise, one character at a time.
///
/// [NebaAnimateTyping]'s sibling: a typewriter reveals a line from an empty
/// one, this resolves it out of a line that was already the right length. The
/// box is laid out from the finished text, so nothing around it moves and a
/// heading does not push the page down as it lands. Each word's noise is drawn
/// over the word it settles into, so the line breaks where the finished line
/// breaks; a word's noise can be wider than the word for a moment and is cut
/// off at the word's end. Whitespace is never scrambled.
///
/// A screen reader is told the finished text once, and none of the noise. A
/// reader who asked for less motion is shown the text, before any trigger
/// too.
///
/// ```dart
/// NebaAnimateScramble(text: 'RESOLVING SIGNAL')
/// ```
class NebaAnimateScramble extends StatelessWidget {
  /// [text], settling out of noise at [speed] characters a second.
  const NebaAnimateScramble({
    required this.text,
    this.style,
    this.textAlign,
    this.speed = 18,
    this.tick = const Duration(milliseconds: 45),
    this.characters,
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

  /// The text to settle.
  final String text;

  /// The style the text is set in, over the [DefaultTextStyle] around it.
  final TextStyle? style;

  /// How the lines of the text are aligned.
  final TextAlign? textAlign;

  /// How fast the text settles, in characters per second. [duration] wins
  /// when it is given.
  final double speed;

  /// How often an unsettled character is redrawn. Below about 30
  /// milliseconds it stops reading as characters at all.
  final Duration tick;

  /// The pool an unsettled character is drawn from. Keep its glyphs one
  /// height, or the line jumps as it settles. Left out, capitals, digits and
  /// a few symbols.
  final String? characters;

  /// The whole run, when it is given: the delay between characters falls out
  /// of it.
  final Duration? duration;

  /// How long it waits before the first character settles. The noise is
  /// drawn throughout.
  final Duration delay;

  /// Whether it ends: `double.infinity` holds it off the screen and, under
  /// [NebaAnimateTrigger.hover], starts it over on the next hover.
  final num repeat;

  /// Holds it where it is, noise and all.
  final bool paused;

  /// What starts it. Until it starts, the noise stands still.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that scrambles it again each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  /// The pool [characters] falls back to: one height throughout, so the line
  /// does not jump as it settles.
  static const String defaultCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&\$@*';

  @override
  Widget build(BuildContext context) {
    final List<String> graphemes = nebaGraphemesOf(text);
    final String? characters = this.characters;
    final List<String> pool = nebaGraphemesOf(
      characters == null || characters.isEmpty ? defaultCharacters : characters,
    );
    final Duration? duration = this.duration;
    final int total = graphemes.length;
    final double wait = delay.inMicroseconds / 1000;
    final double step = duration != null && total > 0
        ? math.max(1, duration.inMicroseconds / 1000 / total)
        : 1000 / math.max(1, speed);
    final double every = math.max(1, tick.inMicroseconds / 1000);
    final double end = wait + total * step;

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: DefaultTextStyle.merge(
        style: style,
        textAlign: textAlign,
        child: NebaAnimateRun(
          // Over once the last character has settled, whatever `repeat` says:
          // an endless one is held off the screen and, on a hover, stopped
          // when the pointer leaves, so the next one scrambles it again.
          timing: NebaTiming(duration: end),
          endless: repeat.isInfinite,
          trigger: trigger,
          play: play,
          once: once,
          threshold: threshold,
          paused: paused,
          restart: text,
          builder: (BuildContext context, NebaRunSnapshot run) {
            return ValueListenableBuilder<double>(
              valueListenable: run.clock,
              builder: (BuildContext context, double elapsed, Widget? child) {
                // The clock stops at the end, where working back from it
                // can fall a hair short of the last character.
                final int settled = run.reduced || elapsed >= end
                    ? total
                    : math.min(total, math.max(0, ((elapsed - wait) / step).floor()));
                final List<_Word> words = _wordsOf(
                  graphemes,
                  settled: settled,
                  tick: (elapsed / every).floor(),
                  pool: pool,
                );

                return MediaQuery.withNoTextScaling(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        for (final _Word word in words) ...<InlineSpan>[
                          if (word.text.isNotEmpty)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: _ScrambledWord(word: word),
                            ),
                          if (word.gap.isNotEmpty) TextSpan(text: word.gap),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// One word of a scrambled line, as it shows on one tick.
class _Word {
  /// The finished word.
  final StringBuffer _text = StringBuffer();

  /// Its settled letters as themselves and the rest as noise.
  final StringBuffer _shown = StringBuffer();

  /// The whitespace after it, never scrambled.
  final StringBuffer _gap = StringBuffer();

  /// Whether every letter has settled, so the word is drawn as itself.
  bool settled = true;

  String get text => _text.toString();
  String get shown => _shown.toString();
  String get gap => _gap.toString();
}

/// [graphemes] as words, each with what it shows on [tick] when the first
/// [settled] of them have settled. A character of a script written without
/// spaces is a word of its own: a line may break inside a run of them, and
/// the noise over a word has to stay on one line.
List<_Word> _wordsOf(
  List<String> graphemes, {
  required int settled,
  required int tick,
  required List<String> pool,
}) {
  final List<_Word> words = <_Word>[];

  for (int index = 0; index < graphemes.length; index++) {
    final String grapheme = graphemes[index];
    final bool blank = grapheme.trim().isEmpty;
    final bool alone = !blank && nebaStandsAlone(grapheme);
    final bool afterAlone = index > 0 && nebaStandsAlone(graphemes[index - 1]);

    if (words.isEmpty || (!blank && (words.last._gap.isNotEmpty || alone || afterAlone))) {
      words.add(_Word());
    }

    final _Word word = words.last;

    if (blank) {
      word._gap.write(grapheme);
      continue;
    }

    final bool done = index < settled;

    word._text.write(grapheme);
    word._shown.write(done ? grapheme : pool[_noiseAt(tick, index, pool.length)]);
    word.settled = word.settled && done;
  }

  return words;
}

/// Which of [size] glyphs the unsettled character at [index] shows on
/// [tick]: a mix of the two numbers rather than a random one, so a build that
/// is not a tick draws exactly what was already there. The React package's
/// `glyphAt`, in 32-bit arithmetic on every platform, so both packages draw
/// the same noise.
int _noiseAt(int tick, int index, int size) {
  int mixed = _imul(tick + 1, 0x85ebca6b) ^ _imul(index + 1, 0xc2b2ae35);

  mixed ^= mixed >>> 15;
  mixed = _imul(mixed, 0x2545f491);
  mixed ^= mixed >>> 13;

  return mixed % size;
}

/// The low 32 bits of [a] times [b], unsigned: JavaScript's `Math.imul`,
/// worked in 16-bit halves so a product never leaves the 53 bits a number on
/// the web holds exactly.
int _imul(int a, int b) {
  final int aHigh = (a >>> 16) & 0xffff;
  final int aLow = a & 0xffff;
  final int bHigh = (b >>> 16) & 0xffff;
  final int bLow = b & 0xffff;
  final int cross = ((aHigh * bLow + aLow * bHigh) & 0xffff) << 16;

  return (aLow * bLow + cross) & 0xffffffff;
}

/// A word: itself once it has settled, and otherwise its noise drawn over it,
/// centred on its line and cut off at its end, with the word laid out unseen
/// underneath so it takes the finished word's room.
class _ScrambledWord extends StatelessWidget {
  const _ScrambledWord({required this.word});

  final _Word word;

  @override
  Widget build(BuildContext context) {
    final Widget finished = Text(word.text, softWrap: false);

    if (word.settled) {
      return finished;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: finished,
        ),
        Positioned.fill(
          child: ClipRect(
            // Across only: a clip down the page would cut the descenders off
            // a heading set solid.
            clipper: const _Across(),
            child: OverflowBox(
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: AlignmentDirectional.centerStart,
              child: Text(word.shown, softWrap: false),
            ),
          ),
        ),
      ],
    );
  }
}

/// The width of a box, and as far above and below it as anything drawn in
/// it could reach.
class _Across extends CustomClipper<Rect> {
  const _Across();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, -size.height, size.width, size.height * 2);

  @override
  bool shouldReclip(_Across oldClipper) => false;
}
