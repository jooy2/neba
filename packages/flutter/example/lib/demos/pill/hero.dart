import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PillHero extends StatelessWidget {
  const PillHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaPill(
          startIcon: _Dot(),
          color: NebaColor.danger,
          title: Text('Recording'),
          endIcon: Padding(
            padding: EdgeInsetsDirectional.only(end: 8),
            child: Text(
              '02:14',
              style: TextStyle(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
            ),
          ),
        ),
        NebaPill(
          startIcon: _Note(),
          variant: NebaVariant.outline,
          color: NebaColor.primary,
          title: Text('Neba — Acrylic'),
          description: Text('Now playing'),
        ),
      ],
    );
  }
}

/// A filled dot, at the icon size and in the icon colour the pill sets.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);
    final double size = icon.size ?? 16;

    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Container(
          width: size / 2,
          height: size / 2,
          decoration: BoxDecoration(color: icon.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// A pair of quavers.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _NotePainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _NotePainter extends CustomPainter {
  _NotePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        Path()
          ..moveTo(6, 12)
          ..lineTo(6, 4)
          ..lineTo(12, 2.5)
          ..lineTo(12, 10.5)
          ..addOval(Rect.fromCircle(center: const Offset(4.5, 12), radius: 1.75))
          ..addOval(Rect.fromCircle(center: const Offset(10.5, 10.5), radius: 1.75)),
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
  bool shouldRepaint(_NotePainter oldDelegate) => oldDelegate.color != color;
}
