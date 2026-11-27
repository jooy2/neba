/// `NebaHighlight`, the words a reader is looking for, marked in a text.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:neba/src/components/typography/neba_typography.dart';
import 'package:neba/src/internal/search.dart';
import 'package:neba/src/theme/theme.dart';
import 'package:neba/src/theme/tokens.dart';
import 'package:neba/src/types.dart';

/// Marks the words a reader is looking for, inside a text they were already
/// reading.
///
/// The widget is the search, not only its look: `query` is what a search box
/// holds, and how it matches is an argument. A string is one term, the
/// [NebaHighlight.terms] constructor takes several and tries the longest
/// first, and [NebaHighlight.pattern] takes a regular expression used as
/// written. A string term ignores accents, so `jose` marks `José`.
///
/// [child] is the text to search: a [Text], a [Text.rich] or a
/// [NebaTypography]. Its spans are walked into, a match inside a bold span is
/// marked and stays bold, and a widget inside it is left as it is. The marks never move the text around
/// them: a mark's surface is drawn a hair wider than its word, behind it.
///
/// ```dart
/// NebaHighlight(query: query, child: const Text('A sheet of cut acrylic.'))
/// ```
class NebaHighlight extends StatelessWidget {
  /// Marks every place [query] appears in [child].
  const NebaHighlight({
    required String this.query,
    required this.child,
    this.variant,
    this.color = NebaColor.warning,
    this.caseSensitive = false,
    this.wholeWord = false,
    this.underline = false,
    this.weight,
    super.key,
  }) : assert(child is Text || child is NebaTypography);

  /// Marks every place any of [query] appears in [child], the longest term
  /// first, so `['data', 'database']` marks the whole of `database`.
  const NebaHighlight.terms({
    required List<String> this.query,
    required this.child,
    this.variant,
    this.color = NebaColor.warning,
    this.caseSensitive = false,
    this.wholeWord = false,
    this.underline = false,
    this.weight,
    super.key,
  }) : assert(child is Text || child is NebaTypography);

  /// Marks every match of [query] in [child], as written: the expression
  /// already says whether case matters and where a word ends.
  const NebaHighlight.pattern({
    required RegExp this.query,
    required this.child,
    this.variant,
    this.color = NebaColor.warning,
    this.underline = false,
    this.weight,
    super.key,
  }) : assert(child is Text || child is NebaTypography),
       caseSensitive = false,
       wholeWord = false;

  /// What to find: a [String], a [List] of them, or a [RegExp], by the
  /// constructor. An empty string marks nothing.
  final Object query;

  /// The text to search: a [Text], a [Text.rich] or a [NebaTypography].
  final Widget child;

  /// The weight of the mark: `solid`, the default, fills it like a
  /// highlighter pen, `outline` draws a hairline box around the word and
  /// `text` changes its colour alone. Defaults to `NebaProvider`'s, then
  /// [NebaVariant.solid].
  final NebaVariant? variant;

  /// The family of the mark. [NebaColor.warning], whose fill is light with
  /// dark ink on it, so a solid mark reads as a yellow highlighter.
  final NebaColor color;

  /// Whether `a` and `A` are different letters. Ignored by
  /// [NebaHighlight.pattern].
  final bool caseSensitive;

  /// Whether a term has to be a word on its own, so `cat` marks "cat" but not
  /// "concatenate". A word is a run of letters, digits and underscores in any
  /// script, which says little about Korean or Japanese, where a phrase is not
  /// set off by spaces. Ignored by [NebaHighlight.pattern].
  final bool wholeWord;

  /// Whether the mark is underlined as well, under every variant.
  final bool underline;

  /// The mark's weight. Left out, a mark is the weight of the text around it.
  final FontWeight? weight;

  /// How far a mark's surface reaches past its word on each side.
  static const double inset = 2;

  /// The corners of a mark's surface.
  static const double radius = 4;

  /// The thickness of the underline, and its distance under the text.
  static const double underlineThickness = 2;

  @override
  Widget build(BuildContext context) {
    final Widget child = this.child;
    final RegExp? pattern = _patternOf(query, caseSensitive);

    if (pattern == null) {
      return child;
    }

    final NebaTokens tokens = NebaTheme.of(context);
    final NebaColorRoles roles = tokens.roles(color);
    final NebaVariant variant =
        this.variant ?? NebaTheme.defaultsOf(context).variant ?? NebaVariant.solid;
    final Color ink = variant == NebaVariant.solid ? roles.onSolid : roles.onTint;
    final _Marker marker = _Marker(
      pattern: pattern,
      wholeWord: wholeWord && query is! RegExp,
      fold: query is! RegExp,
      style: TextStyle(color: ink, fontWeight: weight),
    );
    final InlineSpan source = switch (child) {
      Text(:final InlineSpan textSpan) => textSpan,
      Text(:final String? data) => TextSpan(text: data),
      NebaTypography(:final InlineSpan span) => span,
      // An overline is set in capitals, which the typography does to its
      // string; a span it draws as given.
      NebaTypography(:final String? data, :final NebaTypographyLevel level) => TextSpan(
        text: level == NebaTypographyLevel.overline ? data?.toUpperCase() : data,
      ),
      _ => throw ArgumentError.value(child, 'child', 'is not a Text or a NebaTypography'),
    };
    final InlineSpan marked = marker.mark(source);

    if (marker.ranges.isEmpty) {
      return child;
    }

    return _Marks(
      ranges: marker.ranges,
      fill: switch (variant) {
        NebaVariant.solid => roles.fill,
        NebaVariant.outline => roles.panel,
        NebaVariant.text => null,
      },
      edge: variant == NebaVariant.outline ? roles.line : null,
      underline: underline ? ink : null,
      child: switch (child) {
        Text() => Text.rich(
          marked,
          key: child.key,
          style: child.style,
          strutStyle: child.strutStyle,
          textAlign: child.textAlign,
          textDirection: child.textDirection,
          locale: child.locale,
          softWrap: child.softWrap,
          overflow: child.overflow,
          textScaler: child.textScaler,
          maxLines: child.maxLines,
          semanticsLabel: child.semanticsLabel,
          semanticsIdentifier: child.semanticsIdentifier,
          textWidthBasis: child.textWidthBasis,
          textHeightBehavior: child.textHeightBehavior,
          selectionColor: child.selectionColor,
        ),
        NebaTypography() => NebaTypography.rich(
          marked,
          key: child.key,
          level: child.level,
          color: child.color,
          weight: child.weight,
          align: child.align,
          lines: child.lines,
          gutter: child.gutter,
          headingLevel: child.headingLevel,
          style: child.style,
          semanticsLabel: child.semanticsLabel,
          transition: child.transition,
        ),
        _ => child,
      },
    );
  }
}

/// The characters a regular expression treats as syntax.
final RegExp _syntax = RegExp(r'[.*+?^${}()|[\]\\]');

/// What [NebaHighlight.wholeWord] counts as part of a word.
final RegExp _wordCharacter = RegExp(r'[\p{L}\p{N}_]', unicode: true);

/// The query as one expression, or `null` when there is nothing to look for:
/// an empty search box leaves the text as it was rather than marking every
/// character in it. Terms are tried longest first, because an alternation is
/// first match wins.
RegExp? _patternOf(Object query, bool caseSensitive) {
  if (query is RegExp) {
    return query;
  }

  final List<String> terms =
      (query is String ? <String>[query] : query as List<String>)
          .map((String term) => nebaFold(term.trim()))
          .where((String term) => term.isNotEmpty)
          .toList()
        ..sort((String a, String b) => b.length - a.length);

  if (terms.isEmpty) {
    return null;
  }

  return RegExp(
    terms.map((String term) => term.replaceAllMapped(_syntax, (Match m) => '\\${m[0]}')).join('|'),
    caseSensitive: caseSensitive,
    unicode: true,
  );
}

/// Whether the match from [start] to [end] in [text] is a word on its own.
bool _isWholeWord(String text, int start, int end) {
  final String before = start > 0 ? text[start - 1] : '';
  final String after = end < text.length ? text[end] : '';

  return !_wordCharacter.hasMatch(before) && !_wordCharacter.hasMatch(after);
}

/// Walks a span tree, splitting its text into plain runs and marked ones and
/// keeping where each mark lands in the paragraph's flattened text.
class _Marker {
  _Marker({
    required this.pattern,
    required this.wholeWord,
    required this.fold,
    required this.style,
  });

  final RegExp pattern;
  final bool wholeWord;
  final bool fold;
  final TextStyle style;

  /// Where each mark is, in the paragraph's code units.
  final List<TextRange> ranges = <TextRange>[];

  int _offset = 0;

  InlineSpan mark(InlineSpan span) {
    if (span is! TextSpan) {
      // A widget in the text takes one placeholder and is left alone.
      _offset += 1;

      return span;
    }

    final String? text = span.text;
    final List<InlineSpan>? pieces = text == null || span.semanticsLabel != null
        ? null
        : _split(text, span);

    if (pieces == null) {
      _offset += text?.length ?? 0;
    }

    final List<InlineSpan>? children = span.children;
    List<InlineSpan>? marked = children;

    if (children != null) {
      final List<InlineSpan> next = <InlineSpan>[];
      bool changed = false;

      for (final InlineSpan child in children) {
        final InlineSpan result = mark(child);
        changed = changed || !identical(result, child);
        next.add(result);
      }

      if (changed) {
        marked = next;
      }
    }

    if (pieces == null && identical(marked, children)) {
      return span;
    }

    return TextSpan(
      text: pieces == null ? text : null,
      style: span.style,
      locale: span.locale,
      spellOut: span.spellOut,
      semanticsLabel: span.semanticsLabel,
      recognizer: pieces == null ? span.recognizer : null,
      mouseCursor: pieces == null ? span.mouseCursor : null,
      onEnter: pieces == null ? span.onEnter : null,
      onExit: pieces == null ? span.onExit : null,
      children: <InlineSpan>[...?pieces, ...?marked],
    );
  }

  /// [text] as runs, the marked ones in [style], or `null` when nothing in it
  /// matched. Each run keeps the span's gestures, which a child span does not
  /// inherit.
  List<InlineSpan>? _split(String text, TextSpan owner) {
    final NebaFoldedText? folded = fold ? nebaFoldText(text) : null;
    final String haystack = folded?.text ?? text;
    final List<TextRange> found = <TextRange>[];
    int from = 0;

    while (from <= haystack.length) {
      final Iterator<RegExpMatch> next = pattern.allMatches(haystack, from).iterator;

      if (!next.moveNext()) {
        break;
      }

      final RegExpMatch match = next.current;

      if (match.end == match.start) {
        // A pattern that can match nothing would otherwise never advance.
        from = match.start + 1;
        continue;
      }

      final int start = folded == null ? match.start : folded.starts[match.start];
      final int end = folded == null ? match.end : folded.ends[match.end - 1];

      if (wholeWord && !_isWholeWord(text, start, end)) {
        // Rewound to just after where the match started: a rejected match is
        // not a claim on the characters inside it, so `cat` in
        // `concatenate cat` still finds the second one.
        from = match.start + 1;
        continue;
      }

      found.add(TextRange(start: start, end: end));
      from = match.end;
    }

    if (found.isEmpty) {
      return null;
    }

    TextSpan run(String piece, {TextStyle? style}) {
      return TextSpan(
        text: piece,
        style: style,
        recognizer: owner.recognizer,
        mouseCursor: owner.mouseCursor,
        onEnter: owner.onEnter,
        onExit: owner.onExit,
      );
    }

    final List<InlineSpan> pieces = <InlineSpan>[];
    int cursor = 0;

    for (final TextRange range in found) {
      if (range.start > cursor) {
        pieces.add(run(text.substring(cursor, range.start)));
      }

      pieces.add(run(text.substring(range.start, range.end), style: style));
      ranges.add(TextRange(start: _offset + range.start, end: _offset + range.end));
      cursor = range.end;
    }

    if (cursor < text.length) {
      pieces.add(run(text.substring(cursor)));
    }

    _offset += text.length;

    return pieces;
  }
}

/// Draws each mark's surface and underline behind the paragraph below it.
class _Marks extends SingleChildRenderObjectWidget {
  const _Marks({
    required this.ranges,
    required this.fill,
    required this.edge,
    required this.underline,
    required super.child,
  });

  final List<TextRange> ranges;
  final Color? fill;
  final Color? edge;
  final Color? underline;

  @override
  _RenderMarks createRenderObject(BuildContext context) {
    return _RenderMarks(ranges: ranges, fill: fill, edge: edge, underline: underline);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderMarks renderObject) {
    renderObject
      ..ranges = ranges
      ..fill = fill
      ..edge = edge
      ..underline = underline;
  }
}

class _RenderMarks extends RenderProxyBox {
  _RenderMarks({
    required List<TextRange> ranges,
    required Color? fill,
    required Color? edge,
    required Color? underline,
  }) : _ranges = ranges,
       _fill = fill,
       _edge = edge,
       _underline = underline;

  List<TextRange> _ranges;
  set ranges(List<TextRange> value) {
    if (!listEquals(value, _ranges)) {
      _ranges = value;
      markNeedsPaint();
    }
  }

  Color? _fill;
  set fill(Color? value) {
    if (value != _fill) {
      _fill = value;
      markNeedsPaint();
    }
  }

  Color? _edge;
  set edge(Color? value) {
    if (value != _edge) {
      _edge = value;
      markNeedsPaint();
    }
  }

  Color? _underline;
  set underline(Color? value) {
    if (value != _underline) {
      _underline = value;
      markNeedsPaint();
    }
  }

  /// The paragraph the marks are in: the first one down the single-child
  /// chain a [Text] builds.
  RenderParagraph? get _paragraph {
    RenderObject? node = child;

    while (node != null && node is! RenderParagraph) {
      RenderObject? only;
      node.visitChildren((RenderObject child) => only ??= child);
      node = only;
    }

    return node as RenderParagraph?;
  }

  /// A mark's rectangles in the paragraph, one per line it runs across, in the
  /// paragraph's own coordinates.
  List<Rect> _lines(RenderParagraph paragraph, TextRange range) {
    final List<Rect> lines = <Rect>[];

    for (final TextBox box in paragraph.getBoxesForSelection(
      TextSelection(baseOffset: range.start, extentOffset: range.end),
    )) {
      final Rect rect = box.toRect();

      if (lines.isNotEmpty) {
        final Rect last = lines.last;
        // A run of the same line, split by a fallback font or a bidi level.
        if (rect.center.dy > last.top &&
            rect.center.dy < last.bottom &&
            (rect.left - last.right).abs() < 1) {
          lines[lines.length - 1] = last.expandToInclude(rect);
          continue;
        }
      }

      lines.add(rect);
    }

    return lines;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderParagraph? paragraph = _paragraph;
    final Color? fill = _fill;
    final Color? edge = _edge;
    final Color? underline = _underline;

    if (paragraph != null && paragraph.hasSize && (fill != null || underline != null)) {
      final Canvas canvas = context.canvas;
      final Offset at =
          offset + MatrixUtils.transformPoint(paragraph.getTransformTo(this), Offset.zero);

      for (final TextRange range in _ranges) {
        for (final Rect line in _lines(paragraph, range)) {
          final Rect text = line.shift(at);

          if (fill != null) {
            // A hair of padding each side, given straight back, so a mark is
            // a little wider than its word and the line keeps its length; an
            // outline's hairline is a pixel more each way.
            final double border = edge == null ? 0 : 1;
            final RRect surface = RRect.fromRectAndRadius(
              Rect.fromLTRB(
                text.left - NebaHighlight.inset - border,
                text.top - border,
                text.right + NebaHighlight.inset + border,
                text.bottom + border,
              ),
              const Radius.circular(NebaHighlight.radius),
            );

            canvas.drawRRect(surface, Paint()..color = fill);

            if (edge != null) {
              canvas.drawRRect(
                surface.deflate(0.5),
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1
                  ..color = edge,
              );
            }
          }

          if (underline != null) {
            // Under the descenders rather than through them.
            canvas.drawRect(
              Rect.fromLTWH(text.left, text.bottom, text.width, NebaHighlight.underlineThickness),
              Paint()..color = underline,
            );
          }
        }
      }
    }

    super.paint(context, offset);
  }
}
