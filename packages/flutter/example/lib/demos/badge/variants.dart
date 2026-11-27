import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class BadgeVariants extends StatelessWidget {
  const BadgeVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaFlex(
            wrap: true,
            spacing: 5,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              for (final NebaColor color in NebaColor.values)
                NebaBadge.count(
                  count: 8,
                  variant: variant,
                  color: color,
                  child: NebaButton(
                    onPressed: () {},
                    variant: NebaVariant.outline,
                    color: NebaColor.secondary,
                    size: NebaSize.sm,
                    child: Text(color.name),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
