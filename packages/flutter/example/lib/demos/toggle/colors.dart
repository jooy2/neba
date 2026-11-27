import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleColors extends StatelessWidget {
  const ToggleColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      justifyContent: NebaJustifyContent.center,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaColor color in NebaColor.values)
          NebaToggle(color: color, defaultPressed: true, child: Text(color.name)),
      ],
    );
  }
}
