import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleControlled extends StatefulWidget {
  const ToggleControlled({super.key});

  @override
  State<ToggleControlled> createState() => _ToggleControlledState();
}

class _ToggleControlledState extends State<ToggleControlled> {
  bool _grid = true;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaToggle(
          pressed: _grid,
          onPressedChange: (bool on) => setState(() => _grid = on),
          child: const Text('Grid'),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: tokens.roles(NebaColor.primary).line),
            borderRadius: BorderRadius.circular(tokens.radius[NebaSize.md]!),
          ),
          child: _grid
              ? CustomPaint(painter: _GridPainter(tokens.roles(NebaColor.primary).line))
              : null,
        ),
      ],
    );
  }
}

/// A line every 16 pixels each way.
class _GridPainter extends CustomPainter {
  _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()..color = color;

    for (double at = 0; at < size.width; at += 16) {
      canvas.drawRect(Rect.fromLTWH(at, 0, 1, size.height), line);
    }

    for (double at = 0; at < size.height; at += 16) {
      canvas.drawRect(Rect.fromLTWH(0, at, size.width, 1), line);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
