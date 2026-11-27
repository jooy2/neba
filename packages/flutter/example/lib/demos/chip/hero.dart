import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ChipHero extends StatelessWidget {
  const ChipHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 2,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        const NebaChip(child: Text('design-system')),
        const NebaChip(
          variant: NebaVariant.solid,
          color: NebaColor.success,
          startIcon: _DotIcon(),
          child: Text('Live'),
        ),
        const NebaChip(color: NebaColor.danger, count: Text('12'), child: Text('Errors')),
        NebaChip(variant: NebaVariant.text, onDelete: () {}, child: const Text('typescript')),
      ],
    );
  }
}

/// A filled dot, drawn in the icon colour at the icon size the chip hands
/// down.
class _DotIcon extends StatelessWidget {
  const _DotIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _DotPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(size.center(Offset.zero), size.width / 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.color != color;
}
