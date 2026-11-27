import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// One delay shared across the row: once any of these has opened, its
/// neighbours open at once, and the wait comes back after a pause.
class TooltipGrouped extends StatelessWidget {
  const TooltipGrouped({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaTooltipProvider(
      delay: const Duration(milliseconds: 400),
      child: NebaButtonGroup(
        variant: NebaVariant.outline,
        color: NebaColor.secondary,
        children: <Widget>[
          NebaTooltip(
            content: const Text('Bold'),
            child: NebaButton(
              onPressed: press,
              semanticLabel: 'Bold',
              startIcon: _Glyph(
                (Path path) => path
                  ..moveTo(5, 3)
                  ..lineTo(9, 3)
                  ..arcToPoint(const Offset(9, 8), radius: const Radius.circular(2.5))
                  ..lineTo(5, 8)
                  ..close()
                  ..moveTo(5, 8)
                  ..lineTo(9.5, 8)
                  ..arcToPoint(const Offset(9.5, 13), radius: const Radius.circular(2.5))
                  ..lineTo(5, 13)
                  ..close(),
              ),
            ),
          ),
          NebaTooltip(
            content: const Text('Italic'),
            child: NebaButton(
              onPressed: press,
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
          ),
          NebaTooltip(
            content: const Text('Underline'),
            child: NebaButton(
              onPressed: press,
              semanticLabel: 'Underline',
              startIcon: _Glyph(
                (Path path) => path
                  ..moveTo(4.5, 3)
                  ..lineTo(4.5, 7.5)
                  ..arcToPoint(
                    const Offset(11.5, 7.5),
                    radius: const Radius.circular(3.5),
                    clockwise: false,
                  )
                  ..lineTo(11.5, 3)
                  ..moveTo(4, 13.5)
                  ..lineTo(12, 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A 16-unit path stroked in the icon colour at the icon size the button
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
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}
