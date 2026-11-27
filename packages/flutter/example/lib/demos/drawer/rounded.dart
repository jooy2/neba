import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DrawerRounded extends StatelessWidget {
  const DrawerRounded({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaDrawer(
          side: NebaSide.bottom,
          size: NebaSize.lg,
          triggerBuilder: (BuildContext context, VoidCallback open) {
            return NebaButton(
              onPressed: open,
              variant: NebaVariant.outline,
              child: const Text('Rounded'),
            );
          },
          title: const Text('Cut corners'),
          child: const Text(
            'The two corners facing the page are cut to the size step of the radius ladder.',
          ),
        ),
        NebaDrawer(
          side: NebaSide.bottom,
          size: NebaSize.lg,
          rounded: false,
          triggerBuilder: (BuildContext context, VoidCallback open) {
            return NebaButton(
              onPressed: open,
              variant: NebaVariant.outline,
              color: NebaColor.secondary,
              child: const Text('Square'),
            );
          },
          title: const Text('Square corners'),
          child: const Text(
            'Every corner is square, for a panel that should read as an extension of the window '
            'rather than a sheet laid over it.',
          ),
        ),
      ],
    );
  }
}
