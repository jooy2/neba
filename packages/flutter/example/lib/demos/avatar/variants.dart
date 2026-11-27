import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class AvatarVariants extends StatelessWidget {
  const AvatarVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaFlex(
            wrap: true,
            spacing: 3,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              for (final NebaColor color in NebaColor.values)
                NebaAvatar(variant: variant, color: color, name: 'Jane Doe', size: NebaSize.lg),
            ],
          ),
      ],
    );
  }
}
