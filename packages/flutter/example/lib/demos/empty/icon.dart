import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class EmptyIcon extends StatelessWidget {
  const EmptyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: third,
          child: const NebaEmpty(variant: NebaVariant.outline, title: Text('Default')),
        ),
        NebaGrid(
          span: third,
          child: const NebaEmpty(
            variant: NebaVariant.outline,
            icon: _Search(),
            title: Text('Your own glyph'),
          ),
        ),
        NebaGrid(
          span: third,
          child: const NebaEmpty(
            variant: NebaVariant.outline,
            showIcon: false,
            title: Text('No glyph at all'),
          ),
        ),
      ],
    );
  }
}

/// A magnifying glass, at the icon size and in the icon colour the empty
/// state hands down.
class _Search extends StatelessWidget {
  const _Search();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _SearchPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _SearchPainter extends CustomPainter {
  _SearchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(7.25, 7.25), radius: 4.5))
          ..moveTo(10.6, 10.6)
          ..lineTo(13.25, 13.25),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}
