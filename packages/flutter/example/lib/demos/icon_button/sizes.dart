import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The same control heights everything else uses, so a disc drops into a row
/// of buttons without the row losing its baseline.
class IconButtonSizes extends StatelessWidget {
  const IconButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 4,
          alignItems: NebaAlignItems.end,
          children: <Widget>[
            for (final NebaSize size in NebaSize.values)
              NebaFlex(
                direction: NebaOrientation.vertical,
                spacing: 2,
                alignItems: NebaAlignItems.center,
                children: <Widget>[
                  NebaIconButton(
                    onPressed: press,
                    icon: const _Search(),
                    label: 'Search, ${size.name}',
                    size: size,
                  ),
                  NebaTypography(size.name, level: NebaTypographyLevel.caption),
                ],
              ),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 2,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            NebaButton(onPressed: press, variant: NebaVariant.outline, child: const Text('Filter')),
            NebaIconButton(
              onPressed: press,
              icon: const _Search(),
              label: 'Search',
              variant: NebaVariant.outline,
            ),
            const NebaTypography(
              'Same height, different shape.',
              level: NebaTypographyLevel.caption,
            ),
          ],
        ),
      ],
    );
  }
}

/// A magnifying glass in the icon colour at the icon size the button hands
/// down.
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
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawCircle(const Offset(7, 7), 4.25, stroke)
      ..drawLine(const Offset(10.25, 10.25), const Offset(13.25, 13.25), stroke)
      ..restore();
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}
