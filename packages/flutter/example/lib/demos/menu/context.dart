import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// The same rows, opened by a right-click or a long press instead of by a
/// button. It takes the rows as `content` and the area as `child`, and lays
/// the area out exactly as it would be without it. The box takes the focus,
/// so the context-menu key and Shift+F10 open it too.
class MenuContext extends StatelessWidget {
  const MenuContext({super.key});

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaContextMenu(
      content: const <Widget>[
        NebaMenuItem(shortcut: Text('⌘X'), child: Text('Cut')),
        NebaMenuItem(shortcut: Text('⌘C'), child: Text('Copy')),
        NebaMenuItem(shortcut: Text('⌘V'), child: Text('Paste')),
        NebaMenuSeparator(),
        NebaMenuSubmenu(
          label: Text('Transform'),
          children: <Widget>[
            NebaMenuItem(child: Text('To uppercase')),
            NebaMenuItem(child: Text('To lowercase')),
          ],
        ),
        NebaMenuSeparator(),
        NebaMenuItem(color: NebaColor.danger, child: Text('Delete')),
      ],
      child: Focus(
        child: CustomPaint(
          painter: _DashedBorder(tokens.border, tokens.radius[NebaSize.md]!),
          child: SizedBox(
            height: 128,
            child: Center(
              child: Text(
                'Right-click anywhere in this box',
                style: TextStyle(fontSize: 13, color: tokens.mutedFg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 1-pixel dashed edge with rounded corners, CSS `border-dashed`.
class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color, this.radius);

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Path edge = Path()
      ..addRRect(
        RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), Radius.circular(radius)),
      );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final PathMetric metric in edge.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 6) {
        canvas.drawPath(metric.extractPath(distance, distance + 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
