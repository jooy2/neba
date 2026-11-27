/// `NebaStreamingText`, text arriving from somewhere else.
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/motion.dart';
import 'package:neba/src/internal/text_marks.dart';
import 'package:neba/src/theme/scale.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Text arriving from somewhere else.
///
/// An animated typewriter types out a string it already has. This is the
/// other direction: the string is handed over a piece at a time, nobody knows
/// how long it will be, and the widget's job is to make it land without the
/// page moving under whoever is reading it. Three things do that. The block
/// holds a floor of [lines] before anything has arrived, and keeps holding it
/// afterwards. A caret says the text is not finished. And each word fades in
/// on its own as it lands, rather than the block as a whole, which would play
/// the entire answer again on every token.
///
/// A plain [Text] as [child] is what this is for: what arrives while it
/// streams is cut into words, and a word already on screen never fades
/// again. Text that was there before a stream started, or that replaces it
/// while nothing streams, is drawn as it is, and so is a word once its fade
/// is over. Any other widget is drawn untouched, with the caret and the floor
/// still around it.
///
/// It is deliberately not a live region: an answer that announced itself on
/// every token would be unusable. Announcing a finished answer is the app's
/// decision.
///
/// ```dart
/// NebaStreamingText(streaming: streaming, lines: 4, child: Text(answer))
/// ```
class NebaStreamingText extends StatefulWidget {
  /// [child], arriving.
  const NebaStreamingText({
    this.streaming = false,
    this.cursor,
    this.showCursor = true,
    this.fade = true,
    this.lines = 1,
    this.color,
    this.child,
    super.key,
  }) : assert(lines >= 0);

  /// Whether more is still coming. It draws the caret; it does not change
  /// what is already there.
  final bool streaming;

  /// What stands at the end while the stream runs, in place of the blinking
  /// block: a spinner, a set of dots, a word.
  final Widget? cursor;

  /// Whether anything stands at the end at all; `false` drops it, React's
  /// `cursor={false}`.
  final bool showCursor;

  /// Fades each word in as it arrives. Off, the text is drawn as it comes.
  final bool fade;

  /// How many lines of height to hold before anything has arrived, so the
  /// page does not jump when the first word lands. A floor, kept once the
  /// text is there.
  final int lines;

  /// The caret's family. Defaults to [NebaColor.primary].
  final NebaColor? color;

  /// The text so far: a [Text], or any other widget, drawn as it is.
  final Widget? child;

  @override
  State<NebaStreamingText> createState() => _NebaStreamingTextState();
}

/// Scripts written without a space between words, cut a character at a time
/// rather than kept as one word per paragraph.
final RegExp _unspaced = RegExp(
  r'[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Thai}'
  r'\p{Script=Lao}\p{Script=Khmer}\p{Script=Myanmar}]',
  unicode: true,
);

final RegExp _space = RegExp(r'\s');

/// One token of a text: a word, or the whitespace after it, from [start] to
/// [end].
typedef _Token = ({int start, int end, bool space});

/// [text] from [from] cut into words and the whitespace between them, each
/// character of a script without spaces a word of its own. The pieces add
/// back up to the text.
List<_Token> _tokenize(String text, int from) {
  final List<_Token> tokens = <_Token>[];
  int start = from;

  bool spaceAt(int at) => _space.hasMatch(text[at]);

  while (start < text.length) {
    final bool space = spaceAt(start);
    int end = start;

    if (!space && _unspaced.hasMatch(text[start])) {
      end = start + 1;
    } else {
      while (end < text.length &&
          spaceAt(end) == space &&
          (space || !_unspaced.hasMatch(text[end]))) {
        end += 1;
      }
    }

    tokens.add((start: start, end: end, space: space));
    start = end;
  }

  return tokens;
}

class _NebaStreamingTextState extends State<NebaStreamingText> with TickerProviderStateMixin {
  /// How much of the text is drawn plain: what was there before the stream,
  /// and every word whose fade is over.
  int _plain = 0;

  /// When each word still fading arrived, by where it starts, on [_clock].
  final Map<int, Duration> _born = <int, Duration>{};

  /// What the last build drew.
  String _shown = '';

  /// Whether a stream has run since the block was last drawn all plain: text
  /// that goes on from what was shown fades in only then, and is drawn as it
  /// is when nothing has streamed.
  bool _streamed = false;

  late final Ticker _ticker = createTicker(_tick);
  Duration _clock = Duration.zero;
  Duration _fadeTime = NebaScale.duration;

  AnimationController? _blink;

  String? get _text {
    final Widget? child = widget.child;

    return child is Text ? child.data ?? child.textSpan?.toPlainText() : null;
  }

  @override
  void initState() {
    super.initState();

    final String text = _text ?? '';

    // Text the block is first built with is plain unless it arrives
    // streaming, when it is arriving now.
    _plain = widget.streaming && widget.fade ? 0 : text.length;
    _shown = text;
    _streamed = widget.streaming;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fadeTime = nebaDuration(context, NebaScale.duration);

    if (widget.streaming && widget.fade && _plain < _shown.length) {
      _arrive(_shown, from: _plain);
    }

    _caret();
  }

  @override
  void didUpdateWidget(NebaStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final String text = _text ?? '';

    if (widget.streaming) {
      _streamed = true;
    }

    if (!widget.fade || !_streamed) {
      _settle(text);
    } else if (text.startsWith(_shown)) {
      // Going on from what was shown: the new words fade in.
      if (text.length > _shown.length) {
        _arrive(text, from: _shown.length);
      }
    } else if (widget.streaming) {
      // Replaced mid-stream: fade from the last whole word the two share.
      _plain = _common(_shown.substring(0, _plain.clamp(0, _shown.length)), text);
      _born.clear();
      _arrive(text, from: _plain);
    } else {
      _settle(text);
    }

    _shown = text;
    _caret();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _blink?.dispose();
    super.dispose();
  }

  /// Draws all of [text] plain.
  void _settle(String text) {
    _plain = text.length;
    _born.clear();
    _ticker.stop();
    _streamed = widget.streaming;
  }

  /// Registers the words of [text] that start at or after [from] and were
  /// not seen before.
  void _arrive(String text, {required int from}) {
    if (_fadeTime == Duration.zero) {
      _plain = text.length;
      _born.clear();

      return;
    }

    if (!_ticker.isActive) {
      _clock = Duration.zero;
      _ticker.start();
    }

    for (final _Token token in _tokenize(text, _plain)) {
      if (!token.space &&
          token.start >= from &&
          !_born.containsKey(token.start) &&
          !_joined(text, token.start)) {
        _born[token.start] = _clock;
      }
    }
  }

  /// Whether the word at [start] goes on from one the plain text already
  /// began, which is drawn without a fade, as the rest of it was. Not in a
  /// script without spaces, where two characters side by side are as likely
  /// to be two words as one.
  bool _joined(String text, int start) {
    if (start != _plain || start == 0) {
      return false;
    }

    final String before = text[start - 1];
    final String after = text[start];

    return !_space.hasMatch(before) && !_unspaced.hasMatch(before + after);
  }

  void _tick(Duration elapsed) {
    _clock = elapsed;

    // Every word whose fade is over, from the front, joins the plain text.
    final String text = _shown;
    int plain = _plain;

    for (final _Token token in _tokenize(text, _plain)) {
      if (token.space) {
        plain = token.end;
        continue;
      }

      final Duration? born = _born[token.start];

      if (born != null && elapsed - born < _fadeTime) {
        break;
      }

      _born.remove(token.start);
      plain = token.end;
    }

    setState(() => _plain = plain.clamp(0, text.length));

    if (_born.isEmpty) {
      _ticker.stop();
      // A stream that has ended is plain text again once its last word is in.
      _streamed = widget.streaming;
    }
  }

  /// Starts the caret blinking while it shows, and stops it while it does not.
  void _caret() {
    final bool blinking =
        widget.streaming &&
        widget.showCursor &&
        widget.cursor == null &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

    if (blinking) {
      _blink ??= AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    } else {
      _blink?.dispose();
      _blink = null;
    }
  }

  /// The longest start [one] and [two] share, cut back to a whole word.
  int _common(String one, String two) {
    if (two.startsWith(one)) {
      return one.length;
    }

    int at = 0;

    while (at < one.length && at < two.length && one[at] == two[at]) {
      at += 1;
    }

    while (at > 0 && !_space.hasMatch(two[at - 1])) {
      at -= 1;
    }

    return at;
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final Widget? child = widget.child;
    final String? text = _text;
    final TextStyle ambient = DefaultTextStyle.of(context).style;
    final TextStyle style = child is Text ? ambient.merge(child.style) : ambient;
    final double em = style.fontSize ?? 14;
    final Color accent = tokens.roles(widget.color ?? NebaColor.primary).accent;

    Widget? caret;

    if (widget.streaming && widget.showCursor) {
      final AnimationController? blink = _blink;
      final Widget block = Container(
        width: em * 0.5,
        height: em,
        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(1)),
      );

      caret = ExcludeSemantics(
        child:
            widget.cursor ??
            (blink == null
                ? block
                : AnimatedBuilder(
                    animation: blink,
                    // On for the first half of each second, as the
                    // stylesheet's step-end blink is.
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(opacity: blink.value < 0.5 ? 1 : 0, child: child);
                    },
                    child: block,
                  )),
      );
    }

    Widget content;

    if (child is Text && text != null) {
      final List<InlineSpan> spans = <InlineSpan>[];
      final int plain = _plain.clamp(0, text.length);

      if (plain >= text.length) {
        spans.add(TextSpan(text: text));
      } else {
        if (plain > 0) {
          spans.add(TextSpan(text: text.substring(0, plain)));
        }

        final Color ink = style.color ?? tokens.fg;

        for (final _Token token in _tokenize(text, plain)) {
          final String piece = text.substring(token.start, token.end);
          final Duration? born = _born[token.start];

          if (token.space || born == null) {
            spans.add(TextSpan(text: piece));
          } else {
            final double shown = _fadeTime == Duration.zero
                ? 1
                : ((_clock - born).inMicroseconds / _fadeTime.inMicroseconds).clamp(0.0, 1.0);

            spans.add(
              TextSpan(
                text: piece,
                style: TextStyle(
                  color: ink.withValues(alpha: ink.a * NebaScale.ease.transform(shown)),
                ),
              ),
            );
          }
        }
      }

      if (caret != null) {
        spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: caret));
      }

      content = nebaRetext(child, TextSpan(children: spans));
    } else if (caret != null) {
      content = Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: <Widget>[?child, caret]);
    } else {
      content = child ?? const SizedBox.shrink();
    }

    // The floor, in the block's own line height.
    final TextPainter measure = TextPainter(
      text: TextSpan(text: ' ', style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final double line = measure.preferredLineHeight;
    measure.dispose();

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.lines * line),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        widthFactor: 1,
        heightFactor: 1,
        child: content,
      ),
    );
  }
}
