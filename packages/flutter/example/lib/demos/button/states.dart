import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonStates extends StatelessWidget {
  const ButtonStates({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final NebaVariant variant in NebaVariant.values)
          NebaFlex(
            wrap: true,
            spacing: 2,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              NebaButton(onPressed: press, variant: variant, child: const Text('Normal')),
              NebaButton(
                onPressed: press,
                variant: variant,
                loading: true,
                child: const Text('Loading'),
              ),
              NebaButton(onPressed: null, variant: variant, child: const Text('Disabled')),
              NebaButton(
                onPressed: press,
                variant: variant,
                readOnly: true,
                child: const Text('Read-only'),
              ),
            ],
          ),
      ],
    );
  }
}
