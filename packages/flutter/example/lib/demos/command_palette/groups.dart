import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A page with a folded corner, on the 16-unit grid.
Path _file() {
  return Path()
    ..moveTo(9, 1.5)
    ..lineTo(4.5, 1.5)
    ..arcToPoint(const Offset(3, 3), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(3, 13)
    ..arcToPoint(const Offset(4.5, 14.5), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(11.5, 14.5)
    ..arcToPoint(const Offset(13, 13), radius: const Radius.circular(1.5), clockwise: false)
    ..lineTo(13, 5.5)
    ..lineTo(9, 1.5)
    ..close();
}

/// A lightning bolt, on the 16-unit grid.
Path _bolt() {
  return Path()
    ..moveTo(9, 1.5)
    ..lineTo(3.5, 9)
    ..lineTo(8, 9)
    ..lineTo(7, 14.5)
    ..lineTo(12.5, 7)
    ..lineTo(8, 7)
    ..lineTo(9, 1.5)
    ..close();
}

class CommandPaletteGroups extends StatefulWidget {
  const CommandPaletteGroups({super.key});

  @override
  State<CommandPaletteGroups> createState() => _CommandPaletteGroupsState();
}

class _CommandPaletteGroupsState extends State<CommandPaletteGroups> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _open = true),
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Grouped commands'),
        ),
        NebaCommandPalette(
          size: NebaSize.sm,
          shortcut: null,
          open: _open,
          onOpenChange: (bool open) => setState(() => _open = open),
          items: const <NebaCommandItem>[
            NebaCommandItem(
              value: 'new',
              label: 'New file',
              group: 'File',
              icon: _Icon(_file),
              shortcut: 'Mod+N',
            ),
            NebaCommandItem(
              value: 'open',
              label: 'Open…',
              group: 'File',
              icon: _Icon(_file),
              shortcut: 'Mod+O',
            ),
            NebaCommandItem(value: 'build', label: 'Run build', group: 'Run', icon: _Icon(_bolt)),
            NebaCommandItem(value: 'test', label: 'Run tests', group: 'Run', icon: _Icon(_bolt)),
            NebaCommandItem(
              value: 'clean',
              label: 'Clean the cache',
              group: 'Run',
              icon: _Icon(_bolt),
              disabled: true,
            ),
          ],
        ),
      ],
    );
  }
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
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
