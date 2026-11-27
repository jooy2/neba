import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class IconSizes extends StatelessWidget {
  const IconSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              NebaIcon(
                icon: _Glyph(_bell),
                size: size,
                semanticLabel: 'Notifications, ${size.name}',
              ),
              NebaTypography(size.name, level: NebaTypographyLevel.caption),
            ],
          ),
      ],
    );
  }
}

/// A 16-unit line drawing in the icon colour around it: what an app's own
/// icon set would hand a `NebaIcon`.
class _Glyph extends StatelessWidget {
  const _Glyph(this.paths);

  /// The drawing, in a 16-unit box.
  final List<Path> paths;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GlyphPainter(paths, IconTheme.of(context).color ?? const Color(0xFF000000)),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.paths, this.color);

  final List<Path> paths;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(size.shortestSide / 16);

    for (final Path path in paths) {
      canvas.drawPath(path, stroke);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}

/// A bell.
final List<Path> _bell = <Path>[
  Path()
    ..moveTo(4, 6.5)
    ..arcToPoint(const Offset(12, 6.5), radius: const Radius.circular(4))
    ..cubicTo(12, 9.5, 13, 10.5, 13, 10.5)
    ..lineTo(3, 10.5)
    ..cubicTo(3, 10.5, 4, 9.5, 4, 6.5)
    ..close(),
  Path()
    ..moveTo(6.5, 13)
    ..arcToPoint(const Offset(9.5, 13), radius: const Radius.circular(1.5), clockwise: false),
];
