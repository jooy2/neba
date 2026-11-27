import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TimelineBullets extends StatelessWidget {
  const TimelineBullets({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: <Widget>[
          // Numbers, for a sequence somebody is being walked through.
          NebaTimeline(
            active: 1,
            size: NebaSize.lg,
            children: <Widget>[
              NebaTimelineItem(
                bullet: Text('1'),
                title: Text('Account'),
                child: Text('Email and a password.'),
              ),
              NebaTimelineItem(
                bullet: Text('2'),
                title: Text('Workspace'),
                child: Text('Name it and pick a region.'),
              ),
              NebaTimelineItem(
                bullet: Text('3'),
                title: Text('Invite'),
                child: Text('Optional, and skippable.'),
              ),
            ],
          ),
          // Icons, for a sequence that already happened.
          NebaTimeline(
            active: 2,
            color: NebaColor.success,
            size: NebaSize.lg,
            children: <Widget>[
              NebaTimelineItem(bullet: _CheckIcon(), title: Text('Built'), meta: Text('1m 12s')),
              NebaTimelineItem(bullet: _CheckIcon(), title: Text('Tested'), meta: Text('3m 40s')),
              NebaTimelineItem(title: Text('Deploying'), meta: Text('running')),
            ],
          ),
        ],
      ),
    );
  }
}

/// A tick, drawn in the icon colour at the icon size the bullet hands down.
class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _CheckPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

/// The React demo's tick, in the same 16-unit box.
class _CheckPainter extends CustomPainter {
  _CheckPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path tick = Path()
      ..moveTo(3.5, 8.5)
      ..lineTo(6.5, 11.5)
      ..lineTo(12.5, 5.5);

    canvas
      ..scale(size.width / 16)
      ..drawPath(
        tick,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.color != color;
}
