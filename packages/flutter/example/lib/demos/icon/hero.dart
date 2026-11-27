import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class IconHero extends StatelessWidget {
  const IconHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaIcon(
          icon: _Glyph(_bolt),
          size: NebaSize.xl,
          color: NebaColor.warning,
          semanticLabel: 'Fast',
        ),
        NebaTypography.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'Deploys finish in '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: NebaIcon(icon: _Glyph(_bolt), color: NebaColor.warning),
              ),
              const TextSpan(text: ' under a minute.'),
            ],
          ),
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

/// A lightning bolt.
final List<Path> _bolt = <Path>[
  Path()
    ..moveTo(9, 1.5)
    ..lineTo(3.5, 9.25)
    ..lineTo(7.5, 9.25)
    ..lineTo(7, 14.5)
    ..lineTo(12.5, 6.75)
    ..lineTo(8.5, 6.75)
    ..lineTo(9, 1.5)
    ..close(),
];
