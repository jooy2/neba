import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BreadcrumbIcons extends StatelessWidget {
  const BreadcrumbIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaBreadcrumb(
      size: NebaSize.lg,
      children: <NebaBreadcrumbItem>[
        NebaBreadcrumbItem(
          onPressed: () {},
          href: Uri.parse('#home'),
          startIcon: const _Icon(_HomePainter.new),
          child: const Text('Home'),
        ),
        NebaBreadcrumbItem(onPressed: () {}, href: Uri.parse('#src'), child: const Text('src')),
        const NebaBreadcrumbItem(startIcon: _Icon(_FilePainter.new), child: Text('Button.tsx')),
      ],
    );
  }
}

/// A 16-unit drawing in the icon colour at the icon size the step hands down.
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

/// A house with its door, the React demo's path.
class _HomePainter extends CustomPainter {
  _HomePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const Radius corner = Radius.circular(0.5);
    final Path house = Path()
      ..moveTo(2.5, 7)
      ..lineTo(8, 2.5)
      ..lineTo(13.5, 7)
      ..lineTo(13.5, 13)
      ..arcToPoint(const Offset(13, 13.5), radius: corner)
      ..lineTo(10, 13.5)
      ..lineTo(10, 9.5)
      ..lineTo(6, 9.5)
      ..lineTo(6, 13.5)
      ..lineTo(3, 13.5)
      ..arcToPoint(const Offset(2.5, 13), radius: corner)
      ..close();

    canvas
      ..scale(size.width / 16)
      ..drawPath(house, _stroke(color));
  }

  @override
  bool shouldRepaint(_HomePainter oldDelegate) => oldDelegate.color != color;
}

/// A page with its corner folded.
class _FilePainter extends CustomPainter {
  _FilePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path page = Path()
      ..moveTo(4, 2)
      ..lineTo(9, 2)
      ..lineTo(12, 5)
      ..lineTo(12, 14)
      ..lineTo(4, 14)
      ..close();
    final Path fold = Path()
      ..moveTo(9, 2)
      ..lineTo(9, 5)
      ..lineTo(12, 5);

    canvas
      ..scale(size.width / 16)
      ..drawPath(page, _stroke(color))
      ..drawPath(fold, _stroke(color));
  }

  @override
  bool shouldRepaint(_FilePainter oldDelegate) => oldDelegate.color != color;
}
