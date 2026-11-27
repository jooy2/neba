import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TooltipSides extends StatelessWidget {
  const TooltipSides({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSide side in NebaSide.values)
          NebaTooltip(
            side: side,
            delay: Duration.zero,
            content: Text('Placed on the ${side.name}'),
            child: NebaButton(
              onPressed: press,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: Text(side.name),
            ),
          ),
      ],
    );
  }
}
