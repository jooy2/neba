import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleIcons extends StatelessWidget {
  const ToggleIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaToggle(
          variant: NebaVariant.text,
          semanticLabel: 'Bold',
          defaultPressed: true,
          startIcon: _Glyph(
            (Path path) => path
              ..moveTo(4.5, 3)
              ..lineTo(8.5, 3)
              ..arcToPoint(const Offset(8.5, 8), radius: const Radius.circular(2.5))
              ..lineTo(4.5, 8)
              ..close()
              ..moveTo(4.5, 8)
              ..lineTo(9, 8)
              ..arcToPoint(const Offset(9, 13), radius: const Radius.circular(2.5))
              ..lineTo(4.5, 13)
              ..close(),
          ),
        ),
        NebaToggle(
          variant: NebaVariant.text,
          semanticLabel: 'Italic',
          startIcon: _Glyph(
            (Path path) => path
              ..moveTo(10, 3)
              ..lineTo(6.5, 3)
              ..moveTo(9.5, 13)
              ..lineTo(6, 13)
              ..moveTo(9.5, 3)
              ..lineTo(7, 13),
          ),
        ),
        NebaToggle(
          variant: NebaVariant.text,
          semanticLabel: 'Underline',
          startIcon: _Glyph(
            (Path path) => path
              ..moveTo(4.5, 2.5)
              ..lineTo(4.5, 7.5)
              ..arcToPoint(
                const Offset(11.5, 7.5),
                radius: const Radius.circular(3.5),
                clockwise: false,
              )
              ..lineTo(11.5, 2.5)
              ..moveTo(3.5, 14)
              ..lineTo(12.5, 14),
          ),
        ),
      ],
    );
  }
}

/// A 16-unit path stroked in the icon colour at the icon size the toggle
/// hands down.
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
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}
