import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonGroupShared extends StatelessWidget {
  const ButtonGroupShared({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        // Set once for the whole group.
        NebaButtonGroup(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          color: NebaColor.secondary,
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Copy')),
            NebaButton(onPressed: press, child: const Text('Duplicate')),
            NebaButton(onPressed: press, child: const Text('Archive')),
          ],
        ),

        // A button can still override what the group said.
        NebaButtonGroup(
          size: NebaSize.sm,
          variant: NebaVariant.outline,
          color: NebaColor.secondary,
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Copy')),
            NebaButton(onPressed: press, child: const Text('Duplicate')),
            NebaButton(onPressed: press, color: NebaColor.danger, child: const Text('Delete')),
          ],
        ),
      ],
    );
  }
}
