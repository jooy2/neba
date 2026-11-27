import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaColor> _families = <NebaColor>[
  NebaColor.primary,
  NebaColor.success,
  NebaColor.warning,
  NebaColor.danger,
];

class AnimateLightingColors extends StatelessWidget {
  const AnimateLightingColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final NebaColor color in _families)
          NebaAnimateLighting(
            key: ValueKey<NebaColor>(color),
            color: color,
            size: NebaSize.md,
            child: NebaBox(
              size: NebaSize.md,
              child: NebaTypography(color.name, level: NebaTypographyLevel.caption),
            ),
          ),
      ],
    );
  }
}
