import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class CollapsibleSlots extends StatelessWidget {
  const CollapsibleSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        children: <Widget>[
          NebaCollapsible(
            title: Text('Notifications'),
            subtitle: Text('How we reach you'),
            startIcon: _BellIcon(),
            action: NebaSwitch(
              size: NebaSize.sm,
              defaultChecked: true,
              semanticLabel: 'Enable notifications',
            ),
            child: NebaTypography(
              'Email goes out immediately. Push waits five minutes, so a message you have '
              'already read on another device never rings twice.',
            ),
          ),
          NebaCollapsible(
            title: Text('No chevron'),
            indicator: false,
            child: NebaTypography('The header still reports its state by colour.'),
          ),
        ],
      ),
    );
  }
}

/// A bell, drawn at the icon size and in the icon colour the header sets, as
/// an `Icon` reads them.
class _BellIcon extends StatelessWidget {
  const _BellIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size,
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
      ..scale(size.shortestSide / 16)
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
      ..drawPath(
        Path()
          ..moveTo(6.5, 13)
          ..arcToPoint(const Offset(9.5, 13), radius: const Radius.circular(1.5), clockwise: false),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BellPainter oldDelegate) => oldDelegate.color != color;
}
