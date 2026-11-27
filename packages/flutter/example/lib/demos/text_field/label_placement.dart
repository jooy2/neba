import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A magnifying glass, drawn in the icon colour at the icon size the field
/// hands down.
class _SearchIcon extends StatelessWidget {
  const _SearchIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);
    final double size = icon.size ?? 16;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SearchPainter(icon.color ?? const Color(0xFF000000))),
    );
  }
}

class TextFieldLabelPlacement extends StatelessWidget {
  const TextFieldLabelPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan third = NebaGridSpan.columns(wide ? 4 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        rowSpacing: 6,
        columnSpacing: 4,
        padded: false,
        alignItems: NebaAlignItems.end,
        children: <Widget>[
          NebaGrid(
            span: third,
            child: const NebaTextField(
              label: Text('Top'),
              placeholder: 'you@example.com',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaTextField(
              labelPlacement: NebaLabelPlacement.notch,
              label: Text('Notch'),
              placeholder: 'you@example.com',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaTextField(
              labelPlacement: NebaLabelPlacement.float,
              label: Text('Float'),
              placeholder: 'you@example.com',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaTextField(
              labelPlacement: NebaLabelPlacement.notch,
              label: Text('Email'),
              startIcon: _SearchIcon(),
              placeholder: 'you@example.com',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaTextField(
              labelPlacement: NebaLabelPlacement.float,
              label: Text('Name'),
              initialValue: 'Ada Lovelace',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: third,
            child: const NebaTextField(
              labelPlacement: NebaLabelPlacement.float,
              label: Text('Message'),
              multiline: true,
              rows: 2,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// A circle and a handle, in the 16-unit box the React demo's SVG uses.
class _SearchPainter extends CustomPainter {
  _SearchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas
      ..scale(size.width / 16)
      ..drawCircle(const Offset(7, 7), 4.25, stroke)
      ..drawLine(const Offset(10.5, 10.5), const Offset(13.5, 13.5), stroke);
  }

  @override
  bool shouldRepaint(_SearchPainter oldDelegate) => oldDelegate.color != color;
}
