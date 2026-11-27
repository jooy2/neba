import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class IconButtonHero extends StatelessWidget {
  const IconButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaIconButton(onPressed: press, icon: const _Plus(), label: 'Add item'),
        NebaIconButton(
          onPressed: press,
          icon: const _Star(),
          label: 'Star',
          variant: NebaVariant.outline,
        ),
        NebaIconButton(
          onPressed: press,
          icon: const _Trash(),
          label: 'Delete',
          variant: NebaVariant.text,
          color: NebaColor.danger,
        ),
      ],
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) => _Glyph(
    (Path path) => path
      ..moveTo(8, 3.5)
      ..lineTo(8, 12.5)
      ..moveTo(3.5, 8)
      ..lineTo(12.5, 8),
    width: 1.75,
  );
}

class _Star extends StatelessWidget {
  const _Star();

  @override
  Widget build(BuildContext context) => _Glyph(
    (Path path) => path
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
  );
}

class _Trash extends StatelessWidget {
  const _Trash();

  @override
  Widget build(BuildContext context) => _Glyph(
    (Path path) => path
      ..moveTo(3, 4.5)
      ..lineTo(13, 4.5)
      ..moveTo(6.5, 4.5)
      ..lineTo(6.5, 3)
      ..lineTo(9.5, 3)
      ..lineTo(9.5, 4.5)
      ..moveTo(4.5, 4.5)
      ..lineTo(5, 12.5)
      ..lineTo(11, 12.5)
      ..lineTo(11.5, 4.5),
  );
}

/// A 16-unit path stroked in the icon colour at the icon size the button
/// hands down.
class _Glyph extends StatelessWidget {
  const _Glyph(this.trace, {this.width = 1.5});

  final void Function(Path path) trace;
  final double width;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(
        painter: _GlyphPainter(trace, icon.color ?? const Color(0xFF000000), width),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.trace, this.color, this.width);

  final void Function(Path path) trace;
  final Color color;
  final double width;

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
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}
