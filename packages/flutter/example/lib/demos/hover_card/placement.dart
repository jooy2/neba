import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class HoverCardPlacement extends StatelessWidget {
  const HoverCardPlacement({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      justifyContent: NebaJustifyContent.center,
      children: <Widget>[
        for (final NebaSide side in NebaSide.values)
          NebaHoverCard(
            side: side,
            arrow: true,
            size: NebaSize.sm,
            trigger: NebaButton(
              onPressed: press,
              size: NebaSize.sm,
              variant: NebaVariant.outline,
              child: Text(side.name),
            ),
            title: const Text('Deploy 4f21c8'),
            child: const Text('Built in 42s, shipped to production.'),
          ),
      ],
    );
  }
}
