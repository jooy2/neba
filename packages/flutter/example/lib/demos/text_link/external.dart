import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class TextLinkExternal extends StatelessWidget {
  const TextLinkExternal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaTextLink(onPressed: _open, newTab: true, child: Text('New tab')),
        NebaTextLink(onPressed: _open, newTab: true, showIcon: false, child: Text('No mark')),
        NebaTextLink(onPressed: _open, showIcon: true, child: Text('Same tab, marked')),
        NebaTextLink(
          onPressed: _open,
          icon: _DownloadIcon(),
          color: NebaColor.secondary,
          child: Text('A glyph of its own'),
        ),
      ],
    );
  }
}

/// An arrow down onto a line, drawn in the icon colour the link sets.
class _DownloadIcon extends StatelessWidget {
  const _DownloadIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);

    return CustomPaint(painter: _DownloadPainter(theme.color ?? const Color(0xFF000000)));
  }
}

class _DownloadPainter extends CustomPainter {
  _DownloadPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(8, 2.75)
          ..lineTo(8, 9.75)
          ..moveTo(5.25, 7)
          ..lineTo(8, 9.75)
          ..lineTo(10.75, 7)
          ..moveTo(3, 12.5)
          ..lineTo(13, 12.5),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DownloadPainter oldDelegate) => oldDelegate.color != color;
}
