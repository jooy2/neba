import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToolbarHero extends StatelessWidget {
  const ToolbarHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaToolbar(
      start: const <Widget>[
        NebaIcon(
          icon: _Glyph(_logo),
          size: NebaSize.lg,
          color: NebaColor.primary,
          semanticLabel: 'Neba',
        ),
      ],
      end: <Widget>[
        NebaIconButton(
          onPressed: () {},
          icon: const _Glyph(_bell),
          label: 'Notifications',
          variant: NebaVariant.text,
          size: NebaSize.sm,
        ),
        NebaButton(onPressed: () {}, size: NebaSize.sm, child: const Text('Deploy')),
      ],
      // The name in the middle, which gives way on a narrow screen where the
      // two ends do not.
      children: const <Widget>[
        Flexible(child: NebaTypography('Workspace', level: NebaTypographyLevel.h6, lines: 1)),
      ],
    );
  }
}

void _logo(Path path) {
  path
    ..addRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(2.5, 2.5, 11, 11), const Radius.circular(3.5)),
    )
    ..moveTo(5.5, 10.5)
    ..lineTo(5.5, 5.5)
    ..lineTo(10.5, 10.5)
    ..lineTo(10.5, 5.5);
}

void _bell(Path path) {
  path
    ..moveTo(4, 6.5)
    ..arcToPoint(const Offset(12, 6.5), radius: const Radius.circular(4))
    ..cubicTo(12, 9.5, 13, 10.5, 13, 10.5)
    ..lineTo(3, 10.5)
    ..cubicTo(3, 10.5, 4, 9.5, 4, 6.5)
    ..close()
    ..moveTo(6.5, 13)
    ..arcToPoint(const Offset(9.5, 13), radius: const Radius.circular(1.5), clockwise: false);
}

/// A 16-unit path stroked in the icon colour at the icon size around it.
class _Glyph extends StatelessWidget {
  const _Glyph(this.trace);

  final void Function(Path path) trace;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _GlyphPainter(trace, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.trace, this.color);

  final void Function(Path path) trace;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    trace(path);
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}
