import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `color` is left out to inherit, which is why the icon inside a button
/// comes out in the button's ink without being told to. Naming a family opts
/// out of that.
class IconColors extends StatelessWidget {
  const IconColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: <Widget>[
            for (final NebaColor color in NebaColor.values)
              NebaIcon(
                icon: _Glyph(_check),
                color: color,
                size: NebaSize.lg,
                semanticLabel: color.name,
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            NebaButton(
              onPressed: () {},
              startIcon: NebaIcon(icon: _Glyph(_check), size: NebaSize.sm),
              child: const Text('Approve'),
            ),
            NebaButton(
              onPressed: () {},
              variant: NebaVariant.outline,
              color: NebaColor.danger,
              startIcon: NebaIcon(icon: _Glyph(_check), size: NebaSize.sm),
              child: const Text('Reject'),
            ),
            const NebaTypography(
              'Both icons inherit; neither was given a colour.',
              level: NebaTypographyLevel.caption,
            ),
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

/// A tick.
final List<Path> _check = <Path>[
  Path()
    ..moveTo(3.5, 8.5)
    ..lineTo(6.5, 11.5)
    ..lineTo(12.5, 5.5),
];
