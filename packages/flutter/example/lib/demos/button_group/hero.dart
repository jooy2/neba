import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonGroupHero extends StatelessWidget {
  const ButtonGroupHero({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButtonGroup(
          variant: NebaVariant.outline,
          color: NebaColor.secondary,
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Day')),
            NebaButton(onPressed: press, child: const Text('Week')),
            NebaButton(onPressed: press, child: const Text('Month')),
          ],
        ),
        NebaButtonGroup(
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Deploy')),
            NebaButton(
              onPressed: press,
              semanticLabel: 'More options',
              startIcon: const _ChevronDown(),
            ),
          ],
        ),
      ],
    );
  }
}

/// A chevron pointing down, in the icon colour at the icon size the button
/// hands down.
class _ChevronDown extends StatelessWidget {
  const _ChevronDown();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _ChevronPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(4.5, 6.5)
          ..lineTo(8, 10)
          ..lineTo(11.5, 6.5),
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
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
