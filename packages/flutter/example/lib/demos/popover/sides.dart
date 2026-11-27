import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PopoverSides extends StatelessWidget {
  const PopoverSides({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSide side in NebaSide.values)
          NebaPopover(
            side: side,
            arrow: true,
            size: NebaSize.sm,
            trigger: NebaButton(
              onPressed: press,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: Text(side.name),
            ),
            child: Text(
              'Placed on the ${side.name}, and flipped to the opposite side when the window '
              'has no room for it.',
            ),
          ),
      ],
    );
  }
}
