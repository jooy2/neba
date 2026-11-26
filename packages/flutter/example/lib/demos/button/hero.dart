import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ButtonHero extends StatelessWidget {
  const ButtonHero({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaButton(onPressed: press, child: const Text('Save')),
        NebaButton(onPressed: press, variant: NebaVariant.outline, child: const Text('Cancel')),
        NebaButton(onPressed: press, variant: NebaVariant.text, child: const Text('Details')),
        NebaButton(onPressed: press, color: NebaColor.danger, child: const Text('Delete')),
        NebaButton(onPressed: press, loading: true, child: const Text('Saving')),
        const NebaButton(onPressed: null, child: Text('Unavailable')),
      ],
    );
  }
}
