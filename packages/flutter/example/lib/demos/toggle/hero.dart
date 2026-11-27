import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleHero extends StatelessWidget {
  const ToggleHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 3,
      justifyContent: NebaJustifyContent.center,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaToggle(defaultPressed: true, child: Text('Bold')),
        NebaToggle(child: Text('Italic')),
        NebaToggle(variant: NebaVariant.text, defaultPressed: true, child: Text('Underline')),
        NebaToggle(
          variant: NebaVariant.solid,
          color: NebaColor.success,
          defaultPressed: true,
          child: Text('Live'),
        ),
      ],
    );
  }
}
