import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class RatingIcons extends StatelessWidget {
  const RatingIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaRating(
      icon: _Heart(filled: true),
      emptyIcon: _Heart(filled: false),
      color: NebaColor.danger,
      size: NebaSize.lg,
      defaultValue: 3,
      semanticLabel: 'How much did you like it?',
    );
  }
}

/// A heart, filled or drawn in outline in the icon colour the rating sets.
class _Heart extends StatelessWidget {
  const _Heart({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeartPainter(IconTheme.of(context).color ?? const Color(0xFF000000), filled),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final Path heart = Path()
      ..moveTo(8, 14)
      ..cubicTo(8, 14, 1.5, 10, 1.5, 5.75)
      ..arcToPoint(const Offset(8, 4.4), radius: const Radius.circular(3.25))
      ..arcToPoint(const Offset(14.5, 5.75), radius: const Radius.circular(3.25))
      ..cubicTo(14.5, 10, 8, 14, 8, 14)
      ..close();

    canvas
      ..save()
      ..scale(size.shortestSide / 16)
      ..drawPath(
        heart,
        Paint()
          ..color = color
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.25
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_HeartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}
