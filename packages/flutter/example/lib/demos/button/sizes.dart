import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonSizes extends StatelessWidget {
  const ButtonSizes({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaButton(onPressed: press, size: size, child: Text(size.name)),
      ],
    );
  }
}
