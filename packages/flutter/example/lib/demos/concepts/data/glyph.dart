// The glyphs the concept screens draw, from the same SVG path data the React
// screens write, so a screen's icons are the documentation's own. Not a demo
// of its own: the registry reads only the files one folder down.

import 'package:flutter/widgets.dart';

/// A 16-unit glyph from SVG path data, stroked or filled in the icon colour
/// at the icon size the widget around it hands down.
class ConceptGlyph extends StatelessWidget {
  /// A glyph drawn from [data].
  const ConceptGlyph(this.data, {this.filled = false, this.width = 1.5, super.key});

  /// The SVG path data, on a 16-unit square.
  final String data;

  /// Whether the path is filled rather than stroked.
  final bool filled;

  /// The stroke's width, in the square's units.
  final double width;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(
        painter: _GlyphPainter(
          path: _parse(data),
          color: icon.color ?? const Color(0xFF000000),
          filled: filled,
          width: width,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.path,
    required this.color,
    required this.filled,
    required this.width,
  });

  final Path path;
  final Color color;
  final bool filled;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.path != path;
  }
}

final Map<String, Path> _parsed = <String, Path>{};

/// The SVG path commands the glyphs above use, absolute and relative: move,
/// line, horizontal, vertical, cubic, smooth cubic, arc and close.
Path _parse(String data) {
  return _parsed.putIfAbsent(data, () {
    final Path path = Path();
    final Iterable<RegExpMatch> tokens = RegExp(
      r'[MmLlHhVvCcSsAaZz]|-?(?:\d*\.\d+|\d+\.?)(?:e-?\d+)?',
    ).allMatches(data);
    final List<String> parts = <String>[for (final RegExpMatch token in tokens) token[0]!];
    int at = 0;
    String command = 'M';
    Offset point = Offset.zero;
    Offset start = Offset.zero;
    Offset? control;

    bool isCommand(String part) => RegExp(r'^[A-Za-z]$').hasMatch(part);
    double next() => double.parse(parts[at++]);
    // An arc's flags may be written run together, as `0 0 1` or `001`.
    bool flag() {
      final String part = parts[at];

      if (part.length > 1 && (part.startsWith('0') || part.startsWith('1'))) {
        parts[at] = part.substring(1);
        return part.startsWith('1');
      }

      at++;
      return part == '1';
    }

    while (at < parts.length) {
      if (isCommand(parts[at])) {
        command = parts[at++];
      }

      final bool relative = command == command.toLowerCase();
      final Offset base = relative ? point : Offset.zero;

      switch (command.toUpperCase()) {
        case 'M':
          point = base + Offset(next(), next());
          start = point;
          path.moveTo(point.dx, point.dy);
          // Further pairs after a move are lines.
          command = relative ? 'l' : 'L';
          control = null;
        case 'L':
          point = base + Offset(next(), next());
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'H':
          point = Offset((relative ? point.dx : 0) + next(), point.dy);
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'V':
          point = Offset(point.dx, (relative ? point.dy : 0) + next());
          path.lineTo(point.dx, point.dy);
          control = null;
        case 'C':
          final Offset first = base + Offset(next(), next());
          final Offset second = base + Offset(next(), next());
          point = base + Offset(next(), next());
          path.cubicTo(first.dx, first.dy, second.dx, second.dy, point.dx, point.dy);
          control = second;
        case 'S':
          final Offset reflected = control == null ? point : point * 2 - control;
          final Offset second = base + Offset(next(), next());
          point = base + Offset(next(), next());
          path.cubicTo(reflected.dx, reflected.dy, second.dx, second.dy, point.dx, point.dy);
          control = second;
        case 'A':
          final double rx = next();
          final double ry = next();
          final double rotation = next();
          final bool large = flag();
          final bool sweep = flag();
          point = base + Offset(next(), next());
          path.arcToPoint(
            point,
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: large,
            clockwise: sweep,
          );
          control = null;
        case 'Z':
          path.close();
          point = start;
          control = null;
        default:
          at++;
      }
    }

    return path;
  });
}
