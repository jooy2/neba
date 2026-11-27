import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingActionButtonAppearance extends StatelessWidget {
  const FloatingActionButtonAppearance({super.key});

  @override
  Widget build(BuildContext context) {
    // With no onPressed and no actions a Flutter button is disabled, so every
    // button here that is meant to answer is given something to do.
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final NebaSize size in <NebaSize>[
              NebaSize.sm,
              NebaSize.md,
              NebaSize.lg,
              NebaSize.xl,
            ])
              NebaFloatingActionButton(
                position: NebaFloatingActionButtonPosition.static,
                size: size,
                icon: const _Plus(),
                label: 'Add, ${size.name}',
                onPressed: () {},
              ),
          ],
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            NebaFloatingActionButton(
              position: NebaFloatingActionButtonPosition.static,
              icon: const _Plus(),
              label: 'Add',
              variant: NebaVariant.outline,
              onPressed: () {},
            ),
            NebaFloatingActionButton(
              position: NebaFloatingActionButtonPosition.static,
              icon: const _Plus(),
              label: 'Add',
              color: NebaColor.success,
              elevation: 3,
              onPressed: () {},
            ),
            NebaFloatingActionButton(
              position: NebaFloatingActionButtonPosition.static,
              icon: const _Plus(),
              label: 'Add',
              disabled: true,
              onPressed: () {},
            ),
          ],
        ),
        const NebaTypography(
          'size defaults to lg, elevation to 2',
          level: NebaTypographyLevel.caption,
          color: NebaColor.secondary,
        ),
      ],
    );
  }
}

/// A plus, on the 16-unit grid, at the icon size and in the icon colour the
/// button hands down.
class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _PlusPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawLine(const Offset(8, 3.5), const Offset(8, 12.5), stroke)
      ..drawLine(const Offset(3.5, 8), const Offset(12.5, 8), stroke)
      ..restore();
  }

  @override
  bool shouldRepaint(_PlusPainter oldDelegate) => oldDelegate.color != color;
}
