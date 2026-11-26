import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonDensity extends StatelessWidget {
  const ButtonDensity({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      children: <Widget>[
        for (final NebaDensity density in NebaDensity.values)
          NebaFlex(
            wrap: true,
            spacing: 3,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              NebaButton(onPressed: press, density: density, child: const Text('Save changes')),
              NebaButton(
                onPressed: press,
                density: density,
                variant: NebaVariant.outline,
                child: const Text('Save changes'),
              ),
            ],
          ),
      ],
    );
  }
}
