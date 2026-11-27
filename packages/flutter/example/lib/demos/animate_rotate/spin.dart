import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Two angles and no fade is what turns an arrival into a spin.
class AnimateRotateSpin extends StatelessWidget {
  const AnimateRotateSpin({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      spacing: 6,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        NebaAnimateRotate(
          from: 0,
          to: 360,
          repeat: double.infinity,
          curve: Curves.linear,
          fade: false,
          duration: const Duration(milliseconds: 2400),
          child: NebaIcon(
            icon: _Glyph(_gear),
            size: NebaSize.lg,
            color: NebaColor.primary,
            semanticLabel: 'Working',
          ),
        ),
        NebaAnimateRotate(
          from: 0,
          to: -360,
          repeat: double.infinity,
          curve: Curves.linear,
          fade: false,
          duration: const Duration(milliseconds: 1400),
          child: NebaIcon(
            icon: _Glyph(_gear),
            color: NebaColor.secondary,
            semanticLabel: 'Working faster',
          ),
        ),
      ],
    );
  }
}

/// A 16-unit line drawing in the icon colour around it.
class _Glyph extends StatelessWidget {
  const _Glyph(this.paths);

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

/// A gear: a ring and eight spokes.
final List<Path> _gear = <Path>[
  Path()..addOval(Rect.fromCircle(center: const Offset(8, 8), radius: 2.5)),
  Path()
    ..moveTo(8, 1)
    ..lineTo(8, 3)
    ..moveTo(8, 13)
    ..lineTo(8, 15)
    ..moveTo(1, 8)
    ..lineTo(3, 8)
    ..moveTo(13, 8)
    ..lineTo(15, 8)
    ..moveTo(3.1, 3.1)
    ..lineTo(4.5, 4.5)
    ..moveTo(11.5, 11.5)
    ..lineTo(12.9, 12.9)
    ..moveTo(12.9, 3.1)
    ..lineTo(11.5, 4.5)
    ..moveTo(4.5, 11.5)
    ..lineTo(3.1, 12.9),
];
