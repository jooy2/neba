import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// Every button state is here unchanged, the turning ring included.
class IconButtonStates extends StatefulWidget {
  const IconButtonStates({super.key});

  @override
  State<IconButtonStates> createState() => _IconButtonStatesState();
}

class _IconButtonStatesState extends State<IconButtonStates> {
  bool _loading = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() => _loading = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void press() {}

    Widget labelled(String caption, Widget button) {
      return NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        alignItems: NebaAlignItems.center,
        children: <Widget>[
          button,
          NebaTypography(caption, level: NebaTypographyLevel.caption),
        ],
      );
    }

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        labelled(
          'press me',
          NebaIconButton(
            onPressed: _refresh,
            icon: const _Refresh(),
            label: 'Refresh',
            loading: _loading,
          ),
        ),
        labelled(
          'disabled',
          NebaIconButton(
            onPressed: press,
            icon: const _Refresh(),
            label: 'Refresh',
            disabled: true,
          ),
        ),
        labelled(
          'readOnly',
          NebaIconButton(
            onPressed: press,
            icon: const _Refresh(),
            label: 'Refresh',
            readOnly: true,
          ),
        ),
        labelled(
          'elevation 2',
          NebaIconButton(onPressed: press, icon: const _Refresh(), label: 'Refresh', elevation: 2),
        ),
      ],
    );
  }
}

/// A circular arrow in the icon colour at the icon size the button hands
/// down.
class _Refresh extends StatelessWidget {
  const _Refresh();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _RefreshPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _RefreshPainter extends CustomPainter {
  _RefreshPainter(this.color);

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
      // Most of a circle of radius 5 round the middle, open at the top right.
      ..drawArc(Rect.fromCircle(center: const Offset(8, 8), radius: 5), 0, 5.4, false, stroke)
      ..drawPath(
        Path()
          ..moveTo(13, 2)
          ..lineTo(13, 5)
          ..lineTo(10, 5),
        stroke,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_RefreshPainter oldDelegate) => oldDelegate.color != color;
}
