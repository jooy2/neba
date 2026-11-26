/// The glyphs more than one widget draws, the React package's
/// `src/internal/icons.tsx` in Dart.
///
/// Each one is the same SVG in the same 16-unit box, read with
/// `parseSvgPath`, so a close button's × is one drawing on both packages. The
/// chevron is drawn pointing down once and turned by whoever needs it another
/// way, because rotating a glyph is the one transform the design language
/// allows. The severity set is a piece of the design language rather than a
/// convenience: an alert that says "this went wrong" only in red says it only
/// to some readers, so the shape carries the meaning too.
///
/// The library talking to itself: nothing here is exported.
library;

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:neba/src/internal/svg_path.dart';
import 'package:neba/src/types.dart';

/// One stroke or fill of a glyph, in the 16-unit box.
@immutable
class NebaGlyphPart {
  /// A stroked path.
  const NebaGlyphPart.stroke(
    this.data, {
    this.width = 1.5,
    this.cap = StrokeCap.butt,
    this.join = StrokeJoin.miter,
    this.opacity = 1,
  }) : fill = false;

  /// A filled path.
  const NebaGlyphPart.fill(this.data, {this.opacity = 1})
    : fill = true,
      width = 0,
      cap = StrokeCap.butt,
      join = StrokeJoin.miter;

  /// The SVG path data.
  final String data;

  /// Whether the path is filled rather than stroked.
  final bool fill;

  /// The stroke width, in the box's units.
  final double width;

  /// The stroke's ends.
  final StrokeCap cap;

  /// The stroke's corners.
  final StrokeJoin join;

  /// How much of the colour this part takes, as `stroke-opacity` does.
  final double opacity;
}

/// A circle as path data, for the parts SVG writes as `<circle>`.
String _circle(double cx, double cy, double r) {
  return 'M${cx - r} $cy a$r $r 0 1 0 ${2 * r} 0 a$r $r 0 1 0 ${-2 * r} 0Z';
}

/// The glyphs, by name.
abstract final class NebaGlyphs {
  /// The × a close or a remove button draws.
  static final List<NebaGlyphPart> close = <NebaGlyphPart>[
    const NebaGlyphPart.stroke('m4.5 4.5 7 7m0-7-7 7', width: 1.75, cap: StrokeCap.round),
  ];

  /// The chevron, pointing down.
  static final List<NebaGlyphPart> chevron = <NebaGlyphPart>[
    const NebaGlyphPart.stroke(
      'm4.5 6.5 3.5 3.5 3.5-3.5',
      cap: StrokeCap.round,
      join: StrokeJoin.round,
    ),
  ];

  /// The tick of a checked row or box.
  static final List<NebaGlyphPart> check = <NebaGlyphPart>[
    const NebaGlyphPart.stroke(
      'm3.5 8.5 3 3 6-6',
      width: 1.75,
      cap: StrokeCap.round,
      join: StrokeJoin.round,
    ),
  ];

  /// A minus.
  static final List<NebaGlyphPart> minus = <NebaGlyphPart>[
    const NebaGlyphPart.stroke('M3.5 8h9', width: 1.75, cap: StrokeCap.round),
  ];

  /// A plus.
  static final List<NebaGlyphPart> plus = <NebaGlyphPart>[
    const NebaGlyphPart.stroke('M8 3.5v9M3.5 8h9', width: 1.75, cap: StrokeCap.round),
  ];

  /// The dot of a chosen radio row.
  static final List<NebaGlyphPart> dot = <NebaGlyphPart>[NebaGlyphPart.fill(_circle(8, 8, 3.25))];

  /// The turning ring of something in progress: a faint track and an arc.
  /// It is the one glyph that is turned continuously, by whoever draws it.
  static final List<NebaGlyphPart> spinner = <NebaGlyphPart>[
    NebaGlyphPart.stroke(_circle(8, 8, 6.5), width: 2, opacity: 0.25),
    const NebaGlyphPart.stroke('M14.5 8A6.5 6.5 0 0 0 8 1.5', width: 2, cap: StrokeCap.round),
  ];

  /// The neutral severity: a note.
  static final List<NebaGlyphPart> note = <NebaGlyphPart>[
    NebaGlyphPart.stroke(_circle(8, 8, 6.25)),
    const NebaGlyphPart.stroke('M8 7.25v4', cap: StrokeCap.round),
    NebaGlyphPart.fill(_circle(8, 4.9, 0.85)),
  ];

  /// Something went well.
  static final List<NebaGlyphPart> success = <NebaGlyphPart>[
    NebaGlyphPart.stroke(_circle(8, 8, 6.25)),
    const NebaGlyphPart.stroke(
      'm5.25 8.25 1.9 1.9 3.6-3.9',
      cap: StrokeCap.round,
      join: StrokeJoin.round,
    ),
  ];

  /// Something needs attention.
  static final List<NebaGlyphPart> warning = <NebaGlyphPart>[
    const NebaGlyphPart.stroke(
      'M7.13 2.6 1.9 11.7a1 1 0 0 0 .87 1.5h10.46a1 1 0 0 0 .87-1.5L8.87 2.6a1 1 0 0 0-1.74 0Z',
      join: StrokeJoin.round,
    ),
    const NebaGlyphPart.stroke('M8 6.1v3', cap: StrokeCap.round),
    NebaGlyphPart.fill(_circle(8, 11.2, 0.85)),
  ];

  /// Something went wrong.
  static final List<NebaGlyphPart> danger = <NebaGlyphPart>[
    NebaGlyphPart.stroke(_circle(8, 8, 6.25)),
    const NebaGlyphPart.stroke('m5.9 5.9 4.2 4.2m0-4.2-4.2 4.2', cap: StrokeCap.round),
  ];

  /// The severity glyph of [color]: `success`, `warning` and `danger` have
  /// their own, and every other family says only "note".
  static List<NebaGlyphPart> severity(NebaColor color) {
    switch (color) {
      case NebaColor.success:
        return success;
      case NebaColor.warning:
        return warning;
      case NebaColor.danger:
        return danger;
      case NebaColor.primary:
      case NebaColor.secondary:
      case NebaColor.info:
        return note;
    }
  }
}

/// Draws a glyph at [size], in [color] or the ambient icon or text colour.
class NebaGlyph extends StatelessWidget {
  /// A glyph from [NebaGlyphs].
  const NebaGlyph(this.parts, {this.size, this.color, super.key});

  /// What to draw.
  final List<NebaGlyphPart> parts;

  /// The glyph's width and height. Defaults to the ambient icon size, then 16.
  final double? size;

  /// The glyph's colour. Defaults to the ambient icon colour, then the text's.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);
    final double extent = size ?? icon.size ?? 16;
    final Color paint =
        color ?? icon.color ?? DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);

    return SizedBox.square(
      dimension: extent,
      child: CustomPaint(painter: _GlyphPainter(parts, paint)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.parts, this.color);

  final List<NebaGlyphPart> parts;
  final Color color;

  /// Each part's path, read once per part rather than once per paint.
  static final Expando<ui.Path> _paths = Expando<ui.Path>('glyph paths');

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 16, size.height / 16);

    for (final NebaGlyphPart part in parts) {
      final ui.Path path = _paths[part] ??= parseSvgPath(part.data);
      final Paint paint = Paint()
        ..color = color.withValues(alpha: color.a * part.opacity)
        ..isAntiAlias = true;

      if (part.fill) {
        paint.style = PaintingStyle.fill;
      } else {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = part.width
          ..strokeCap = part.cap
          ..strokeJoin = part.join;
      }

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.color != color || !identical(oldDelegate.parts, parts);
  }
}
