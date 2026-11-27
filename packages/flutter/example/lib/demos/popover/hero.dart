import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PopoverHero extends StatelessWidget {
  const PopoverHero({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaPopover(
      trigger: NebaButton(
        onPressed: () {},
        variant: NebaVariant.outline,
        child: const Text('Share'),
      ),
      title: const Text('Share this page'),
      description: const Text('Anyone with the link can read it.'),
      showClose: true,
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 3,
        alignItems: NebaAlignItems.stretch,
        children: <Widget>[
          const NebaTextField(
            size: NebaSize.sm,
            label: Text('Link'),
            initialValue: 'https://neba.cdget.com/p/8f2c1a',
            readOnly: true,
            fullWidth: true,
          ),
          const NebaSwitch(size: NebaSize.sm, label: Text('Allow comments'), defaultChecked: true),
          NebaPopoverClose(
            builder: (BuildContext context, VoidCallback close) =>
                NebaButton(size: NebaSize.sm, onPressed: close, child: const Text('Copy link')),
          ),
        ],
      ),
    );
  }
}
