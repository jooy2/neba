import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingActionButtonCorners extends StatefulWidget {
  const FloatingActionButtonCorners({super.key});

  @override
  State<FloatingActionButtonCorners> createState() => _FloatingActionButtonCornersState();
}

class _FloatingActionButtonCornersState extends State<FloatingActionButtonCorners> {
  static const Map<NebaCorner, String> _names = <NebaCorner, String>{
    NebaCorner.topStart: 'top-start',
    NebaCorner.topEnd: 'top-end',
    NebaCorner.bottomStart: 'bottom-start',
    NebaCorner.bottomEnd: 'bottom-end',
  };

  NebaCorner _corner = NebaCorner.bottomEnd;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          // A row wider than a phone scrolls sideways there.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: NebaSegmentedButton<NebaCorner>(
              size: NebaSize.sm,
              semanticLabel: 'Corner',
              value: _corner,
              onValueChange: (NebaCorner? next) => setState(() => _corner = next ?? _corner),
              children: <NebaSegment<NebaCorner>>[
                for (final MapEntry<NebaCorner, String> entry in _names.entries)
                  NebaSegment<NebaCorner>(value: entry.key, child: Text(entry.value)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 224,
            decoration: BoxDecoration(
              border: Border.all(color: tokens.border),
              borderRadius: radius,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: <Widget>[
                  NebaFloatingActionButton(
                    position: NebaFloatingActionButtonPosition.absolute,
                    corner: _corner,
                    offset: 12,
                    icon: const _Plus(),
                    label: 'Add',
                    children: const <NebaFloatingAction>[
                      NebaFloatingAction(icon: _Dot(), label: 'Task'),
                      NebaFloatingAction(icon: _Dot(), label: 'Note'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A plus, on the 16-unit grid, at the icon size and in the icon colour the
/// button hands down.
class _Plus extends StatelessWidget {
  const _Plus();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _PlusPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawLine(const Offset(8, 3.5), const Offset(8, 12.5), stroke)
      ..drawLine(const Offset(3.5, 8), const Offset(12.5, 8), stroke)
      ..restore();
  }

  @override
  bool shouldRepaint(_PlusPainter oldDelegate) => oldDelegate.color != color;
}

/// A ring, on the 16-unit grid.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _DotPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawCircle(
        const Offset(8, 8),
        4.25,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => oldDelegate.color != color;
}
