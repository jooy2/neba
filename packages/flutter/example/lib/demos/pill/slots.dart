import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The leading slot takes a picture as readily as a glyph: it is a square
/// clipped to a circle, and the picture fills and crops it. The trailing slot
/// is outside the pressable row, so a control can live there.
class PillSlots extends StatelessWidget {
  const PillSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaPill(
          variant: NebaVariant.outline,
          color: NebaColor.primary,
          startIcon: Image.asset('assets/samples/logos/layered-stack.png'),
          title: const Text('Neba UI'),
          description: const Text('1.0.0 published'),
        ),
        NebaPill(
          color: NebaColor.info,
          title: const Text('Deploying'),
          description: const Text('build 8f2c1a'),
          endIcon: NebaIconButton(
            onPressed: () {},
            icon: const _Pause(),
            label: 'Pause',
            size: NebaSize.xs,
            variant: NebaVariant.text,
            color: NebaColor.info,
          ),
        ),
      ],
    );
  }
}

/// Two bars, at the icon size and in the icon colour the button sets.
class _Pause extends StatelessWidget {
  const _Pause();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _PausePainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PausePainter extends CustomPainter {
  _PausePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(6, 3.5)
          ..lineTo(6, 12.5)
          ..moveTo(10, 3.5)
          ..lineTo(10, 12.5),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.75
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PausePainter oldDelegate) => oldDelegate.color != color;
}
