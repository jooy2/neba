import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A plus, drawn in the icon colour at the icon size the button hands down.
class PlusIcon extends StatelessWidget {
  const PlusIcon({super.key});

  @override
  Widget build(BuildContext context) => _Stroke(
    (Path path) => path
      ..moveTo(8, 3.5)
      ..lineTo(8, 12.5)
      ..moveTo(3.5, 8)
      ..lineTo(12.5, 8),
  );
}

/// A chevron pointing the way forward.
class ChevronIcon extends StatelessWidget {
  const ChevronIcon({super.key});

  @override
  Widget build(BuildContext context) => _Stroke(
    (Path path) => path
      ..moveTo(6, 4)
      ..lineTo(10, 8)
      ..lineTo(6, 12),
  );
}

class ButtonIcons extends StatelessWidget {
  const ButtonIcons({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(onPressed: press, startIcon: const PlusIcon(), child: const Text('New project')),
        NebaButton(
          onPressed: press,
          variant: NebaVariant.outline,
          endIcon: const ChevronIcon(),
          child: const Text('Continue'),
        ),
        NebaButton(
          onPressed: press,
          variant: NebaVariant.outline,
          semanticLabel: 'Add',
          startIcon: const PlusIcon(),
        ),
      ],
    );
  }
}

/// A 16-unit path stroked at 1.75, scaled to the icon size.
class _Stroke extends StatelessWidget {
  const _Stroke(this.trace);

  final void Function(Path path) trace;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);
    final double size = icon.size ?? 16;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _StrokePainter(trace, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter(this.trace, this.color);

  final void Function(Path path) trace;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    trace(path);
    canvas
      ..scale(size.width / 16)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.75
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) => oldDelegate.color != color;
}
