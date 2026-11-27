import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class VisuallyHiddenHero extends StatelessWidget {
  const VisuallyHiddenHero({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaIconButton(onPressed: press, icon: const _Refresh(), label: 'Refresh'),
        NebaChip(onDelete: press, child: const Text('Seoul')),
        NebaButton(
          onPressed: press,
          variant: NebaVariant.text,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExcludeSemantics(child: Text('7')),
              NebaVisuallyHidden(child: Text('7 unread messages')),
            ],
          ),
        ),
        Text(
          'The last button says "7" to the eye and "7 unread messages" to a screen reader.',
          style: TextStyle(fontSize: 13, color: tokens.mutedFg),
        ),
      ],
    );
  }
}

/// A circular arrow in the icon colour at the icon size the button hands
/// down.
class _Refresh extends StatelessWidget {
  const _Refresh();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _RefreshPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _RefreshPainter extends CustomPainter {
  _RefreshPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawArc(Rect.fromCircle(center: const Offset(8, 8), radius: 5.5), 0, 5.4, false, stroke)
      ..drawPath(
        Path()
          ..moveTo(13, 2)
          ..lineTo(13, 5)
          ..lineTo(10, 5),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_RefreshPainter oldDelegate) => oldDelegate.color != color;
}
