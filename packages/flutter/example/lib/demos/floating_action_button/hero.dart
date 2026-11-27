import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingActionButtonHero extends StatelessWidget {
  const FloatingActionButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    // The region the button floats over is a Stack, and the button takes the
    // whole of it and sits in its corner.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        height: 192,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16),
                child: NebaTypography(
                  'A region with one action floating over it.',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
              ),
              NebaFloatingActionButton(
                position: NebaFloatingActionButtonPosition.absolute,
                icon: const _Icon(_pencil),
                label: 'Compose',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pencil, on the 16-unit grid.
Path _pencil() {
  return Path()
    ..moveTo(11, 2.5)
    ..lineTo(13.5, 5)
    ..lineTo(6, 12.5)
    ..relativeLineTo(-3.25, 0.75)
    ..lineTo(3.5, 10)
    ..close();
}

/// A stroked path in the icon colour at the icon size the button hands down.
class _Icon extends StatelessWidget {
  const _Icon(this.path);

  final Path Function() path;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _IconPainter(path, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);

  final Path Function() path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path(),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
