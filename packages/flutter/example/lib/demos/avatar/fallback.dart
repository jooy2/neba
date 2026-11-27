import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AvatarFallback extends StatelessWidget {
  const AvatarFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        // Loads, so nothing else is ever drawn.
        NebaAvatar(
          size: NebaSize.xl,
          image: AssetImage('assets/samples/people/noa-marin.jpg'),
          name: 'Noa Marin',
        ),

        // Fails, so the initials take over.
        NebaAvatar(
          size: NebaSize.xl,
          image: AssetImage('assets/not-a-real-image.png'),
          name: 'Jane Doe',
          color: NebaColor.danger,
        ),

        // No picture at all: the child stands in for it.
        NebaAvatar(
          size: NebaSize.xl,
          name: 'Deploy bot',
          color: NebaColor.secondary,
          child: _RobotIcon(),
        ),

        // A single character: a channel, a team.
        NebaAvatar(
          size: NebaSize.xl,
          variant: NebaVariant.solid,
          color: NebaColor.warning,
          child: Text('#'),
        ),

        // Nothing to go on at all.
        NebaAvatar(size: NebaSize.xl, color: NebaColor.secondary),
      ],
    );
  }
}

/// A robot, drawn in the icon colour at the icon size the avatar hands down.
class _RobotIcon extends StatelessWidget {
  const _RobotIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 24,
      child: CustomPaint(painter: _RobotPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _RobotPainter extends CustomPainter {
  _RobotPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final Paint fill = Paint()..color = color;

    canvas
      ..save()
      ..scale(size.width / 24)
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(3.5, 7.5, 17, 13), const Radius.circular(3.5)),
        stroke,
      )
      ..drawLine(const Offset(12, 3.5), const Offset(12, 7.5), stroke)
      ..drawCircle(const Offset(9, 13.5), 1.5, fill)
      ..drawCircle(const Offset(15, 13.5), 1.5, fill)
      ..restore();
  }

  @override
  bool shouldRepaint(_RobotPainter oldDelegate) => oldDelegate.color != color;
}
