import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BottomNavigationLabels extends StatelessWidget {
  const BottomNavigationLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          for (final NebaBottomNavigationLabels labels in NebaBottomNavigationLabels.values)
            NebaFlex(
              direction: NebaOrientation.vertical,
              spacing: 1,
              children: <Widget>[
                NebaTypography(
                  'labels: ${labels.name}',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
                // Every bar on a screen takes a name once there is more than
                // one, or Flutter's semantics check fails.
                NebaBottomNavigation<String>(
                  position: NebaPosition.static,
                  label: 'Music, ${labels.name}',
                  labels: labels,
                  defaultValue: 'library',
                  children: const <NebaBottomNavigationItem<String>>[
                    NebaBottomNavigationItem<String>(
                      value: 'listen',
                      icon: _Disc(),
                      child: Text('Listen'),
                    ),
                    NebaBottomNavigationItem<String>(
                      value: 'library',
                      icon: _Disc(),
                      child: Text('Library'),
                    ),
                    NebaBottomNavigationItem<String>(
                      value: 'radio',
                      icon: _Disc(),
                      child: Text('Radio'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A ring with a dot in it, on the 16-unit grid, at the icon size and in the
/// icon colour the destination hands down.
class _Disc extends StatelessWidget {
  const _Disc();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _DiscPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _DiscPainter extends CustomPainter {
  _DiscPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawCircle(
        const Offset(8, 8),
        5.25,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )
      ..drawCircle(const Offset(8, 8), 1.5, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_DiscPainter oldDelegate) => oldDelegate.color != color;
}
