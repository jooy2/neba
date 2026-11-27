import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AppLogoShape extends StatelessWidget {
  const AppLogoShape({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 32,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaAppLogo(name: 'Neba', size: NebaSize.lg, child: _Mark()),
        NebaAppLogo(name: 'Neba', size: NebaSize.lg, shape: NebaAppLogoShape.app, child: _Mark()),
        NebaAppLogo(
          name: 'Neba',
          size: NebaSize.lg,
          shape: NebaAppLogoShape.circle,
          child: _Mark(),
        ),
        NebaAppLogo(
          name: 'Neba',
          size: NebaSize.lg,
          shape: NebaAppLogoShape.app,
          padded: false,
          child: _Mark(),
        ),
      ],
    );
  }
}

/// The mark: an M drawn in the colour around it, square as its viewBox is.
class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _MarkPainter(IconTheme.of(context).color ?? const Color(0xFF000000)),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.shortestSide / 24)
      ..drawPath(
        Path()
          ..moveTo(4, 18)
          ..lineTo(4, 7)
          ..lineTo(12, 17)
          ..lineTo(20, 7)
          ..lineTo(20, 18),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}
