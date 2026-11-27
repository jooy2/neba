import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BottomNavigationAppearance extends StatelessWidget {
  const BottomNavigationAppearance({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 4,
        children: <Widget>[
          _Captioned(
            caption: 'variant: solid, color: success',
            child: _Bar(label: 'Solid', variant: NebaVariant.solid, color: NebaColor.success),
          ),
          _Captioned(
            caption: 'size: sm, density: compact',
            child: _Bar(label: 'Small', size: NebaSize.sm, density: NebaDensity.compact),
          ),
          _Captioned(
            caption: 'variant: text, divider: false',
            child: _Bar(label: 'Text', variant: NebaVariant.text, divider: false),
          ),
        ],
      ),
    );
  }
}

class _Captioned extends StatelessWidget {
  const _Captioned({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 1,
      children: <Widget>[
        NebaTypography(caption, level: NebaTypographyLevel.caption, color: NebaColor.secondary),
        child,
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    this.variant,
    this.color,
    this.size,
    this.density,
    this.divider = true,
  });

  /// Every bar on a screen takes a name once there is more than one, or
  /// Flutter's semantics check fails.
  final String label;
  final NebaVariant? variant;
  final NebaColor? color;
  final NebaSize? size;
  final NebaDensity? density;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return NebaBottomNavigation<String>(
      position: NebaPosition.static,
      label: label,
      defaultValue: 'two',
      variant: variant,
      color: color,
      size: size,
      density: density,
      divider: divider,
      children: const <NebaBottomNavigationItem<String>>[
        NebaBottomNavigationItem<String>(value: 'one', icon: _Dot(), child: Text('One')),
        NebaBottomNavigationItem<String>(value: 'two', icon: _Dot(), child: Text('Two')),
        NebaBottomNavigationItem<String>(value: 'three', icon: _Dot(), child: Text('Three')),
      ],
    );
  }
}

/// A ring, on the 16-unit grid, at the icon size and in the icon colour the
/// destination hands down.
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
