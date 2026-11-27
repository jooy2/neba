import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressCircularSizes extends StatelessWidget {
  const ProgressCircularSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 5,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaProgressCircular(size: size, value: 60, showValue: true),
      ],
    );
  }
}
