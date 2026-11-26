import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonFullWidth extends StatelessWidget {
  const ButtonFullWidth({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 2,
        children: <Widget>[
          NebaButton(
            onPressed: press,
            fullWidth: true,
            size: NebaSize.lg,
            child: const Text('Create workspace'),
          ),
          NebaButton(
            onPressed: press,
            fullWidth: true,
            variant: NebaVariant.text,
            color: NebaColor.secondary,
            child: const Text('Maybe later'),
          ),
        ],
      ),
    );
  }
}
