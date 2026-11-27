import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The slots, and what a Statistic looks like when it is asked to carry more
/// than a number: an icon on the label, a unit on the figure, and something of
/// your own underneath.
class StatisticAnatomy extends StatelessWidget {
  const StatisticAnatomy({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return NebaGridContainer(
      spacing: 3,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 6 : 12),
          child: const NebaStatistic(
            icon: NebaIcon(icon: _UsersIcon(), size: NebaSize.sm),
            label: Text('Seats'),
            value: 188,
            unit: Text('/ 250'),
            caption: Text('75% of the plan'),
            child: NebaProgressLinear(value: 75, label: Text('Seats used')),
          ),
        ),
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 3 : 12),
          child: const NebaStatistic(
            label: Text('Uptime'),
            value: '99.98%',
            align: NebaAlign.center,
            variant: NebaVariant.solid,
            color: NebaColor.success,
          ),
        ),
        NebaGrid(
          span: NebaGridSpan.columns(wide ? 3 : 12),
          child: const NebaStatistic(
            label: Text('Median build'),
            value: '3m 12s',
            align: NebaAlign.center,
            variant: NebaVariant.text,
            size: NebaSize.sm,
          ),
        ),
      ],
    );
  }
}

/// Two people, drawn in the icon colour around them.
class _UsersIcon extends StatelessWidget {
  const _UsersIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _UsersPainter(IconTheme.of(context).color ?? const Color(0xFF000000)),
    );
  }
}

class _UsersPainter extends CustomPainter {
  _UsersPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawCircle(const Offset(6, 5.5), 2.5, stroke)
      ..drawPath(
        Path()
          ..moveTo(1.75, 13)
          ..cubicTo(1.75, 10.7, 3.65, 9.25, 6, 9.25)
          ..cubicTo(8.35, 9.25, 10.25, 10.7, 10.25, 13),
        stroke,
      )
      ..drawPath(
        Path()
          ..moveTo(11, 4.5)
          ..arcToPoint(const Offset(11, 8.5), radius: const Radius.circular(2))
          ..moveTo(12, 9.75)
          ..cubicTo(13.4, 10.2, 14.25, 11.35, 14.25, 13),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_UsersPainter oldDelegate) => oldDelegate.color != color;
}
