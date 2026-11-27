import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FloatingActionButtonDial extends StatefulWidget {
  const FloatingActionButtonDial({super.key});

  @override
  State<FloatingActionButtonDial> createState() => _FloatingActionButtonDialState();
}

class _FloatingActionButtonDialState extends State<FloatingActionButtonDial> {
  String _last = 'nothing yet';

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(tokens.radius[NebaSize.md]!);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Container(
        width: double.infinity,
        height: 256,
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: NebaTypography(
                  'Last action: $_last',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
              ),
              NebaFloatingActionButton(
                position: NebaFloatingActionButtonPosition.absolute,
                icon: const _Icon(_share),
                label: 'Share',
                children: <NebaFloatingAction>[
                  NebaFloatingAction(
                    icon: const _Icon(_link),
                    label: 'Copy link',
                    onPressed: () => setState(() => _last = 'Copy link'),
                  ),
                  NebaFloatingAction(
                    icon: const _Icon(_mail),
                    label: 'Email',
                    onPressed: () => setState(() => _last = 'Email'),
                  ),
                  NebaFloatingAction(
                    icon: const _Icon(_print),
                    label: 'Print',
                    onPressed: () => setState(() => _last = 'Print'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An arrow rising out of a tray, on the 16-unit grid.
Path _share() {
  return Path()
    ..moveTo(8, 10.5)
    ..lineTo(8, 2.75)
    ..lineTo(5.25, 5.5)
    ..moveTo(8, 2.75)
    ..lineTo(10.75, 5.5)
    ..moveTo(3.25, 9.5)
    ..lineTo(3.25, 12.75)
    ..lineTo(12.75, 12.75)
    ..lineTo(12.75, 9.5);
}

/// Two links of a chain.
Path _link() {
  const Radius bend = Radius.circular(2.75);

  return Path()
    ..moveTo(6.5, 9.5)
    ..relativeArcToPoint(const Offset(4, 0.25), radius: bend, clockwise: false)
    ..relativeLineTo(1.75, -1.75)
    ..relativeArcToPoint(const Offset(-3.9, -3.9), radius: bend, clockwise: false)
    ..lineTo(7.75, 5.2)
    ..moveTo(9.5, 6.5)
    ..relativeArcToPoint(const Offset(-4, -0.25), radius: bend, clockwise: false)
    ..lineTo(3.75, 8)
    ..relativeArcToPoint(const Offset(3.9, 3.9), radius: bend, clockwise: false)
    ..relativeLineTo(0.6, -0.6);
}

/// An envelope.
Path _mail() {
  return Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2.25, 3.75, 11.5, 8.5),
        const Radius.circular(1.5),
      ),
    )
    ..moveTo(2.75, 5)
    ..lineTo(8, 8.75)
    ..lineTo(13.25, 5);
}

/// A printer with a sheet in it.
Path _print() {
  return Path()
    ..moveTo(4.75, 6.5)
    ..lineTo(4.75, 3)
    ..lineTo(11.25, 3)
    ..lineTo(11.25, 6.5)
    ..addRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(2.25, 6.5, 11.5, 5), const Radius.circular(1.5)),
    )
    ..moveTo(4.75, 9.5)
    ..lineTo(11.25, 9.5)
    ..lineTo(11.25, 13.25)
    ..lineTo(4.75, 13.25)
    ..close();
}

/// A stroked path in the icon colour at the icon size the button hands down.
class _Icon extends StatelessWidget {
  const _Icon(this.path);

  final Path Function() path;

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);

    return SizedBox.square(
      dimension: icon.size ?? 16,
      child: CustomPaint(painter: _IconPainter(path, icon.color ?? const Color(0xFF000000))),
    );
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color);

  final Path Function() path;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 16)
      ..drawPath(
        path(),
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
  bool shouldRepaint(_IconPainter oldDelegate) {
    return oldDelegate.path != path || oldDelegate.color != color;
  }
}
