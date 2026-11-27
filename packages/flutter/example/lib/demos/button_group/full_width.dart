import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonGroupFullWidth extends StatelessWidget {
  const ButtonGroupFullWidth({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaButtonGroup(
        fullWidth: true,
        variant: NebaVariant.outline,
        color: NebaColor.secondary,
        children: <Widget>[
          NebaButton(onPressed: press, child: const Text('Cancel')),
          NebaButton(onPressed: press, child: const Text('Save draft')),
          NebaButton(onPressed: press, child: const Text('Publish')),
        ],
      ),
    );
  }
}
