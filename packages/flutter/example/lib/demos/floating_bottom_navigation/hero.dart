import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingBottomNavigationHero extends StatefulWidget {
  const FloatingBottomNavigationHero({super.key});

  @override
  State<FloatingBottomNavigationHero> createState() => _FloatingBottomNavigationHeroState();
}

class _FloatingBottomNavigationHeroState extends State<FloatingBottomNavigationHero> {
  String _section = 'home';

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.lg]!);
    final BorderRadius row = BorderRadius.circular(tokens.radius[NebaSize.sm]!);

    // The screen the bar floats over is a Stack, and the bar takes the whole
    // of it and floats at the bottom. What scrolls keeps room at its end, so
    // its last row can come out from under the bar.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        height: 288,
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: <Widget>[
                    NebaTypography(_section, level: NebaTypographyLevel.h6),
                    for (int i = 0; i < 6; i++)
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: tokens.roles(NebaColor.primary).soft,
                          borderRadius: row,
                        ),
                      ),
                  ],
                ),
              ),
              NebaFloatingBottomNavigation<String>(
                position: NebaFloatingBottomNavigationPosition.absolute,
                label: 'Main',
                value: _section,
                onValueChange: (String next) => setState(() => _section = next),
                children: const <NebaBottomNavigationItem<String>>[
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
                    value: 'library',
                    icon: _Icon(_library),
                    child: Text('Library'),
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

/// Two books on a shelf and a third leaning on them.
Path _library() {
  return Path()
    ..addRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(2.5, 3, 3, 10), const Radius.circular(1)),
    )
    ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 3, 3, 10), const Radius.circular(1)))
    ..moveTo(11.6, 4)
    ..lineTo(14, 12.4);
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
