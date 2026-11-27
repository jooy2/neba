import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class SegmentedButtonStates extends StatelessWidget {
  const SegmentedButtonStates({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        alignItems: NebaAlignItems.center,
        children: <Widget>[
          // Icons ride on the label, at 1.2 times its size.
          NebaSegmentedButton<String>(
            semanticLabel: 'Layout',
            defaultValue: 'grid',
            children: <NebaSegment<String>>[
              NebaSegment<String>(value: 'list', startIcon: _ListIcon(), child: Text('List')),
              NebaSegment<String>(value: 'grid', startIcon: _GridIcon(), child: Text('Grid')),
            ],
          ),

          // One segment out of the set, without disabling the rest.
          NebaSegmentedButton<String>(
            semanticLabel: 'Plan',
            defaultValue: 'team',
            children: <NebaSegment<String>>[
              NebaSegment<String>(value: 'starter', child: Text('Starter')),
              NebaSegment<String>(value: 'team', child: Text('Team')),
              NebaSegment<String>(value: 'enterprise', disabled: true, child: Text('Enterprise')),
            ],
          ),

          // Read-only keeps the choice and drains the saturation; disabled
          // drops the colour family entirely.
          NebaSegmentedButton<String>(
            semanticLabel: 'Mode',
            defaultValue: 'auto',
            readOnly: true,
            children: <NebaSegment<String>>[
              NebaSegment<String>(value: 'light', child: Text('Light')),
              NebaSegment<String>(value: 'auto', child: Text('Auto')),
              NebaSegment<String>(value: 'dark', child: Text('Dark')),
            ],
          ),

          // The full width, divided evenly.
          NebaSegmentedButton<String>(
            semanticLabel: 'Period',
            defaultValue: '30d',
            fullWidth: true,
            children: <NebaSegment<String>>[
              NebaSegment<String>(value: '7d', child: Text('7 days')),
              NebaSegment<String>(value: '30d', child: Text('30 days')),
              NebaSegment<String>(value: '90d', child: Text('90 days')),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridIcon extends StatelessWidget {
  const _GridIcon();

  @override
  Widget build(BuildContext context) {
    return _Glyph((Path path) {
      for (final Offset corner in const <Offset>[
        Offset(2.5, 2.5),
        Offset(9, 2.5),
        Offset(2.5, 9),
        Offset(9, 9),
      ]) {
        path.addRRect(
          RRect.fromRectAndRadius(corner & const Size(4.5, 4.5), const Radius.circular(1)),
        );
      }
    });
  }
}

class _ListIcon extends StatelessWidget {
  const _ListIcon();

  @override
  Widget build(BuildContext context) {
    return _Glyph((Path path) {
      for (final double y in const <double>[4, 8, 12]) {
        path
          ..moveTo(5.5, y)
          ..lineTo(13.5, y)
          ..moveTo(2.5, y)
          ..lineTo(2.51, y);
      }
    });
  }
}

/// A 16-unit path stroked in the icon colour at the icon size the segment
/// hands down.
class _Glyph extends StatelessWidget {
  const _Glyph(this.trace);

  final void Function(Path path) trace;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _GlyphPainter(trace, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.trace, this.color);

  final void Function(Path path) trace;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    trace(path);
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path,
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
  bool shouldRepaint(_GlyphPainter oldDelegate) => oldDelegate.color != color;
}
