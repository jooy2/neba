import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToggleSizes extends StatelessWidget {
  const ToggleSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      justifyContent: NebaJustifyContent.center,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaToggle(size: size, defaultPressed: true, child: Text(size.name)),
      ],
    );
  }
}
