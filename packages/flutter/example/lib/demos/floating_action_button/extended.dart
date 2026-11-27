import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingActionButtonExtended extends StatelessWidget {
  const FloatingActionButtonExtended({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaFloatingActionButton(
          position: NebaFloatingActionButtonPosition.static,
          icon: const _Pencil(),
          label: 'Compose',
          extended: true,
          onPressed: () {},
        ),
        NebaFloatingActionButton(
          position: NebaFloatingActionButtonPosition.static,
          icon: const _Pencil(),
          label: 'Compose',
          extended: true,
          variant: NebaVariant.outline,
          onPressed: () {},
        ),
        NebaFloatingActionButton(
          position: NebaFloatingActionButtonPosition.static,
          icon: const _Pencil(),
          label: 'Compose',
          onPressed: () {},
        ),
      ],
    );
  }
}

/// A pencil, on the 16-unit grid, at the icon size and in the icon colour the
/// button hands down.
class _Pencil extends StatelessWidget {
  const _Pencil();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _PencilPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PencilPainter extends CustomPainter {
  _PencilPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(11, 2.5)
      ..lineTo(13.5, 5)
      ..lineTo(6, 12.5)
      ..relativeLineTo(-3.25, 0.75)
      ..lineTo(3.5, 10)
      ..close();

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PencilPainter oldDelegate) => oldDelegate.color != color;
}
