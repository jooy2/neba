import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChipContent extends StatelessWidget {
  const ChipContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaChip(child: Text('Text only')),
        NebaChip(startIcon: _BranchIcon(), child: Text('main')),
        NebaChip(count: Text('4'), child: Text('Comments')),
        NebaChip(
          variant: NebaVariant.solid,
          color: NebaColor.danger,
          count: Text('99'),
          child: Text('Failing'),
        ),
        NebaChip(
          startIcon: _BranchIcon(),
          count: Text('2'),
          color: NebaColor.info,
          child: Text('release/1.2'),
        ),
      ],
    );
  }
}

/// A branch, drawn in the icon colour at the icon size the chip hands down.
class _BranchIcon extends StatelessWidget {
  const _BranchIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _BranchPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _BranchPainter extends CustomPainter {
  _BranchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 16);

    final Path stem = Path()
      ..moveTo(5, 3)
      ..lineTo(5, 13)
      ..moveTo(5, 8)
      ..lineTo(9, 8)
      ..arcToPoint(const Offset(11, 6), radius: const Radius.circular(2), clockwise: false)
      ..lineTo(11, 4);
    final Paint fill = Paint()..color = color;

    canvas
      ..drawPath(
        stem,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(const Offset(5, 3), 1.6, fill)
      ..drawCircle(const Offset(11, 3), 1.6, fill)
      ..drawCircle(const Offset(5, 13), 1.6, fill);
  }

  @override
  bool shouldRepaint(_BranchPainter oldDelegate) => oldDelegate.color != color;
}
