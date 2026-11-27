import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The compact and the expanded pill, which is the whole idea being borrowed.
/// It grows into its second half by its height, and nothing is transformed on
/// the way.
class PillExpandable extends StatefulWidget {
  const PillExpandable({super.key});

  @override
  State<PillExpandable> createState() => _PillExpandableState();
}

class _PillExpandableState extends State<PillExpandable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaPill(
          startIcon: const _Plane(),
          color: NebaColor.info,
          title: const Text('KE081 → ICN'),
          description: const Text('Boards in 25 minutes'),
          expanded: _expanded,
          onPressed: () => setState(() => _expanded = !_expanded),
          details: const NebaFlex(
            direction: NebaOrientation.vertical,
            spacing: 1,
            children: <Widget>[
              NebaTypography('Gate B14 · seat 12A', level: NebaTypographyLevel.caption),
              NebaTypography('On time', level: NebaTypographyLevel.caption),
            ],
          ),
        ),
        const NebaTypography('Press the pill.', level: NebaTypographyLevel.caption),
      ],
    );
  }
}

/// A paper plane, at the icon size and in the icon colour the pill sets.
class _Plane extends StatelessWidget {
  const _Plane();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _PlanePainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PlanePainter extends CustomPainter {
  _PlanePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(2, 8.5)
          ..lineTo(14, 3)
          ..lineTo(10.5, 13)
          ..lineTo(8.3, 8.8)
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PlanePainter oldDelegate) => oldDelegate.color != color;
}
