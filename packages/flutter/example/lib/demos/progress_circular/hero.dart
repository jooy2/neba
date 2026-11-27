import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ProgressCircularHero extends StatelessWidget {
  const ProgressCircularHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 6,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaProgressCircular(value: 72, showValue: true, label: Text('Indexing')),
        NebaProgressCircular(color: NebaColor.secondary),
      ],
    );
  }
}
