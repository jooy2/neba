import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class MenuBasic extends StatelessWidget {
  const MenuBasic({super.key});

  @override
  Widget build(BuildContext context) {
    // The package opens nothing itself: hand the address to a router or a
    // URL launcher here. `href` tells a screen reader where the row leads.
    void open() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaMenu(
          trigger: NebaButton(
            onPressed: () {},
            variant: NebaVariant.outline,
            color: NebaColor.secondary,
            child: const Text('Share'),
          ),
          children: <Widget>[
            const NebaMenuGroup(
              label: Text('Copy'),
              children: <Widget>[
                NebaMenuItem(
                  startIcon: _Icon(_link),
                  shortcut: Text('⌘L'),
                  child: Text('Copy link'),
                ),
                NebaMenuItem(
                  startIcon: _Icon(_copy),
                  description: Text('Includes the current filters'),
                  child: Text('Copy as Markdown'),
                ),
              ],
            ),
            const NebaMenuSeparator(),
            NebaMenuGroup(
              label: const Text('Open'),
              children: <Widget>[
                NebaMenuItem(
                  href: Uri.parse('https://neba.cdget.com'),
                  newTab: true,
                  onPressed: open,
                  child: const Text('Documentation'),
                ),
                NebaMenuItem(
                  href: Uri.parse('https://github.com/jooy2/neba'),
                  newTab: true,
                  onPressed: open,
                  child: const Text('Repository'),
                ),
              ],
            ),
            const NebaMenuSeparator(),
            const NebaMenuItem(disabled: true, child: Text('Export as PDF')),
          ],
        ),
        NebaMenu(
          color: NebaColor.danger,
          trigger: NebaButton(
            onPressed: () {},
            variant: NebaVariant.outline,
            color: NebaColor.danger,
            child: const Text('Danger zone'),
          ),
          children: const <Widget>[
            NebaMenuItem(color: NebaColor.secondary, child: Text('Archive project')),
            NebaMenuSeparator(),
            NebaMenuItem(
              color: NebaColor.danger,
              description: Text('Members lose access immediately'),
              child: Text('Delete project'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Two sheets, one over the other, on the 16-unit grid.
Path _copy() {
  return Path()
    ..addRRect(RRect.fromLTRBR(5.5, 5.5, 13.5, 13.5, const Radius.circular(1.75)))
    ..moveTo(10.5, 5.5)
    ..lineTo(10.5, 4.5)
    ..arcToPoint(const Offset(8.5, 2.5), radius: const Radius.circular(2), clockwise: false)
    ..lineTo(4.5, 2.5)
    ..arcToPoint(const Offset(2.5, 4.5), radius: const Radius.circular(2), clockwise: false)
    ..lineTo(2.5, 8.5)
    ..arcToPoint(const Offset(4.5, 10.5), radius: const Radius.circular(2), clockwise: false)
    ..lineTo(5.5, 10.5);
}

/// Two links of a chain, on the 16-unit grid.
Path _link() {
  return Path()
    ..moveTo(6.5, 9.5)
    ..lineTo(9.5, 6.5)
    ..moveTo(6, 4.5)
    ..lineTo(7.5, 3)
    ..arcToPoint(const Offset(11.5, 7), radius: const Radius.circular(2.9))
    ..lineTo(10, 8.5)
    ..moveTo(10, 11.5)
    ..lineTo(8.5, 13)
    ..arcToPoint(const Offset(4.5, 9), radius: const Radius.circular(2.9))
    ..lineTo(6, 7.5);
}

/// A stroked path in the icon colour at the icon size the row hands down.
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
