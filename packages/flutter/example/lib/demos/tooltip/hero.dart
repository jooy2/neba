import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TooltipHero extends StatelessWidget {
  const TooltipHero({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    // `delay: Duration.zero` so the preview answers the first hover. A real
    // screen wants the default wait.
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaTooltip(
          content: const Text('Copy the deploy URL'),
          delay: Duration.zero,
          child: NebaButton(
            onPressed: press,
            variant: NebaVariant.outline,
            semanticLabel: 'Copy the deploy URL',
            startIcon: const _LinkIcon(),
          ),
        ),
        const NebaTooltip(
          content: Text('Every commit on main deploys here'),
          delay: Duration.zero,
          child: NebaChip(
            variant: NebaVariant.text,
            color: NebaColor.success,
            child: Text('production'),
          ),
        ),
        NebaTooltip(
          content: const Text('Deleting a workspace cannot be undone'),
          color: NebaColor.danger,
          delay: Duration.zero,
          child: NebaButton(
            onPressed: press,
            color: NebaColor.danger,
            variant: NebaVariant.outline,
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }
}

/// Two links of a chain, in the icon colour at the icon size the button
/// hands down.
class _LinkIcon extends StatelessWidget {
  const _LinkIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _LinkPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _LinkPainter extends CustomPainter {
  _LinkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const Radius round = Radius.circular(2.5);
    final Path path = Path()
      ..moveTo(6.5, 9.5)
      ..arcToPoint(const Offset(10.04, 9.5), radius: round, clockwise: false)
      ..lineTo(12.04, 7.5)
      ..arcToPoint(const Offset(8.5, 3.96), radius: round, clockwise: false)
      ..lineTo(8, 4.46)
      ..moveTo(9.5, 6.5)
      ..arcToPoint(const Offset(5.96, 6.5), radius: round, clockwise: false)
      ..lineTo(3.96, 8.5)
      ..arcToPoint(const Offset(7.5, 12.04), radius: round, clockwise: false)
      ..lineTo(8, 11.54);

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path,
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
  bool shouldRepaint(_LinkPainter oldDelegate) => oldDelegate.color != color;
}
