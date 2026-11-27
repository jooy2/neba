import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingBottomNavigationAppearance extends StatelessWidget {
  const FloatingBottomNavigationAppearance({super.key});

  static const List<NebaVariant> _variants = <NebaVariant>[
    NebaVariant.outline,
    NebaVariant.solid,
    NebaVariant.text,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        for (final NebaVariant variant in _variants)
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              NebaTypography(
                'variant: ${variant.name}',
                level: NebaTypographyLevel.caption,
                color: NebaColor.secondary,
              ),
              // Every bar on a screen takes a name once there is more than
              // one, or Flutter's semantics check fails.
              NebaFloatingBottomNavigation<String>(
                position: NebaFloatingBottomNavigationPosition.static,
                label: 'Main, ${variant.name}',
                variant: variant,
                color: NebaColor.info,
                size: NebaSize.sm,
                defaultValue: 'home',
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
                    value: 'you',
                    icon: _Icon(_profile),
                    child: Text('You'),
                  ),
                ],
              ),
            ],
          ),
      ],
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
