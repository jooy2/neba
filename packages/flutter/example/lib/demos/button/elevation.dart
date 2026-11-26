import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonElevation extends StatelessWidget {
  const ButtonElevation({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (int level = 0; level <= 3; level += 1)
          NebaButton(
            onPressed: press,
            elevation: level,
            size: NebaSize.lg,
            child: Text('elevation $level'),
          ),
      ],
    );
  }
}
