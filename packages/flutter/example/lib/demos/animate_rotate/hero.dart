import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AnimateRotateHero extends StatefulWidget {
  const AnimateRotateHero({super.key});

  @override
  State<AnimateRotateHero> createState() => _AnimateRotateHeroState();
}

class _AnimateRotateHeroState extends State<AnimateRotateHero> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _run += 1),
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Play again'),
        ),
        NebaAnimateRotate(
          key: ValueKey<int>(_run),
          from: -270,
          duration: const Duration(milliseconds: 800),
          child: NebaIcon(
            icon: _Glyph(_star),
            size: NebaSize.xl,
            color: NebaColor.warning,
            semanticLabel: 'Starred',
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

/// A five-pointed star.
final List<Path> _star = <Path>[
  Path()
    ..moveTo(8, 2)
    ..lineTo(9.8, 5.9)
    ..lineTo(14, 6.4)
    ..lineTo(10.9, 9.3)
    ..lineTo(11.7, 13.5)
    ..lineTo(8, 11.4)
    ..lineTo(4.3, 13.5)
    ..lineTo(5.1, 9.3)
    ..lineTo(2, 6.4)
    ..lineTo(6.2, 5.9)
    ..close(),
];
