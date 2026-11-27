import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BottomNavigationPinned extends StatelessWidget {
  const BottomNavigationPinned({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    // A screen is a column here: what scrolls takes the room that is left,
    // and the bar holds the bottom of it.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        height: 256,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: NebaFlex(
                    direction: NebaOrientation.vertical,
                    spacing: 4,
                    children: <Widget>[
                      for (int row = 1; row <= 8; row++)
                        NebaTypography('Row $row. Scroll the box: the bar stays at its bottom.'),
                    ],
                  ),
                ),
              ),
              const NebaBottomNavigation<String>(
                position: NebaPosition.sticky,
                label: 'Feed',
                defaultValue: 'feed',
                safeArea: false,
                children: <NebaBottomNavigationItem<String>>[
                  NebaBottomNavigationItem<String>(
                    value: 'feed',
                    icon: _Dot(),
                    child: Text('Feed'),
                  ),
                  NebaBottomNavigationItem<String>(
                    value: 'saved',
                    icon: _Dot(),
                    child: Text('Saved'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ring, on the 16-unit grid, at the icon size and in the icon colour the
/// destination hands down.
class _Dot extends StatelessWidget {
  const _Dot();

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
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawCircle(
        const Offset(8, 8),
        4.25,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.color != color;
}
