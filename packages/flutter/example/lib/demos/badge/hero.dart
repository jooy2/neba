import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BadgeHero extends StatelessWidget {
  const BadgeHero({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaBadge.count(
          count: 4,
          semanticLabel: '4 unread notifications',
          child: NebaButton(
            onPressed: press,
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            semanticLabel: 'Notifications',
            startIcon: const _Bell(),
          ),
        ),
        NebaBadge.count(
          count: 128,
          semanticLabel: '128 open issues',
          child: NebaButton(
            onPressed: press,
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            child: const Text('Issues'),
          ),
        ),
        const NebaBadge(
          color: NebaColor.success,
          semanticLabel: 'Online',
          overlap: NebaBadgeOverlap.circle,
          child: NebaAvatar(
            image: AssetImage('assets/samples/people/nadia-rowan.jpg'),
            name: 'Nadia Rowan',
            size: NebaSize.lg,
          ),
        ),
        const NebaBadge(
          content: Text('NEW'),
          size: NebaSize.sm,
          color: NebaColor.warning,
          placement: NebaCorner.topStart,
          child: NebaChip(
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            child: Text('Releases'),
          ),
        ),
      ],
    );
  }
}

/// A bell, in the icon colour at the icon size the button hands down.
class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _BellPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _BellPainter extends CustomPainter {
  _BellPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(4, 6.5)
          ..arcToPoint(const Offset(12, 6.5), radius: const Radius.circular(4))
          ..cubicTo(12, 9.5, 13, 10.5, 13, 10.5)
          ..lineTo(3, 10.5)
          ..cubicTo(3, 10.5, 4, 9.5, 4, 6.5)
          ..close(),
        stroke,
      )
      ..drawArc(
        Rect.fromCircle(center: const Offset(8, 13), radius: 1.5),
        0,
        3.14159,
        false,
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BellPainter oldDelegate) => oldDelegate.color != color;
}
