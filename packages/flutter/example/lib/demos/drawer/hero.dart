import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DrawerHero extends StatelessWidget {
  const DrawerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDrawer(
      triggerBuilder: (BuildContext context, VoidCallback open) {
        return NebaButton(
          onPressed: open,
          variant: NebaVariant.outline,
          child: const Text('Open navigation'),
        );
      },
      title: const Text('Workspace'),
      description: const Text('Everything this account can reach.'),
      actions: <Widget>[
        NebaDrawerClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(
              onPressed: close,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Close'),
            );
          },
        ),
      ],
      child: const NebaList(
        children: <Widget>[
          NebaListItem(description: Text('Deploys, usage and alerts'), child: Text('Overview')),
          NebaListItem(description: Text('12 active'), child: Text('Projects')),
          NebaListItem(description: Text('4 people'), child: Text('Members')),
          NebaListItem(description: Text('Team plan'), child: Text('Billing')),
        ],
      ),
    );
  }
}
