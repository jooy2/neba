import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BottomNavigationLinks extends StatelessWidget {
  const BottomNavigationLinks({super.key});

  @override
  Widget build(BuildContext context) {
    // The package opens nothing itself: `onPressed` is where the router goes
    // to the page, and `href` tells a screen reader where that is.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: NebaBottomNavigation<String>(
        position: NebaPosition.static,
        label: 'Documentation',
        value: 'components',
        children: <NebaBottomNavigationItem<String>>[
          NebaBottomNavigationItem<String>(
            value: 'guide',
            href: Uri.parse('/guide/getting-started'),
            onPressed: () {},
            icon: const _Icon(_docs),
            child: const Text('Guide'),
          ),
          NebaBottomNavigationItem<String>(
            value: 'components',
            href: Uri.parse('/components/'),
            onPressed: () {},
            icon: const _Icon(_grid),
            child: const Text('Components'),
          ),
          NebaBottomNavigationItem<String>(
            value: 'design',
            href: Uri.parse('/design/design-language'),
            onPressed: () {},
            icon: const _Icon(_docs),
            child: const Text('Design'),
          ),
        ],
      ),
    );
  }
}

/// A page with its corner turned down, on the 16-unit grid.
Path _docs() {
  return Path()
    ..moveTo(4, 2.75)
    ..lineTo(9, 2.75)
    ..lineTo(12, 6)
    ..lineTo(12, 13.25)
    ..lineTo(4, 13.25)
    ..close()
    ..moveTo(8.75, 2.75)
    ..lineTo(8.75, 6)
    ..lineTo(12, 6);
}

/// Four squares in a grid.
Path _grid() {
  final Path path = Path();

  for (final Offset corner in const <Offset>[
    Offset(2.75, 2.75),
    Offset(8.75, 2.75),
    Offset(2.75, 8.75),
    Offset(8.75, 8.75),
  ]) {
    path.addRRect(RRect.fromRectAndRadius(corner & const Size(4.5, 4.5), const Radius.circular(1)));
  }

  return path;
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
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
