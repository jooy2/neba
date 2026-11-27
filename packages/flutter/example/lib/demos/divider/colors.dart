import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DividerColors extends StatelessWidget {
  const DividerColors({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 5,
        children: <Widget>[
          for (final NebaColor color in NebaColor.values)
            NebaDivider(color: color, child: Text(color.name)),
        ],
      ),
    );
  }
}
