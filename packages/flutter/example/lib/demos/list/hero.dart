import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ListHero extends StatelessWidget {
  const ListHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: const NebaList(
        children: <Widget>[
          NebaListItem(
            startIcon: _Icon(_FolderPainter.new),
            description: Text('12 items'),
            child: Text('Documents'),
          ),
          NebaListItem(
            startIcon: _Icon(_ImagePainter.new),
            description: Text('248 items'),
            child: Text('Pictures'),
          ),
          NebaListItem(
            startIcon: _Icon(_FilePainter.new),
            description: Text('Edited yesterday'),
            child: Text('Notes.md'),
          ),
        ],
      ),
    );
  }
}

/// A 16-unit drawing in the icon colour at the icon size the row hands down.
class _Icon extends StatelessWidget {
  const _Icon(this.painter);

  final CustomPainter Function(Color color) painter;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: painter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

Paint _stroke(Color color) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeJoin = StrokeJoin.round;
}

/// A folder with its tab, the React demo's path.
class _FolderPainter extends CustomPainter {
  _FolderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const Radius corner = Radius.circular(1.5);
    final Path path = Path()
      ..moveTo(1.75, 4.25)
      ..arcToPoint(const Offset(3.25, 2.75), radius: corner)
      ..lineTo(5.65, 2.75)
      ..lineTo(6.85, 4.25)
      ..lineTo(12.75, 4.25)
      ..arcToPoint(const Offset(14.25, 5.75), radius: corner)
      ..lineTo(14.25, 11.75)
      ..arcToPoint(const Offset(12.75, 13.25), radius: corner)
      ..lineTo(3.25, 13.25)
      ..arcToPoint(const Offset(1.75, 11.75), radius: corner)
      ..close();

    canvas
      ..scale(size.width / 16)
      ..drawPath(path, _stroke(color));
  }

  @override
  bool shouldRepaint(_FolderPainter oldDelegate) => oldDelegate.color != color;
}

/// A picture frame with the sun and a line of hills in it.
class _ImagePainter extends CustomPainter {
  _ImagePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = _stroke(color)..strokeJoin = StrokeJoin.miter;
    final Path hills = Path()
      ..moveTo(3, 11.5)
      ..lineTo(6, 9)
      ..lineTo(9, 11)
      ..lineTo(11, 9.5)
      ..lineTo(13, 11.5);

    canvas
      ..scale(size.width / 16)
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(2, 3, 12, 10), const Radius.circular(1.5)),
        stroke,
      )
      ..drawCircle(const Offset(6, 6.5), 1.25, stroke)
      ..drawPath(hills, stroke);
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) => oldDelegate.color != color;
}

/// A page with its corner folded.
class _FilePainter extends CustomPainter {
  _FilePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path page = Path()
      ..moveTo(4, 2.75)
      ..lineTo(9, 2.75)
      ..lineTo(12.5, 6)
      ..lineTo(12.5, 13.25)
      ..lineTo(4, 13.25)
      ..close();
    final Path fold = Path()
      ..moveTo(9, 2.75)
      ..lineTo(9, 6)
      ..lineTo(12.5, 6);

    canvas
      ..scale(size.width / 16)
      ..drawPath(page, _stroke(color))
      ..drawPath(fold, _stroke(color));
  }

  @override
  bool shouldRepaint(_FilePainter oldDelegate) => oldDelegate.color != color;
}
