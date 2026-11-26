import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonColors extends StatelessWidget {
  const ButtonColors({super.key});

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
              for (final NebaColor color in NebaColor.values)
                NebaButton(
                  onPressed: press,
                  variant: variant,
                  color: color,
                  child: Text(color.name),
                ),
            ],
          ),
      ],
    );
  }
}
