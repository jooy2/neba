import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonVariants extends StatelessWidget {
  const ButtonVariants({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(onPressed: press, variant: NebaVariant.solid, child: const Text('Save')),
        NebaButton(onPressed: press, variant: NebaVariant.outline, child: const Text('Cancel')),
        NebaButton(onPressed: press, variant: NebaVariant.text, child: const Text('Details')),
      ],
    );
  }
}
