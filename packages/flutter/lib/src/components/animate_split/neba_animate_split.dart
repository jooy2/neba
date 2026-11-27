/// `NebaAnimateSplit`, a line of text arriving a word, or a letter, at a time.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/animate.dart';
import 'package:neba/src/internal/text.dart';
import 'package:neba/src/types.dart';

/// What one piece of a [NebaAnimateSplit] is.
enum NebaSplitBy {
  /// A word, with the punctuation after it.
  word,

  /// A character, as a reader counts them: an accented letter typed as two
  /// code points is one, and so is a family emoji of five.
  character,
}

/// A line of text arriving a word, or a letter, at a time.
///
/// [NebaAnimateAppear] walks down a list a child at a time; this walks along
/// a sentence, each piece arriving on one of the library's own effects, held
/// back by its place in the line. The pieces are laid out inline in one
/// paragraph, with the spaces between them as text, so the line breaks where
/// the text would and never inside a word: split by character, the letters of
/// a word are kept together.
///
/// A screen reader is told the line once, and none of the pieces. A reader
/// who asked for less motion sees the line whole.
///
/// ```dart
/// NebaAnimateSplit(
///   text: 'A line arriving a word at a time',
///   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
/// )
/// ```
class NebaAnimateSplit extends StatelessWidget {
  /// [text], cut [by] words or characters, each piece arriving on [effect].
  const NebaAnimateSplit({
    required this.text,
    this.style,
    this.textAlign,
    this.by = NebaSplitBy.word,
    this.effect = NebaAnimation.slide,
    this.from = NebaSide.bottom,
    this.distance,
    this.scale,
    this.angle,
    this.side,
    this.duration = const Duration(milliseconds: 520),
    this.delay = Duration.zero,
    this.curve,
    this.repeat,
    this.alternate = false,
    this.paused = false,
    this.trigger = NebaAnimateTrigger.mount,
    this.play,
    this.once = true,
    this.threshold = 0.2,
    this.stagger = const Duration(milliseconds: 45),
    this.durationStep = Duration.zero,
    this.reverse = false,
    this.timeline = NebaAnimateTimeline.time,
    this.range = const NebaViewRange(),
    super.key,
  });

  /// The text to split.
  final String text;

  /// The style the text is set in, over the [DefaultTextStyle] around it.
  final TextStyle? style;

  /// How the lines of the text are aligned.
  final TextAlign? textAlign;

  /// What one piece is. A word is the one to reach for: a heading of eight
  /// words is eight pieces, and the same heading by character is forty-six.
  final NebaSplitBy by;

  /// Which effect each piece arrives on, from the library's own vocabulary,
  /// so a split heading's fade and a `NebaAnimateFade` are the same fade.
  final NebaAnimation effect;

  /// Which edge a [NebaAnimation.slide] piece comes from.
  final NebaSide from;

  /// How far a [NebaAnimation.slide] piece travels, in logical pixels. Left
  /// out, it is four tenths of the font size.
  final double? distance;

  /// Where a [NebaAnimation.grow] or [NebaAnimation.zoom] piece starts, as a
  /// multiple of its size: 0.8 for a grow and 0.4 for a zoom unless it says.
  final double? scale;

  /// How far a [NebaAnimation.rotate] piece turns from, in degrees; -180
  /// unless it says.
  final double? angle;

  /// Which edge a [NebaAnimation.reveal] piece is wiped from; the left
  /// unless it says.
  final NebaSide? side;

  /// How long one piece takes.
  final Duration duration;

  /// How long the first piece waits before it starts.
  final Duration delay;

  /// The easing. Left out, it is the house curve, `NebaScale.ease`.
  final Curve? curve;

  /// How many times each piece runs; `double.infinity` runs it until the
  /// widget goes. Left out, it is once, and forever for a blink.
  final num? repeat;

  /// Runs every other pass backwards.
  final bool alternate;

  /// Holds it where it is.
  final bool paused;

  /// What starts it.
  final NebaAnimateTrigger trigger;

  /// Runs it, when [trigger] is [NebaAnimateTrigger.manual]: a `bool`, or a
  /// number that replays it each time it changes.
  final Object? play;

  /// With [NebaAnimateTrigger.visible], whether it runs only the first time.
  final bool once;

  /// With [NebaAnimateTrigger.visible], how much of it has to be on screen.
  final double threshold;

  /// How long after one piece the next one starts. What the effect is made
  /// of; at zero every piece still arrives on its own.
  final Duration stagger;

  /// How much longer each successive piece takes than the one before it.
  final Duration durationStep;

  /// Runs the line from its last piece to its first.
  final bool reverse;

  /// What drives the progress: the clock, or how far the line has come up
  /// through the scroll view it is in.
  final NebaAnimateTimeline timeline;

  /// The part of the line's way through the scroll view a
  /// [NebaAnimateTimeline.view] effect is played over.
  final NebaViewRange range;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolved = DefaultTextStyle.of(context).style.merge(style);
    final NebaTransition transition = _transition(resolved.fontSize ?? 14);
    final List<_Group> groups = _groups();
    final List<String> pieces = <String>[for (final _Group group in groups) ...group.letters];

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: DefaultTextStyle.merge(
        style: style,
        child: NebaAnimateRun(
          effect: NebaEffect.of(transition),
          timing: NebaTiming.of(transition),
          curve: curve,
          trigger: trigger,
          play: play,
          once: once,
          threshold: threshold,
          paused: paused,
          stagger: stagger.inMicroseconds / 1000,
          durationStep: durationStep.inMicroseconds / 1000,
          reverse: reverse,
          eachChild: true,
          timeline: timeline,
          range: range,
          layoutBuilder: (List<Widget> animated) {
            return _line(animated, groups, resolved);
          },
          children: <Widget>[
            for (final String piece in pieces)
              // The paragraph around the pieces already scales them by the
              // reader's text size, as it scales every widget inline in it.
              Text(piece, softWrap: false, textScaler: TextScaler.noScaling),
          ],
        ),
      ),
    );
  }

  /// The words of [text], each with its letters and the whitespace after it:
  /// one letter, the whole word, when it is cut by word.
  List<_Group> _groups() {
    final RegExp trailing = RegExp(r'\s*$');

    return <_Group>[
      for (final String word in nebaWordsOf(text))
        _Group.of(word, trailing.firstMatch(word)?.group(0) ?? '', by),
    ];
  }

  /// The pieces in a paragraph of their own, each word a widget inline in it
  /// on the line's baseline and the whitespace between them text, so the
  /// line breaks where the text would.
  Widget _line(List<Widget> animated, List<_Group> groups, TextStyle resolved) {
    final List<InlineSpan> spans = <InlineSpan>[];
    int at = 0;

    for (final _Group group in groups) {
      final int count = group.letters.length;

      if (count > 0) {
        final List<Widget> letters = animated.sublist(at, at + count);

        at += count;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: count == 1
                ? letters.first
                // The letters of one word on one line: a paragraph may break
                // between any two widgets inline in it.
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: letters,
                  ),
          ),
        );
      }

      if (group.gap.isNotEmpty) {
        spans.add(TextSpan(text: group.gap));
      }
    }

    // The style the pieces are set in, so the paragraph scales them by the
    // reader's text size at the size they are drawn at.
    return Text.rich(
      TextSpan(style: resolved, children: spans),
      textAlign: textAlign,
    );
  }

  NebaTransition _transition(double fontSize) {
    switch (effect) {
      case NebaAnimation.fade:
        return NebaTransition.fade(
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.grow:
        return NebaTransition.grow(
          scale: scale ?? 0.8,
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.zoom:
        return NebaTransition.zoom(
          scale: scale ?? 0.4,
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.slide:
        return NebaTransition.slide(
          from: from,
          distance: distance ?? 0.4 * fontSize,
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.rotate:
        return NebaTransition.rotate(
          angle: angle ?? -180,
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.blink:
        return NebaTransition.blink(
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
      case NebaAnimation.reveal:
        return NebaTransition.reveal(
          side: side ?? NebaSide.left,
          duration: duration,
          delay: delay,
          curve: curve,
          repeat: repeat,
          alternate: alternate,
        );
    }
  }
}

/// One word of the line: the pieces it is drawn as and the whitespace after
/// it, which stays text so the line can break there.
class _Group {
  const _Group(this.letters, this.gap);

  factory _Group.of(String word, String gap, NebaSplitBy by) {
    final String stem = word.substring(0, math.max(0, word.length - gap.length));

    if (stem.isEmpty) {
      return _Group(const <String>[], gap);
    }

    return _Group(by == NebaSplitBy.word ? <String>[stem] : nebaGraphemesOf(stem), gap);
  }

  final List<String> letters;
  final String gap;
}
