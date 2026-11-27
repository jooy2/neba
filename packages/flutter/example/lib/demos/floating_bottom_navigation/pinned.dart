import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingBottomNavigationPinned extends StatelessWidget {
  const FloatingBottomNavigationPinned({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    // The bar floats over the box that scrolls, in a Stack with it, and the
    // content keeps room at its end so its last row can come out from under
    // the bar.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        height: 256,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
                child: NebaFlex(
                  direction: NebaOrientation.vertical,
                  spacing: 4,
                  children: <Widget>[
                    for (int row = 1; row <= 10; row++)
                      NebaTypography('Row $row. Scroll the box: the bar keeps its gap.'),
                  ],
                ),
              ),
              const NebaFloatingBottomNavigation<String>(
                position: NebaFloatingBottomNavigationPosition.sticky,
                label: 'Main',
                offset: 12,
                safeArea: false,
                size: NebaSize.sm,
                defaultValue: 'home',
                children: <NebaBottomNavigationItem<String>>[
                  NebaBottomNavigationItem<String>(
                    value: 'home',
                    icon: _Icon(_home),
                    child: Text('Home'),
                  ),
                  NebaBottomNavigationItem<String>(
                    value: 'search',
                    icon: _Icon(_search),
                    child: Text('Search'),
                  ),
                  NebaBottomNavigationItem<String>(
                    value: 'you',
                    icon: _Icon(_profile),
                    child: Text('You'),
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

/// A house with a pitched roof, on the 16-unit grid.
Path _home() {
  return Path()
    ..moveTo(2.5, 7)
    ..lineTo(8, 2.5)
    ..lineTo(13.5, 7)
    ..lineTo(13.5, 13)
    ..arcToPoint(const Offset(13, 13.5), radius: const Radius.circular(0.5))
    ..lineTo(3, 13.5)
    ..arcToPoint(const Offset(2.5, 13), radius: const Radius.circular(0.5))
    ..close();
}

/// A lens with a handle.
Path _search() {
  return Path()
    ..addOval(Rect.fromCircle(center: const Offset(7, 7), radius: 4.25))
    ..moveTo(10.25, 10.25)
    ..lineTo(13.25, 13.25);
}

/// A head over a pair of shoulders.
Path _profile() {
  return Path()
    ..addOval(Rect.fromCircle(center: const Offset(8, 5.75), radius: 2.75))
    ..moveTo(3, 13.25)
    ..arcToPoint(const Offset(13, 13.25), radius: const Radius.circular(5));
}

/// A stroked path in the icon colour at the icon size the destination hands
/// down.
class _Icon extends StatelessWidget {
  const _Icon(this.path);

  final Path Function() path;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _IconPainter(path, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);

  final Path Function() path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path(),
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
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
