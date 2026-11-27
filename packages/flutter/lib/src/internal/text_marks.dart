/// Surfaces and underlines drawn behind runs of a paragraph's text, so the
/// text itself is laid out exactly as it would be without them.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Draws a surface and an underline behind each of [ranges] in the paragraph
/// [child] lays out: the first one down its chain of render objects, which is
/// where a [Text] puts its own.
///
/// A range that runs across lines is drawn once per line, each piece with its
/// own corners, as CSS `box-decoration-break: clone` draws an inline box. A
/// surface reaches [inset] past its text on either side and takes no room, so
/// the line keeps its length; an [edge] is a hairline a pixel further out.
/// The underline is [underlineThickness] thick, drawn under the text's own box
/// so it clears the descenders, across the text and not the inset.
class NebaTextMarks extends SingleChildRenderObjectWidget {
  /// Marks [ranges] of the paragraph in [child].
  const NebaTextMarks({
    required super.child,
    this.ranges,
    this.fill,
    this.edge,
    this.inset = 0,
    this.radius = 0,
    this.underline,
    this.underlineThickness = 1,
    super.key,
  });

  /// The runs to mark, in the paragraph's code units. `null` marks all of it.
  final List<TextRange>? ranges;

  /// The surface behind each run, or `null` for none.
  final Color? fill;

  /// A hairline around each surface, or `null` for none.
  final Color? edge;

  /// How far a surface reaches past its text on each side.
  final double inset;

  /// A surface's corners.
  final double radius;

  /// The underline's colour, or `null` for none.
  final Color? underline;

  /// The underline's thickness.
  final double underlineThickness;

  @override
  RenderNebaTextMarks createRenderObject(BuildContext context) {
    return RenderNebaTextMarks(
      ranges: ranges,
      fill: fill,
      edge: edge,
      inset: inset,
      radius: radius,
      underline: underline,
      underlineThickness: underlineThickness,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderNebaTextMarks renderObject) {
    renderObject
      ..ranges = ranges
      ..fill = fill
      ..edge = edge
      ..inset = inset
      ..radius = radius
      ..underline = underline
      ..underlineThickness = underlineThickness;
  }
}

/// The render object behind [NebaTextMarks].
class RenderNebaTextMarks extends RenderProxyBox {
  /// Marks of the paragraph below.
  RenderNebaTextMarks({
    required List<TextRange>? ranges,
    required Color? fill,
    required Color? edge,
    required double inset,
    required double radius,
    required Color? underline,
    required double underlineThickness,
  }) : _ranges = ranges,
       _fill = fill,
       _edge = edge,
       _inset = inset,
       _radius = radius,
       _underline = underline,
       _underlineThickness = underlineThickness;

  List<TextRange>? _ranges;

  /// The runs to mark, or `null` for the whole paragraph.
  set ranges(List<TextRange>? value) {
    if (!listEquals(value, _ranges)) {
      _ranges = value;
      markNeedsPaint();
    }
  }

  Color? _fill;

  /// The surface behind each run.
  set fill(Color? value) {
    if (value != _fill) {
      _fill = value;
      markNeedsPaint();
    }
  }

  Color? _edge;

  /// The hairline around each surface.
  set edge(Color? value) {
    if (value != _edge) {
      _edge = value;
      markNeedsPaint();
    }
  }

  double _inset;

  /// How far a surface reaches past its text.
  set inset(double value) {
    if (value != _inset) {
      _inset = value;
      markNeedsPaint();
    }
  }

  double _radius;

  /// A surface's corners.
  set radius(double value) {
    if (value != _radius) {
      _radius = value;
      markNeedsPaint();
    }
  }

  Color? _underline;

  /// The underline's colour.
  set underline(Color? value) {
    if (value != _underline) {
      _underline = value;
      markNeedsPaint();
    }
  }

  double _underlineThickness;

  /// The underline's thickness.
  set underlineThickness(double value) {
    if (value != _underlineThickness) {
      _underlineThickness = value;
      markNeedsPaint();
    }
  }

  /// The paragraph the marks are in: the first one down the chain of render
  /// objects below, taking the first child where there are several.
  RenderParagraph? get _paragraph {
    RenderObject? node = child;

    while (node != null && node is! RenderParagraph) {
      RenderObject? first;
      node.visitChildren((RenderObject child) => first ??= child);
      node = first;
    }

    return node as RenderParagraph?;
  }

  /// A run's rectangles in the paragraph, one per line it crosses.
  static List<Rect> _lines(RenderParagraph paragraph, TextRange range) {
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
      final List<TextRange> ranges =
          _ranges ??
          <TextRange>[
            TextRange(
              start: 0,
              end: paragraph.text.toPlainText(includeSemanticsLabels: false).length,
            ),
          ];

      for (final TextRange range in ranges) {
        for (final Rect line in _lines(paragraph, range)) {
          final Rect text = line.shift(at);

          if (fill != null) {
            final double border = edge == null ? 0 : 1;
            final RRect surface = RRect.fromRectAndRadius(
              Rect.fromLTRB(
                text.left - _inset - border,
                text.top - border,
                text.right + _inset + border,
                text.bottom + border,
              ),
              Radius.circular(_radius),
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

          if (underline != null && underline.a > 0) {
            canvas.drawRect(
              Rect.fromLTWH(text.left, text.bottom, text.width, math.max(_underlineThickness, 0)),
              Paint()..color = underline,
            );
          }
        }
      }
    }

    super.paint(context, offset);
  }
}

/// [source] with its text replaced by [span] and every other setting kept,
/// for a widget that rebuilds a caller's [Text] around marks or a glyph.
Text nebaRetext(Text source, InlineSpan span) {
  return Text.rich(
    span,
    key: source.key,
    style: source.style,
    strutStyle: source.strutStyle,
    textAlign: source.textAlign,
    textDirection: source.textDirection,
    locale: source.locale,
    softWrap: source.softWrap,
    overflow: source.overflow,
    textScaler: source.textScaler,
    maxLines: source.maxLines,
    semanticsLabel: source.semanticsLabel,
    semanticsIdentifier: source.semanticsIdentifier,
    textWidthBasis: source.textWidthBasis,
    textHeightBehavior: source.textHeightBehavior,
    selectionColor: source.selectionColor,
  );
}

/// The span a [Text] draws: its own, or its string as one.
InlineSpan nebaSpanOf(Text text) => text.textSpan ?? TextSpan(text: text.data);
