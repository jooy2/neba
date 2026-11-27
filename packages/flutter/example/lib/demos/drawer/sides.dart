import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DrawerSides extends StatelessWidget {
  const DrawerSides({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final NebaSide side in <NebaSide>[
          NebaSide.left,
          NebaSide.right,
          NebaSide.top,
          NebaSide.bottom,
        ])
          NebaDrawer(
            side: side,
            triggerBuilder: (BuildContext context, VoidCallback open) {
              return NebaButton(
                onPressed: open,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: Text(side.name),
              );
            },
            title: Text('Attached to the ${side.name}'),
            description: const Text(
              'The corners on the free edge are cut; the ones against the window stay square.',
            ),
            child: const Text(
              'A side panel takes the width its size implies. A top or bottom panel is as tall '
              'as what is in it, up to 85% of the window.',
            ),
          ),
      ],
    );
  }
}
