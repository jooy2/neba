import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _regions = <String>[
  'us-east-1',
  'us-west-2',
  'eu-west-1',
  'eu-central-1',
  'ap-northeast-1',
  'ap-northeast-2',
  'ap-southeast-1',
  'ap-southeast-2',
  'sa-east-1',
  'af-south-1',
  'me-south-1',
  'ca-central-1',
];

class DrawerScrolling extends StatelessWidget {
  const DrawerScrolling({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaDrawer(
      side: NebaSide.right,
      dividers: true,
      triggerBuilder: (BuildContext context, VoidCallback open) {
        return NebaButton(
          onPressed: open,
          variant: NebaVariant.outline,
          child: const Text('Pick a region'),
        );
      },
      title: const Text('Regions'),
      description: const Text('The header and the actions stay put; only the body scrolls.'),
      actions: <Widget>[
        NebaDrawerClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(
              onPressed: close,
              variant: NebaVariant.text,
              color: NebaColor.secondary,
              child: const Text('Cancel'),
            );
          },
        ),
        NebaDrawerClose(
          builder: (BuildContext context, VoidCallback close) {
            return NebaButton(onPressed: close, child: const Text('Apply'));
          },
        ),
      ],
      child: NebaList(
        children: <Widget>[
          for (final String region in _regions)
            NebaListItem(key: ValueKey<String>(region), child: Text(region)),
        ],
      ),
    );
  }
}
