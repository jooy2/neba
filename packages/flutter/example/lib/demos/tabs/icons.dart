import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TabsIcons extends StatelessWidget {
  const TabsIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: const NebaTabs<String>(
        variant: NebaVariant.solid,
        defaultValue: 'inbox',
        children: <Widget>[
          NebaTab<String>(
            value: 'inbox',
            startIcon: _Icon(_inbox),
            endIcon: NebaBadge(content: Text('12'), size: NebaSize.xs),
            child: Text('Inbox'),
          ),
          NebaTab<String>(value: 'starred', startIcon: _Icon(_star), child: Text('Starred')),
          NebaTab<String>(value: 'sent', child: Text('Sent')),
          NebaTabPanel<String>(
            value: 'inbox',
            child: Text('Twelve unread, four of them from this morning.'),
          ),
          NebaTabPanel<String>(value: 'starred', child: Text('Nothing starred yet.')),
          NebaTabPanel<String>(value: 'sent', child: Text('Eight sent this week.')),
        ],
      ),
    );
  }
}

/// A tray with a notch in its lip, on the 16-unit grid.
Path _inbox() {
  return Path()
    ..moveTo(2, 9.5)
    ..lineTo(5, 9.5)
    ..lineTo(6, 11.5)
    ..lineTo(10, 11.5)
    ..lineTo(11, 9.5)
    ..lineTo(14, 9.5)
    ..moveTo(2.5, 9.5)
    ..lineTo(4, 3.5)
    ..lineTo(12, 3.5)
    ..lineTo(13.5, 9.5)
    ..lineTo(13.5, 11.5)
    ..arcToPoint(const Offset(12, 13), radius: const Radius.circular(1.5))
    ..lineTo(4, 13)
    ..arcToPoint(const Offset(2.5, 11.5), radius: const Radius.circular(1.5))
    ..close();
}

/// A five-pointed star, on the 16-unit grid.
Path _star() {
  return Path()
    ..moveTo(8, 2.5)
    ..lineTo(9.7, 6)
    ..lineTo(13.5, 6.5)
    ..lineTo(10.7, 9.2)
    ..lineTo(11.4, 13)
    ..lineTo(8, 11.2)
    ..lineTo(4.6, 13)
    ..lineTo(5.3, 9.2)
    ..lineTo(2.5, 6.5)
    ..lineTo(6.3, 6)
    ..close();
}

/// A stroked path in the icon colour at the icon size the tab hands down.
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
