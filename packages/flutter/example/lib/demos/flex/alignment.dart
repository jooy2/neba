import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FlexAlignment extends StatelessWidget {
  const FlexAlignment({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      justifyContent: NebaJustifyContent.spaceBetween,
      alignItems: NebaAlignItems.center,
      spacing: 3,
      children: <Widget>[
        const NebaFlex(
          alignItems: NebaAlignItems.center,
          spacing: 2,
          children: <Widget>[
            NebaAvatar(name: 'Kim Minji', size: NebaSize.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NebaTypography('Kim Minji'),
                NebaTypography(
                  'Owner',
                  level: NebaTypographyLevel.caption,
                  color: NebaColor.secondary,
                ),
              ],
            ),
          ],
        ),
        NebaButton(
          onPressed: () {},
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          child: const Text('Manage'),
        ),
      ],
    );
  }
}
