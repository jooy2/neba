import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonGroupOrientation extends StatelessWidget {
  const ButtonGroupOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 8,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        NebaButtonGroup(
          variant: NebaVariant.outline,
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Left')),
            NebaButton(onPressed: press, child: const Text('Centre')),
            NebaButton(onPressed: press, child: const Text('Right')),
          ],
        ),
        NebaButtonGroup(
          orientation: NebaOrientation.vertical,
          variant: NebaVariant.outline,
          children: <Widget>[
            NebaButton(onPressed: press, child: const Text('Top')),
            NebaButton(onPressed: press, child: const Text('Middle')),
            NebaButton(onPressed: press, child: const Text('Bottom')),
          ],
        ),
      ],
    );
  }
}
