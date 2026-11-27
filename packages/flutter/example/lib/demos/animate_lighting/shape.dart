import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<({String label, double arc, double spread, double blur, int duration})> _shapes =
    <({String label, double arc, double spread, double blur, int duration})>[
      (label: 'spark', arc: 20, spread: 3, blur: 3, duration: 1800),
      (label: 'sweep', arc: 120, spread: 4, blur: 8, duration: 3200),
      (label: 'halo', arc: 170, spread: 8, blur: 14, duration: 5000),
    ];

class AnimateLightingShape extends StatelessWidget {
  const AnimateLightingShape({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final ({String label, double arc, double spread, double blur, int duration}) shape
            in _shapes)
          NebaAnimateLighting(
            key: ValueKey<String>(shape.label),
            arc: shape.arc,
            spread: shape.spread,
            blur: shape.blur,
            duration: Duration(milliseconds: shape.duration),
            size: NebaSize.md,
            child: NebaBox(
              size: NebaSize.md,
              child: NebaTypography(shape.label, level: NebaTypographyLevel.caption),
            ),
          ),
      ],
    );
  }
}
